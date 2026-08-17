import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdActionResultResponse Tests")
struct CDUntappdActionResultResponseTests {

    @Test
    func decodesResultFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "action_result", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdActionResultResponse.self, from: data)
        #expect(response.result == true)
    }

    @Test
    func resultIsNilWhenResponseKeyIsAbsent() throws {
        let json = """
        {
          "meta": { "code": 200 }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDUntappdActionResultResponse.self, from: json)
        #expect(response.result == nil)
    }
}
