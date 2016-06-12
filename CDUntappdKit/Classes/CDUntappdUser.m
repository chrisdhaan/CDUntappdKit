//
//  CDUntappdUser.m
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import "CDUntappdUser.h"

@implementation CDUntappdUser

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               @"uid":                  @0,
                               @"userName":             @"",
                               @"firstName":            @"",
                               @"lastName":             @"",
                               @"location":             @"",
                               @"supporter":            @NO,
                               @"url":                  [NSURL URLWithString:@""],
                               @"bio":                  @"",
                               @"relationship":         @"",
                               @"userAvatar":           [NSURL URLWithString:@""],
                               @"privateUser":          @NO,
                               @"foursquareIdentifier": @"",
                               @"twitterIdentifier":    @"",
                               @"facebookIdentifier":   @"",
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"uid":                    @"uid",
             @"userName":               @"user_name",
             @"firstName":              @"first_name",
             @"lastName":               @"last_name",
             @"location":               @"location",
             @"supporter":              @"is_supporter",
             @"url":                    @"url",
             @"bio":                    @"bio",
             @"relationship":           @"relationship",
             @"userAvatar":             @"user_avatar",
             @"privateUser":            @"is_private",
             @"foursquareIdentifier":   @"contact.foursquare",
             @"twitterIdentifier":      @"contact.twitter",
             @"facebookIdentifier":     @"contact.facebook"
             };
}

+ (NSValueTransformer *)urlJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)userAvatarJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

- (NSString *)fullName {
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
