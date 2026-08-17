import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdToastResponse Tests")
struct CDUntappdToastResponseTests {

    @Test
    func decodesResultFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "toast", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdToastResponse.self, from: data)
        #expect(response.result == "success")
    }

    @Test
    func resultIsNilWhenResponseKeyIsAbsent() throws {
        let json = """
        {
          "meta": { "code": 200 }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDUntappdToastResponse.self, from: json)
        #expect(response.result == nil)
    }
}
