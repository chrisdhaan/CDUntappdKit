# ``CDUntappdKit``

A Swift wrapper for the Untappd API. Supports iOS, macOS, tvOS, watchOS, and visionOS.

## Overview

CDUntappdKit handles OAuth 2.0 authentication and authenticated API requests against the
Untappd REST API, decoding responses into strongly-typed Swift model structs.

## Topics

### Getting Started

- <doc:GettingStarted>

### Client

- ``CDUntappdAPIClient``
- ``CDUntappdOAuthClient``

### Configuration

- ``CDUntappdRetryConfiguration``
- ``CDUntappdCacheConfiguration``

### Interceptors

- ``CDUntappdEventMonitor``
- ``CDUntappdRequestAdapter``

### Errors

- ``CDUntappdKitError``

### Core Models

- ``CDUntappdUser``
- ``CDUntappdBeer``
- ``CDUntappdBeerItem``
- ``CDUntappdBrewery``
- ``CDUntappdVenue``
- ``CDUntappdCheckin``
- ``CDUntappdComment``
- ``CDUntappdWishList``
- ``CDUntappdWishListItem``
- ``CDUntappdFriend``
- ``CDUntappdBadge``
- ``CDUntappdStats``
- ``CDUntappdMedia``
- ``CDUntappdSource``
- ``CDUntappdCategory``
- ``CDUntappdContact``
- ``CDUntappdRecentBrew``
- ``CDUntappdSettings``
- ``CDUntappdNotification``
- ``CDUntappdMetadata``

### Response Types

- ``CDUntappdUserInfoResponse``
- ``CDUntappdUserWishListResponse``
- ``CDUntappdUserFriendsResponse``
- ``CDUntappdUserBadgesResponse``
- ``CDUntappdUserBeersResponse``
- ``CDUntappdBeerInfoResponse``
- ``CDUntappdBreweryInfoResponse``
- ``CDUntappdVenueInfoResponse``
- ``CDUntappdBeerSearchResponse``
- ``CDUntappdBrewerySearchResponse``
- ``CDUntappdActivityFeedResponse``
- ``CDUntappdNotificationsResponse``
- ``CDUntappdFoursquareLookupResponse``
- ``CDUntappdCheckinResponse``
- ``CDUntappdToastResponse``
- ``CDUntappdAddCommentResponse``
- ``CDUntappdPendingFriendsResponse``
- ``CDUntappdActionResultResponse``

### Routing

- ``CDUntappdRouter``
- ``CDUntappdOAuthRouter``

### Enumerations

- ``CDUntappdUserWishListSortType``
- ``CDUntappdBeerSearchSortType``
- ``CDUntappdUserBeersSortType``
