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
    func httpErrorWithHeadersCarriesStatusCodeDataAndHeaders() {
        let data = Data("not found".utf8)
        let headers = ["Retry-After": "30"]
        let error = CDUntappdKitError.httpErrorWithHeaders(statusCode: 404, data: data, headers: headers)
        guard case let .httpErrorWithHeaders(statusCode, carriedData, carriedHeaders) = error else {
            Issue.record("Expected .httpErrorWithHeaders")
            return
        }
        #expect(statusCode == 404)
        #expect(carriedData == data)
        #expect(carriedHeaders == headers)
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

    @Test
    func invalidCredentialsCarriesMessage() {
        let error = CDUntappdKitError.invalidCredentials("A clientId is required.")
        guard case let .invalidCredentials(message) = error else {
            Issue.record("Expected .invalidCredentials")
            return
        }
        #expect(message == "A clientId is required.")
    }
}
