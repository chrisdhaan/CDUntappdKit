//
//  CDUntappdBeer.h
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import <Mantle/Mantle.h>
#import "CDUntappdBrewery.h"

typedef NS_ENUM(NSInteger, CDUntappdBeerDistributionKind) {
    CDUntappdBeerDistributionKindUnknown,
    CDUntappdBeerDistributionKindMacro,
    CDUntappdBeerDistributionKindMicro
};

@interface CDUntappdBeer : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSNumber *bid;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSURL *labelURL;
@property (copy, nonatomic, readonly) NSString *style;
@property (copy, nonatomic, readonly) NSNumber *alcoholByVolume;
@property (copy, nonatomic, readonly) NSNumber *authorRating;
@property (assign, nonatomic, readonly, getter = isOnWishList) BOOL onWishList;
@property (assign, nonatomic, readonly, getter = isActive) BOOL active;

//@property (assign, nonatomic, readonly) CDUntappdBeerDistributionKind distributionKind;
//@property (copy, nonatomic, readonly) CDUntappdBrewery *brewery;
//@property (assign, nonatomic, readonly, getter = hasHad) BOOL had;
//@property (copy, nonatomic, readonly) NSNumber *totalCount;
//@property (copy, nonatomic, readonly) NSNumber *yourCount;
//@property (copy, nonatomic, readonly) NSString *slug;
//@property (assign, nonatomic, readonly, getter = isHomebrew) BOOL homebrew;
//@property (copy, nonatomic, readonly) NSDate *createdAt;
//@property (copy, nonatomic, readonly) NSNumber *ratingScore;
//@property (copy, nonatomic, readonly) NSNumber *ratingCount;
//@property (copy, nonatomic, readonly) NSNumber *monthlyCount;
//@property (copy, nonatomic, readonly) NSNumber *userCount;
//@property (copy, nonatomic, readonly) NSNumber *totalUserCount;
//@property (copy, nonatomic, readonly) NSArray *media;
//@property (copy, nonatomic, readonly) NSArray *checkins;

@end
