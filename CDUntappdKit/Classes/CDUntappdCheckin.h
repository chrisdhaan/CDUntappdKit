//
//  CDUntappdCheckin.h
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import <Mantle/Mantle.h>
#import "CDUntappdBeer.h"
#import "CDUntappdBrewery.h"
#import "CDUntappdUser.h"
#import "CDUntappdVenue.h"

@interface CDUntappdCheckin : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSArray *badges;
@property (copy, nonatomic, readonly) CDUntappdBeer *beer;
@property (copy, nonatomic, readonly) CDUntappdBrewery *brewery;
@property (copy, nonatomic, readonly) NSString *checkinComment;
@property (copy, nonatomic, readonly) NSArray *comments;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (copy, nonatomic, readonly) NSArray *media;
@property (copy, nonatomic, readonly) NSNumber *ratingScore;
@property (copy, nonatomic, readonly) NSString *sourceAppName;
@property (copy, nonatomic, readonly) NSURL *sourceAppWebsite;
@property (copy, nonatomic, readonly) NSArray *toasts;
@property (copy, nonatomic, readonly) CDUntappdUser *user;
@property (copy, nonatomic, readonly) CDUntappdVenue *venue;

@end
