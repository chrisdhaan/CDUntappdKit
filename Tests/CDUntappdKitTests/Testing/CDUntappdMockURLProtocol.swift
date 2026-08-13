import Foundation

/// A `URLProtocol` that intercepts every request and returns a pre-configured response,
/// for testing `CDUntappdURLSession` and callers that build a `URLSession` around it,
/// without making a real network call.
///
/// Two ways to attach a stub, both free of the single shared mutable slot Task 5's
/// original design used (a `static var stub`), which races whenever more than one
/// `@Suite` exercises this mock concurrently — Swift Testing's `.serialized` trait only
/// serializes a suite's own tests against each other, never against a different suite:
///
/// 1. `stubbing(_:with:)` attaches the stub directly to a specific `URLRequest` instance
///    via `URLProtocol.setProperty(_:forKey:in:)`, Foundation's sanctioned mechanism for
///    out-of-band per-request metadata. Use this when the test constructs the exact
///    `URLRequest` that will be sent (e.g. testing `CDUntappdURLSession.perform(_:)` directly).
/// 2. `register(stub:for:)` associates a stub with a specific `URL` in a lock-protected
///    dictionary. Use this when the request is built internally by the code under test
///    (e.g. `CDUntappdAPIClient.fetchUserInfo`, which builds its own `URLRequest` via
///    `CDUntappdRouter`), so the test never gets to touch the actual `URLRequest` instance
///    that ends up on the wire — `setProperty`'s attachment is tied to that specific request
///    object's identity, which a separately-constructed "equivalent" request can't share.
///    Give each such registration a unique `URL` (e.g. a unique username baked into the
///    request) so concurrently-running tests can never collide on the same entry.
final class CDUntappdMockURLProtocol: URLProtocol, @unchecked Sendable {

    struct Stub {
        let statusCode: Int
        let data: Data
        let error: Error?

        init(statusCode: Int = 200, data: Data = Data(), error: Error? = nil) {
            self.statusCode = statusCode
            self.data = data
            self.error = error
        }
    }

    private static let stubPropertyKey = "CDUntappdMockURLProtocolStub"

    private static let urlKeyedStubsLock = NSLock()
    private nonisolated(unsafe) static var urlKeyedStubs: [URL: Stub] = [:]

    /// Returns a copy of `request` with `stub` attached, for use with a session created by
    /// `makeSession()`. Safe under concurrent test execution: the stub travels with this
    /// specific request instance only.
    static func stubbing(_ request: URLRequest, with stub: Stub) -> URLRequest {
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(stub, forKey: stubPropertyKey, in: mutableRequest)
        return mutableRequest as URLRequest
    }

    /// Registers `stub` to be served for any request whose `url` equals `url`, for use when
    /// the code under test builds its own `URLRequest` internally. Give each call a distinct
    /// `url` so concurrently-running tests never share an entry.
    static func register(stub: Stub, for url: URL) {
        urlKeyedStubsLock.lock()
        defer { urlKeyedStubsLock.unlock() }
        urlKeyedStubs[url] = stub
    }

    private static func urlKeyedStub(for url: URL?) -> Stub? {
        guard let url else { return nil }
        urlKeyedStubsLock.lock()
        defer { urlKeyedStubsLock.unlock() }
        return urlKeyedStubs[url]
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [CDUntappdMockURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let stub = (URLProtocol.property(forKey: Self.stubPropertyKey, in: request) as? Stub)
            ?? Self.urlKeyedStub(for: request.url)
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://api.untappd.com/v4/")!,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
