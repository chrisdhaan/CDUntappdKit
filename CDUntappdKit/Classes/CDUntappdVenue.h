//
//  CDUntappdVenue.h
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import <Mantle/Mantle.h>

@interface CDUntappdVenue : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSArray *categories;
@property (copy, nonatomic, readonly) NSString *twitterIdentifier;
@property (copy, nonatomic, readonly) NSURL *venueURL;
@property (copy, nonatomic, readonly) NSString *foursquareIdentifier;
@property (copy, nonatomic, readonly) NSURL *foursquareURL;
@property (copy, nonatomic, readonly) NSNumber *latitude;
@property (copy, nonatomic, readonly) NSNumber *longitude;
@property (copy, nonatomic, readonly) NSString *streetAddress;
@property (copy, nonatomic, readonly) NSString *city;
@property (copy, nonatomic, readonly) NSString *state;
@property (copy, nonatomic, readonly) NSString *parentCategoryIdentifier;
@property (copy, nonatomic, readonly) NSString *primaryCategory;
@property (copy, nonatomic, readonly) NSURL *venueIconLargeURL;
@property (copy, nonatomic, readonly) NSURL *venueIconMediumURL;
@property (copy, nonatomic, readonly) NSURL *venueIconSmallURL;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSNumber *totalCount;
@property (copy, nonatomic, readonly) NSNumber *userCount;
@property (copy, nonatomic, readonly) NSNumber *totalUserCount;
@property (copy, nonatomic, readonly) NSArray *media;
@property (copy, nonatomic, readonly) NSArray *checkins;
@property (copy, nonatomic, readonly) NSArray *topBeers;

@end
