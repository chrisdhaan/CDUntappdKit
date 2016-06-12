//
//  CDUntappdUser.h
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import <Mantle/Mantle.h>

@interface CDUntappdUser : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSNumber *uid;
@property (copy, nonatomic, readonly) NSString *userName;
@property (copy, nonatomic, readonly) NSString *firstName;
@property (copy, nonatomic, readonly) NSString *lastName;
@property (copy, nonatomic, readonly) NSString *location;
@property (assign, nonatomic, readonly, getter = isSupporter) BOOL supporter;
@property (copy, nonatomic, readonly) NSURL *url;
@property (copy, nonatomic, readonly) NSString *bio;
@property (copy, nonatomic, readonly) NSString *relationship;
@property (copy, nonatomic, readonly) NSURL *userAvatar;
@property (assign, nonatomic, readonly, getter = isPrivateUser) BOOL privateUser;
@property (copy, nonatomic, readonly) NSString *foursquareIdentifier;
@property (copy, nonatomic, readonly) NSString *twitterIdentifier;
@property (copy, nonatomic, readonly) NSString *facebookIdentifier;

- (NSString *)fullName;

@end
