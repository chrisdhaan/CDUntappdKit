//
//  CDUntappdCategory.h
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import <Mantle/Mantle.h>

@interface CDUntappdCategory : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSString *name;
@property (assign, nonatomic, readonly, getter = isPrimary) BOOL primary;

@end
