//
//  CDUntappdPhoto.h
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import <Mantle/Mantle.h>

@interface CDUntappdPhoto : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSURL *smallPhoto;
@property (copy, nonatomic, readonly) NSURL *mediumPhoto;
@property (copy, nonatomic, readonly) NSURL *largePhoto;
@property (copy, nonatomic, readonly) NSURL *originalPhoto;

@end
