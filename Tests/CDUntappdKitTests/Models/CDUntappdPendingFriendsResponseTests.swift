import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdPendingFriendsResponse Tests")
struct CDUntappdPendingFriendsResponseTests {

    @Test
    func decodesNestedFriendsFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "pending_friends", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdPendingFriendsResponse.self, from: data)
        #expect(response.friends?.count == 1)
        #expect(response.friends?.first?.user?.username == "PendingUser")
    }

    @Test
    func friendsIsNilWhenResponseKeyIsAbsent() throws {
        let json = """
        {
          "meta": { "code": 200 }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDUntappdPendingFriendsResponse.self, from: json)
        #expect(response.friends == nil)
    }
}
