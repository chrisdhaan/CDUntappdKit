//
//  CDUntappdBadge.h
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import <Mantle/Mantle.h>

@interface CDUntappdBadge : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSNumber *userBadgeIdentifier;
@property (copy, nonatomic, readonly) NSNumber *checkinIdentifier;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *badgeDescription;
@property (copy, nonatomic, readonly) NSString *hint;
@property (assign, nonatomic, readonly, getter = isActive) BOOL active;
@property (copy, nonatomic, readonly) NSDictionary *media;
@property (copy, nonatomic, readonly) NSDate *createdAt;
@property (assign, nonatomic, readonly, getter = isLevel) BOOL level;
@property (copy, nonatomic, readonly) NSArray *levels;

@end
