import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdAddCommentResponse Tests")
struct CDUntappdAddCommentResponseTests {

    @Test
    func decodesNestedCommentFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "add_comment", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdAddCommentResponse.self, from: data)
        #expect(response.comment != nil)
        #expect(response.comment?.id == 555)
        #expect(response.comment?.comment == "Cheers!")
        #expect(response.comment?.user?.username == "TestFriend")
    }

    @Test
    func commentIsNilWhenResponseKeyIsAbsent() throws {
        let json = """
        {
          "meta": { "code": 200 }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDUntappdAddCommentResponse.self, from: json)
        #expect(response.comment == nil)
    }
}
