import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdKitError Tests")
struct CDUntappdKitErrorTests {

    @Test
    func invalidRequestCarriesUnderlyingError() {
        let underlying = URLError(.badURL)
        let error = CDUntappdKitError.invalidRequest(underlying: underlying)
        guard case let .invalidRequest(carried) = error else {
            Issue.record("Expected .invalidRequest")
            return
        }
        #expect((carried as? URLError)?.code == .badURL)
    }

    @Test
    func networkFailureCarriesUnderlyingError() {
        let underlying = URLError(.notConnectedToInternet)
        let error = CDUntappdKitError.networkFailure(underlying: underlying)
        guard case let .networkFailure(carried) = error else {
            Issue.record("Expected .networkFailure")
            return
        }
        #expect((carried as? URLError)?.code == .notConnectedToInternet)
    }

    @Test
    func httpErrorCarriesStatusCodeAndData() {
        let data = Data("not found".utf8)
        let error = CDUntappdKitError.httpError(statusCode: 404, data: data)
        guard case let .httpError(statusCode, carriedData) = error else {
            Issue.record("Expected .httpError")
            return
        }
        #expect(statusCode == 404)
        #expect(carriedData == data)
    }

    @Test
    func decodingFailedCarriesUnderlyingError() throws {
        struct DummyDecodingTarget: Decodable { let value: String }
        var thrown: Error?
        do {
            _ = try JSONDecoder().decode(DummyDecodingTarget.self, from: Data("{}".utf8))
        } catch {
            thrown = error
        }
        let underlying = try #require(thrown)
        let error = CDUntappdKitError.decodingFailed(underlying: underlying)
        guard case .decodingFailed = error else {
            Issue.record("Expected .decodingFailed")
            return
        }
    }

    @Test
    func apiErrorCarriesMessage() {
        let error = CDUntappdKitError.apiError("invalid_access_token")
        guard case let .apiError(message) = error else {
            Issue.record("Expected .apiError")
            return
        }
        #expect(message == "invalid_access_token")
    }
}
