import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdCheckinResponse Tests")
struct CDUntappdCheckinResponseTests {

    @Test
    func decodesNestedCheckinFromRealisticResponseShape() throws {
        let url = try #require(Bundle.module.url(forResource: "checkin_add", withExtension: "json"))
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(CDUntappdCheckinResponse.self, from: data)
        #expect(response.checkin != nil)
        #expect(response.checkin?.id == 999_888_777)
        #expect(response.checkin?.comment == "Great beer!")
    }

    @Test
    func checkinIsNilWhenResponseKeyIsAbsent() throws {
        let json = """
        {
          "meta": { "code": 200 }
        }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CDUntappdCheckinResponse.self, from: json)
        #expect(response.checkin == nil)
    }
}
