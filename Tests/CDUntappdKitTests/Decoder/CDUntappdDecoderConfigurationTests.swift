//
//  CDUntappdDecoderConfigurationTests.swift
//  CDUntappdKitTests
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import Testing
@testable import CDUntappdKit

@Suite("CDUntappdDecoderConfiguration Tests")
struct CDUntappdDecoderConfigurationTests {

    private struct Fixture: Decodable {
        let helloWorld: String
    }

    private struct DateFixture: Decodable {
        let value: Date
    }

    @Test
    func defaultConfigurationDecodesUnmodifiedKeys() {
        let decoder = CDUntappdDecoderConfiguration.default.makeDecoder()
        let json = Data(#"{"helloWorld": "test"}"#.utf8)
        let result = try? decoder.decode(Fixture.self, from: json)
        #expect(result?.helloWorld == "test")
    }

    @Test
    func customKeyDecodingStrategyChangesDecodeBehavior() {
        let decoder = CDUntappdDecoderConfiguration(keyDecodingStrategy: .convertFromSnakeCase).makeDecoder()
        let json = Data(#"{"hello_world": "test"}"#.utf8)
        let result = try? decoder.decode(Fixture.self, from: json)
        #expect(result?.helloWorld == "test")
    }

    @Test
    func defaultConfigurationDoesNotConvertSnakeCaseKeys() {
        let decoder = CDUntappdDecoderConfiguration.default.makeDecoder()
        let json = Data(#"{"hello_world": "test"}"#.utf8)
        let result = try? decoder.decode(Fixture.self, from: json)
        #expect(result == nil)
    }

    @Test
    func customDateDecodingStrategyChangesDecodeBehavior() {
        let decoder = CDUntappdDecoderConfiguration(dateDecodingStrategy: .secondsSince1970).makeDecoder()
        let json = Data(#"{"value": 1000}"#.utf8)
        let result = try? decoder.decode(DateFixture.self, from: json)
        #expect(result?.value.timeIntervalSince1970 == 1000)
    }

    @Test
    func defaultDateDecodingStrategyDoesNotTreatRawNumberAsSecondsSince1970() {
        let decoder = CDUntappdDecoderConfiguration.default.makeDecoder()
        let json = Data(#"{"value": 1000}"#.utf8)
        let result = try? decoder.decode(DateFixture.self, from: json)
        #expect(result?.value.timeIntervalSince1970 != 1000)
    }
}
