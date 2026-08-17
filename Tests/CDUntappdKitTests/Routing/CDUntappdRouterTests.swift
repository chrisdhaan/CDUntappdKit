//
//  CDUntappdRouterTests.swift
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

@Suite("CDUntappdRouter Tests")
struct CDUntappdRouterTests {

    @Test
    func userInfoRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userInfo(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func userInfoRouteContainsUsername() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userInfo(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/info/testuser") == true)
    }

    @Test
    func userInfoRouteContainsCompactParameter() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test", "compact": "true"]
        let request = try CDUntappdRouter.userInfo(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.query?.contains("compact=true") == true)
    }

    @Test
    func userInfoRouteWithoutUsernameConstructsPath() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userInfo(username: nil, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/info") == true)
    }

    @Test
    func userWishListRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userWishList(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func userWishListRouteContainsUsername() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userWishList(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/wishlist/testuser") == true)
    }

    @Test
    func userWishListRouteContainsSortParameter() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test", "sort": "highest_abv"]
        let request = try CDUntappdRouter.userWishList(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.query?.contains("sort=highest_abv") == true)
    }

    @Test
    func userFriendsRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userFriends(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func userFriendsRouteContainsUsername() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userFriends(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/friends/testuser") == true)
    }

    @Test
    func userBadgesRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userBadges(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func userBeersRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userBeers(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func breweryInfoRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.breweryInfo(breweryId: 123, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func breweryInfoRouteContainsBreweryId() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.breweryInfo(breweryId: 123, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("brewery/info/123") == true)
    }

    @Test
    func beerInfoRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.beerInfo(bid: 456, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func beerInfoRouteContainsBeerId() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.beerInfo(bid: 456, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("beer/info/456") == true)
    }

    @Test
    func venueInfoRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.venueInfo(venueId: 789, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func venueInfoRouteContainsVenueId() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.venueInfo(venueId: 789, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("venue/info/789") == true)
    }

    @Test
    func beerSearchRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.beerSearch(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func beerSearchRouteContainsPath() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.beerSearch(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("search/beer") == true)
    }

    @Test
    func brewerySearchRouteUsesGET() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.brewerySearch(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func brewerySearchRouteContainsPath() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.brewerySearch(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("search/brewery") == true)
    }

    @Test
    func activityFeedRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.activityFeed(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func activityFeedRouteContainsPath() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.activityFeed(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("checkin/recent") == true)
    }

    @Test
    func userActivityFeedRouteContainsUsername() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.userActivityFeed(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/checkins/testuser") == true)
    }

    @Test
    func userActivityFeedRouteWithoutUsernameConstructsPath() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.userActivityFeed(username: nil, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/checkins") == true)
    }

    @Test
    func beerActivityFeedRouteContainsBeerId() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.beerActivityFeed(bid: 456, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("beer/checkins/456") == true)
    }

    @Test
    func breweryActivityFeedRouteContainsBreweryId() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.breweryActivityFeed(breweryId: 123, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("brewery/checkins/123") == true)
    }

    @Test
    func venueActivityFeedRouteContainsVenueId() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.venueActivityFeed(venueId: 789, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("venue/checkins/789") == true)
    }

    @Test
    func notificationsRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.notifications(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func notificationsRouteContainsPath() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.notifications(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("notifications") == true)
    }

    @Test
    func foursquareLookupRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.foursquareLookup(venueId: "4b0123456789", parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func foursquareLookupRouteContainsVenueId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.foursquareLookup(venueId: "4b0123456789", parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("venue/foursquare_lookup/4b0123456789") == true)
    }

    @Test
    func routeURLsUseUntappdAPIBase() throws {
        let parameters: [String: Any] = ["client_id": "test", "client_secret": "test"]
        let request = try CDUntappdRouter.userInfo(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("api.untappd.com/v4/") == true)
    }

    @Test
    func routesIncludeQueryParameters() throws {
        let parameters: [String: Any] = ["client_id": "id123", "client_secret": "secret456"]
        let request = try CDUntappdRouter.userInfo(username: "testuser", parameters: parameters).asURLRequest()
        #expect(request.url?.query != nil)
    }

    @Test
    func addCheckinRouteUsesPOST() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 123]
        let request = try CDUntappdRouter.addCheckin(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "POST")
    }

    @Test
    func addCheckinRouteContainsPath() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 123]
        let request = try CDUntappdRouter.addCheckin(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("checkin/add") == true)
    }

    @Test
    func addCheckinRouteEncodesParametersInBody() throws {
        let parameters: [String: Any] = ["bid": 123]
        let request = try CDUntappdRouter.addCheckin(parameters: parameters).asURLRequest()
        let bodyString = try #require(request.httpBody.flatMap { String(data: $0, encoding: .utf8) })
        #expect(bodyString == "bid=123")
    }

    @Test
    func toastRouteUsesPOST() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.toast(checkinId: 42, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "POST")
    }

    @Test
    func toastRouteContainsCheckinId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.toast(checkinId: 42, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("checkin/toast/42") == true)
    }

    @Test
    func addCommentRouteUsesPOST() throws {
        let parameters: [String: Any] = ["access_token": "test", "comment": "Cheers!"]
        let request = try CDUntappdRouter.addComment(checkinId: 42, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "POST")
    }

    @Test
    func addCommentRouteContainsCheckinId() throws {
        let parameters: [String: Any] = ["access_token": "test", "comment": "Cheers!"]
        let request = try CDUntappdRouter.addComment(checkinId: 42, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("checkin/addcomment/42") == true)
    }

    @Test
    func deleteCommentRouteUsesPOST() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.deleteComment(commentId: 99, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "POST")
    }

    @Test
    func deleteCommentRouteContainsCommentId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.deleteComment(commentId: 99, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("checkin/deletecomment/99") == true)
    }

    @Test
    func pendingFriendsRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.pendingFriends(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func pendingFriendsRouteContainsPath() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.pendingFriends(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/pending") == true)
    }

    @Test
    func addFriendRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.addFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func addFriendRouteContainsTargetId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.addFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("friend/request/7") == true)
    }

    @Test
    func removeFriendRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.removeFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func removeFriendRouteContainsTargetId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.removeFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("friend/remove/7") == true)
    }

    @Test
    func acceptFriendRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.acceptFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func acceptFriendRouteContainsTargetId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.acceptFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("friend/accept/7") == true)
    }

    @Test
    func rejectFriendRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.rejectFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func rejectFriendRouteContainsTargetId() throws {
        let parameters: [String: Any] = ["access_token": "test"]
        let request = try CDUntappdRouter.rejectFriend(targetId: 7, parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("friend/reject/7") == true)
    }

    @Test
    func addToWishListRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 55]
        let request = try CDUntappdRouter.addToWishList(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func addToWishListRouteContainsPath() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 55]
        let request = try CDUntappdRouter.addToWishList(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/wishlist/add") == true)
    }

    @Test
    func removeFromWishListRouteUsesGET() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 55]
        let request = try CDUntappdRouter.removeFromWishList(parameters: parameters).asURLRequest()
        #expect(request.httpMethod == "GET")
    }

    @Test
    func removeFromWishListRouteContainsPath() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 55]
        let request = try CDUntappdRouter.removeFromWishList(parameters: parameters).asURLRequest()
        #expect(request.url?.absoluteString.contains("user/wishlist/delete") == true)
    }

    @Test
    func addToWishListRouteContainsBidParameter() throws {
        let parameters: [String: Any] = ["access_token": "test", "bid": 55]
        let request = try CDUntappdRouter.addToWishList(parameters: parameters).asURLRequest()
        #expect(request.url?.query?.contains("bid=55") == true)
    }
}
