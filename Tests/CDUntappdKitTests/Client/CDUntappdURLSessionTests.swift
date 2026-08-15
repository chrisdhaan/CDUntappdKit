import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdURLSession Tests")
struct CDUntappdURLSessionTests {

    private struct Fixture: Decodable, Equatable {
        let value: String
    }

    private let request = URLRequest(url: URL(string: "https://api.untappd.com/v4/user/info")!)

    @Test
    func performDecodesSuccessfulResponse() async throws {
        let stubbedRequest = CDUntappdMockURLProtocol.stubbing(
            request,
            with: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8))
        )
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        let result: Fixture = try await session.perform(stubbedRequest)
        #expect(result == Fixture(value: "ok"))
    }

    @Test
    func performThrowsHTTPErrorForNon2xxStatus() async throws {
        let stubbedRequest = CDUntappdMockURLProtocol.stubbing(
            request,
            with: .init(statusCode: 404, data: Data("not found".utf8))
        )
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(stubbedRequest)
            Issue.record("Expected .httpError to be thrown")
        } catch let CDUntappdKitError.httpError(statusCode, data) {
            #expect(statusCode == 404)
            #expect(data == Data("not found".utf8))
        }
    }

    @Test
    func performThrowsNetworkFailureOnTransportError() async throws {
        let stubbedRequest = CDUntappdMockURLProtocol.stubbing(
            request,
            with: .init(error: URLError(.notConnectedToInternet))
        )
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(stubbedRequest)
            Issue.record("Expected .networkFailure to be thrown")
        } catch let CDUntappdKitError.networkFailure(underlying) {
            #expect((underlying as? URLError)?.code == .notConnectedToInternet)
        }
    }

    @Test
    func performThrowsDecodingFailedOnMalformedBody() async throws {
        let stubbedRequest = CDUntappdMockURLProtocol.stubbing(
            request,
            with: .init(statusCode: 200, data: Data("not json".utf8))
        )
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(stubbedRequest)
            Issue.record("Expected .decodingFailed to be thrown")
        } catch let CDUntappdKitError.decodingFailed(underlying) {
            #expect(underlying is DecodingError)
        }
    }

    @Test
    func cancelAllTasksWaitsUntilInFlightTaskIsActuallyCancelled() async throws {
        let urlSession = CDUntappdMockURLProtocol.makeSession()
        let stubbedRequest = CDUntappdMockURLProtocol.stubbing(
            request,
            with: .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8), delay: 0.5)
        )
        let session = CDUntappdURLSession(session: urlSession)

        let performTask = Task<Fixture?, Never> {
            try? await session.perform(stubbedRequest) as Fixture?
        }

        while await urlSession.allTasks.isEmpty {
            try await Task.sleep(nanoseconds: 1_000_000)
        }

        await session.cancelAllTasks()

        #expect(await urlSession.allTasks.isEmpty)
        let result = await performTask.value
        #expect(result == nil)
    }
}
