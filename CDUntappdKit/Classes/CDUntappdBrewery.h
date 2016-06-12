//
//  CDUntappdBrewery.h
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import <Mantle/Mantle.h>

@interface CDUntappdBrewery : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSNumber *bid;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *slug;
@property (copy, nonatomic, readonly) NSURL *labelImage;
@property (copy, nonatomic, readonly) NSString *country;
@property (copy, nonatomic, readonly) NSString *twitterIdentifier;
@property (copy, nonatomic, readonly) NSURL *facebookURL;
@property (copy, nonatomic, readonly) NSURL *instagramURL;
@property (copy, nonatomic, readonly) NSURL *websiteURL;
@property (copy, nonatomic, readonly) NSString *city;
@property (copy, nonatomic, readonly) NSString *state;
@property (copy, nonatomic, readonly) NSNumber *latitude;
@property (copy, nonatomic, readonly) NSNumber *longitude;
@property (assign, nonatomic, readonly, getter = isActive) BOOL active;

//@property (copy, nonatomic, readonly) NSString *locationDisplay;
//@property (copy, nonatomic, readonly) NSDictionary *claimedStatus;
//@property (copy, nonatomic, readonly) NSNumber *beerCount;
//@property (copy, nonatomic, readonly) NSString *breweryType;
//@property (copy, nonatomic, readonly) NSString *streetAddress;
//@property (copy, nonatomic, readonly) NSNumber *ratingCount;
//@property (copy, nonatomic, readonly) NSNumber *ratingScore;
//@property (copy, nonatomic, readonly) NSArray *owners;
//@property (copy, nonatomic, readonly) NSString *breweryDescription;
//@property (copy, nonatomic, readonly) NSNumber *totalCount;
//@property (copy, nonatomic, readonly) NSNumber *uniqueCount;
//@property (copy, nonatomic, readonly) NSNumber *monthlyCount;
//@property (copy, nonatomic, readonly) NSNumber *weeklyCount;
//@property (copy, nonatomic, readonly) NSNumber *userCount;
//@property (copy, nonatomic, readonly) NSArray *media;
//@property (copy, nonatomic, readonly) NSArray *checkins;
//@property (copy, nonatomic, readonly) NSArray *beers;

@end
