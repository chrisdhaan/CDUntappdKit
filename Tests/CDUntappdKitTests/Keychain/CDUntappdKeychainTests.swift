//
//  CDUntappdKeychainTests.swift
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

/// Each test uses its own Keychain key (rather than one shared key) so Swift Testing's
/// default parallel execution can't race two tests against the same underlying item -
/// the same class of shared-mutable-state race documented on `SharedKeychainTests`.
@Suite("CDUntappdKeychain Tests")
struct CDUntappdKeychainTests {

    private func uniqueKey(_ name: String = #function) -> String {
        "CDUntappdKitTestKey-\(name)"
    }

    @Test
    func storesAndRetrievesString() {
        let key = uniqueKey()
        #expect(CDUntappdKeychain.set("hello_world", forKey: key) == true)
        #expect(CDUntappdKeychain.string(forKey: key) == "hello_world")
        CDUntappdKeychain.delete(forKey: key)
    }

    @Test
    func returnsNilForMissingKey() {
        let key = uniqueKey()
        #expect(CDUntappdKeychain.string(forKey: key) == nil)
    }

    @Test
    func updatesExistingItem() {
        let key = uniqueKey()
        CDUntappdKeychain.set("first_value", forKey: key)
        CDUntappdKeychain.set("second_value", forKey: key)
        #expect(CDUntappdKeychain.string(forKey: key) == "second_value")
        CDUntappdKeychain.delete(forKey: key)
    }

    @Test
    func deleteRemovesItem() {
        let key = uniqueKey()
        CDUntappdKeychain.set("to_be_deleted", forKey: key)
        #expect(CDUntappdKeychain.delete(forKey: key) == true)
        #expect(CDUntappdKeychain.string(forKey: key) == nil)
    }

    @Test
    func deleteOnMissingKeySucceeds() {
        let key = uniqueKey()
        let result = CDUntappdKeychain.delete(forKey: key)
        #expect(result == true)
    }
}
