import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdParameterEncoding Tests")
struct CDUntappdParameterEncodingTests {

    private let baseURL = URL(string: "https://api.untappd.com/v4/user/info")!

    @Test
    func encodesTrueBoolAsNumericOne() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["compact": true])
        #expect(request.url?.query?.contains("compact=1") == true)
    }

    @Test
    func encodesFalseBoolAsNumericZero() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["compact": false])
        #expect(request.url?.query?.contains("compact=0") == true)
    }

    @Test
    func encodesStringValuesVerbatim() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["compact": "true"])
        #expect(request.url?.query?.contains("compact=true") == true)
    }

    @Test
    func encodesIntValues() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["offset": 25])
        #expect(request.url?.query?.contains("offset=25") == true)
    }

    @Test
    func requestUsesGETMethod() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: [:])
        #expect(request.httpMethod == "GET")
    }

    @Test
    func emptyParametersProduceNoQuery() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: [:])
        #expect(request.url?.query == nil)
    }
}
