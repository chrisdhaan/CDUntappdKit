//
//  CDUntappdToast.h
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import <Mantle/Mantle.h>
#import "CDUntappdUser.h"

@interface CDUntappdToast : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) CDUntappdUser *user;
@property (assign, nonatomic, readonly, getter = isLikeOwner) BOOL likeOwner;
@property (copy, nonatomic, readonly) NSDate *createdAt;

@end
