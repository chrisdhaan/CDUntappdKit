import Foundation

/// A `URLProtocol` that intercepts every request and returns a pre-configured response,
/// for testing `CDUntappdURLSession` and callers that build a `URLSession` around it,
/// without making a real network call.
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

    /// Set before making a request through a session configured with this protocol.
    /// Not thread-safe; this static var is safe only because `CDUntappdURLSessionTests`
    /// uses the `.serialized` trait. Any other test suite consuming this mock must do the same.
    nonisolated(unsafe) static var stub: Stub = Stub()

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
        let stub = Self.stub
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
