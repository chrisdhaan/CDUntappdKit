//
//  ParametersExtensionTests.swift
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

import Testing
import Foundation
@testable import CDUntappdKit

@Suite("Parameters Extension Tests")
struct ParametersExtensionTests {

    @Test
    func userInfoParametersWithCompactTrue() {
        let params = [String: Any].userInfoParameters(isCompact: true)
        #expect(params["compact"] as? String == "true")
    }

    @Test
    func userInfoParametersWithCompactFalse() {
        let params = [String: Any].userInfoParameters(isCompact: false)
        #expect(params["compact"] as? Bool == false)
    }

    @Test
    func userInfoParametersReturnsParameters() {
        let params = [String: Any].userInfoParameters(isCompact: true)
        #expect(params.isEmpty == false)
    }

    @Test
    func userWishListParametersWithAllValues() {
        let params = [String: Any].userWishListParameters(withOffset: 10, limit: 20,
                                                          sort: .highestABV)
        #expect(params["offset"] as? Int == 10)
        #expect(params["limit"] as? Int == 20)
        let sortValue = params["sort"] as? CDUntappdUserWishListSortType
        #expect(sortValue == .highestABV)
    }

    @Test
    func userWishListParametersWithNilOffset() {
        let params = [String: Any].userWishListParameters(withOffset: nil, limit: 20,
                                                          sort: .highestABV)
        #expect(params["offset"] == nil)
        #expect(params["limit"] as? Int == 20)
    }

    @Test
    func userWishListParametersWithNilLimit() {
        let params = [String: Any].userWishListParameters(withOffset: 10, limit: nil,
                                                          sort: .highestABV)
        #expect(params["offset"] as? Int == 10)
        #expect(params["limit"] == nil)
    }

    @Test
    func userWishListParametersWithNilSort() {
        let params = [String: Any].userWishListParameters(withOffset: 10, limit: 20,
                                                          sort: nil)
        #expect(params["offset"] as? Int == 10)
        #expect(params["limit"] as? Int == 20)
        #expect(params["sort"] == nil)
    }

    @Test
    func userWishListParametersWithAllNil() {
        let params = [String: Any].userWishListParameters(withOffset: nil, limit: nil,
                                                          sort: nil)
        #expect(params.isEmpty == true)
    }

    @Test
    func userFriendsParametersWithAllValues() {
        let params = [String: Any].userFriendsParameters(withOffset: 5, limit: 15)
        #expect(params["offset"] as? Int == 5)
        #expect(params["limit"] as? Int == 15)
    }

    @Test
    func userFriendsParametersWithNilOffset() {
        let params = [String: Any].userFriendsParameters(withOffset: nil, limit: 15)
        #expect(params["offset"] == nil)
        #expect(params["limit"] as? Int == 15)
    }

    @Test
    func userFriendsParametersWithNilLimit() {
        let params = [String: Any].userFriendsParameters(withOffset: 5, limit: nil)
        #expect(params["offset"] as? Int == 5)
        #expect(params["limit"] == nil)
    }

    @Test
    func userFriendsParametersWithAllNil() {
        let params = [String: Any].userFriendsParameters(withOffset: nil, limit: nil)
        #expect(params.isEmpty == true)
    }

    @Test
    func userFriendsParametersWithZeroOffset() {
        let params = [String: Any].userFriendsParameters(withOffset: 0, limit: 10)
        #expect(params["offset"] as? Int == 0)
    }
}
