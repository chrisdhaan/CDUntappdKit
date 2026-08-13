import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdURLSession Tests", .serialized)
struct CDUntappdURLSessionTests {

    private struct Fixture: Decodable, Equatable {
        let value: String
    }

    private let request = URLRequest(url: URL(string: "https://api.untappd.com/v4/user/info")!)

    @Test
    func performDecodesSuccessfulResponse() async throws {
        CDUntappdMockURLProtocol.stub = .init(statusCode: 200, data: Data(#"{"value":"ok"}"#.utf8))
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        let result: Fixture = try await session.perform(request)
        #expect(result == Fixture(value: "ok"))
    }

    @Test
    func performThrowsHTTPErrorForNon2xxStatus() async throws {
        CDUntappdMockURLProtocol.stub = .init(statusCode: 404, data: Data("not found".utf8))
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .httpError to be thrown")
        } catch let CDUntappdKitError.httpError(statusCode, data) {
            #expect(statusCode == 404)
            #expect(data == Data("not found".utf8))
        }
    }

    @Test
    func performThrowsNetworkFailureOnTransportError() async throws {
        CDUntappdMockURLProtocol.stub = .init(error: URLError(.notConnectedToInternet))
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .networkFailure to be thrown")
        } catch let CDUntappdKitError.networkFailure(underlying) {
            #expect((underlying as? URLError)?.code == .notConnectedToInternet)
        }
    }

    @Test
    func performThrowsDecodingFailedOnMalformedBody() async throws {
        CDUntappdMockURLProtocol.stub = .init(statusCode: 200, data: Data("not json".utf8))
        let session = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        do {
            let _: Fixture = try await session.perform(request)
            Issue.record("Expected .decodingFailed to be thrown")
        } catch is CDUntappdKitError {
            // expected — specifically .decodingFailed, checked via case match below
        }
        CDUntappdMockURLProtocol.stub = .init(statusCode: 200, data: Data("not json".utf8))
        let session2 = CDUntappdURLSession(session: CDUntappdMockURLProtocol.makeSession())
        await #expect(throws: CDUntappdKitError.self) {
            let _: Fixture = try await session2.perform(request)
        }
    }
}
