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

    /// Matches Alamofire's `URLEncoding.default` behavior: `+` must be percent-encoded to
    /// `%2B`. Left unescaped (as `URLComponents`'s default `queryItems` escaping would leave
    /// it), a server following the form-decoding convention interprets a literal `+` as a
    /// space, silently corrupting the value (e.g. a search for "Founders + Friends").
    @Test
    func encodesPlusSignAsPercentTwoB() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["q": "Founders + Friends"])
        let requestURL = try #require(request.url)
        let query = try #require(requestURL.query)
        #expect(query.contains("%2B"))
        #expect(!query.contains("q=Founders + Friends"))
        // A literal `+` left in a query string is form-decoded as a space by many servers —
        // guard against that specific corruption, not just "some encoding happened".
        #expect(!query.contains("+"))
    }

    /// Alamofire's `URLEncoding.default` additionally escapes RFC 3986 sub-delimiters that
    /// `URLComponents`'s default escaping leaves alone. Spot-check a couple of them.
    @Test
    func encodesAlamofireReservedSubDelimiters() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["q": "a;b,c:d"])
        let requestURL = try #require(request.url)
        let query = try #require(requestURL.query)
        #expect(query.contains("a%3Bb%2Cc%3Ad"))
    }

    @Test
    func encodedQueryDecodesBackToOriginalValue() throws {
        let request = try CDUntappdParameterEncoding.urlRequest(for: baseURL, parameters: ["q": "Founders + Friends"])
        let requestURL = try #require(request.url)
        let components = try #require(URLComponents(url: requestURL, resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.first(where: { $0.name == "q" })?.value == "Founders + Friends")
    }

    @Test
    func httpBodyRequestUsesPOSTMethod() throws {
        let request = try CDUntappdParameterEncoding.httpBodyRequest(for: baseURL, parameters: ["bid": 123])
        #expect(request.httpMethod == "POST")
    }

    @Test
    func httpBodyRequestPutsParametersInBothQueryAndBody() throws {
        let request = try CDUntappdParameterEncoding.httpBodyRequest(for: baseURL, parameters: ["bid": 123])
        #expect(request.url?.query == "bid=123")
        let bodyString = try #require(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        #expect(bodyString == "bid=123")
    }

    @Test
    func httpBodyRequestSetsFormEncodedContentType() throws {
        let request = try CDUntappdParameterEncoding.httpBodyRequest(for: baseURL, parameters: ["bid": 123])
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/x-www-form-urlencoded")
    }

    @Test
    func httpBodyRequestEncodesMultipleParametersSortedAndJoined() throws {
        let request = try CDUntappdParameterEncoding.httpBodyRequest(for: baseURL, parameters: ["b": 2, "a": 1])
        let bodyString = try #require(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        #expect(bodyString == "a=1&b=2")
    }

    @Test
    func httpBodyRequestEmptyParametersProduceEmptyBody() throws {
        let request = try CDUntappdParameterEncoding.httpBodyRequest(for: baseURL, parameters: [:])
        let bodyString = try #require(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        #expect(bodyString == "")
    }
}
