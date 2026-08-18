import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdEventMonitor Tests")
struct CDUntappdEventMonitorTests {

    private struct Fixture: Decodable, Equatable {
        let value: String
    }

    private final class SpyMonitor: CDUntappdEventMonitor, @unchecked Sendable {
        private let lock = NSLock()
        private var _startedRequests: [URLRequest] = []
        private var _completedResponses: [(response: HTTPURLResponse?, error: Error?)] = []

        var startedRequests: [URLRequest] {
            lock.lock()
            defer { lock.unlock() }
            return _startedRequests
        }

        var completedResponses: [(response: HTTPURLResponse?, error: Error?)] {
            lock.lock()
            defer { lock.unlock() }
            return _completedResponses
        }

        func requestDidStart(urlRequest: URLRequest) {
            lock.lock()
            _startedRequests.append(urlRequest)
            lock.unlock()
        }

        func requestDidComplete(urlRequest _: URLRequest?, response: HTTPURLResponse?, data _: Data?, error: Error?) {
            lock.lock()
            _completedResponses.append((response, error))
            lock.unlock()
        }
    }

    private func makeRequest(path: String) -> URLRequest {
        URLRequest(url: URL(string: "https://api.untappd.com/v4/monitor/\(path)")!)
    }

    @Test
    func notifiesMonitorOfSuccessfulRequestStartAndComplete() async throws {
        let request = makeRequest(path: "success")
        try CDUntappdMockURLProtocol.register(
            stub: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            for: #require(request.url)
        )
        let monitor = SpyMonitor()
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession(), eventMonitors: [monitor])

        let result: Fixture = try await session.perform(request)

        #expect(result == Fixture(value: "ok"))
        #expect(monitor.startedRequests.count == 1)
        #expect(monitor.completedResponses.count == 1)
        #expect(monitor.completedResponses.first?.response?.statusCode == 200)
        #expect(monitor.completedResponses.first?.error == nil)
    }

    @Test
    func notifiesMonitorOfTerminalFailureWithoutRetry() async throws {
        let request = makeRequest(path: "failure")
        try CDUntappdMockURLProtocol.register(stub: .init(statusCode: 404, data: Data()), for: #require(request.url))
        let monitor = SpyMonitor()
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession(), eventMonitors: [monitor])

        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .httpError to be thrown")
        } catch let CDUntappdKitError.httpError(statusCode, _) {
            #expect(statusCode == 404)
        }

        #expect(monitor.startedRequests.count == 1)
        #expect(monitor.completedResponses.count == 1)
        #expect(monitor.completedResponses.first?.response?.statusCode == 404)
    }

    @Test
    func notifiesMonitorOfEachRetryBeforeEventualSuccess() async throws {
        let request = makeRequest(path: "retry-notify")
        try CDUntappdMockURLProtocol.register(
            stubs: [
                .init(statusCode: 503, data: Data()),
                .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8)),
            ],
            for: #require(request.url)
        )
        let monitor = SpyMonitor()
        let session = CDUntappdURLSession(
            session: CDUntappdMockURLProtocol.makeSession(),
            retryConfiguration: CDUntappdRetryConfiguration(retryLimit: 3, initialDelay: 0.01),
            eventMonitors: [monitor]
        )

        let result: Fixture = try await session.perform(request)

        #expect(result == Fixture(value: "ok"))
        // requestDidStart fires once per logical request, not once per attempt.
        #expect(monitor.startedRequests.count == 1)
        #expect(monitor.completedResponses.count == 1)
        #expect(monitor.completedResponses.first?.response?.statusCode == 200)
    }
}
