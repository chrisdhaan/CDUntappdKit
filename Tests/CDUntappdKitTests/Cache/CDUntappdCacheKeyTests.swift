import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdCacheKey Tests")
struct CDUntappdCacheKeyTests {

    @Test
    func sameURLAndMethodProduceTheSameKey() throws {
        let first = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info?a=1")))
        let second = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info?a=1")))
        #expect(CDUntappdCacheKey.key(for: first) == CDUntappdCacheKey.key(for: second))
    }

    @Test
    func queryItemOrderDoesNotAffectTheKey() throws {
        let first = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info?a=1&b=2")))
        let second = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info?b=2&a=1")))
        #expect(CDUntappdCacheKey.key(for: first) == CDUntappdCacheKey.key(for: second))
    }

    @Test
    func differentHTTPMethodsProduceDifferentKeys() throws {
        var getRequest = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info")))
        getRequest.httpMethod = "GET"
        var postRequest = getRequest
        postRequest.httpMethod = "POST"
        #expect(CDUntappdCacheKey.key(for: getRequest) != CDUntappdCacheKey.key(for: postRequest))
    }

    @Test
    func differentURLsProduceDifferentKeys() throws {
        let first = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info?username=alice")))
        let second = try URLRequest(url: #require(URL(string: "https://api.untappd.com/v4/user/info?username=bob")))
        #expect(CDUntappdCacheKey.key(for: first) != CDUntappdCacheKey.key(for: second))
    }
}
