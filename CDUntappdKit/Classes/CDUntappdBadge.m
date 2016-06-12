//
//  CDUntappdBadge.m
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import "CDUntappdBadge.h"

@implementation CDUntappdBadge

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               @"bid":                  @0,
                               @"userBadgeIdentifier":  @0,
                               @"name":                 @"",
                               @"badgeDescription":     @"",
                               @"createdAt":            [NSDate date],
                               @"imageSmallURL":        [NSURL URLWithString:@""],
                               @"imageMediumURL":       [NSURL URLWithString:@""],
                               @"imageLargeURL":        [NSURL URLWithString:@""]
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"bid":                @"badge_id",
             @"userBadgeIdentifier":@"user_badge_id",
             @"name":               @"badge_name",
             @"badgeDescription":   @"badge_description",
             @"createdAt":          @"created_at",
             @"imageSmallURL":      @"badge_image.sm",
             @"imageMediumURL":     @"badge_image.md",
             @"imageLargeURL":      @"badge_image.lg"
             };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^(NSNumber *dateNumber, BOOL *success, NSError *__autoreleasing *error) {
        return [NSDate dateWithTimeIntervalSince1970:[dateNumber doubleValue]];
    } reverseBlock:^(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        NSTimeInterval timeInterval = [date timeIntervalSince1970];
        return [NSNumber numberWithDouble:timeInterval];
    }];
}

+ (NSValueTransformer *)imageSmallURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)imageMediumURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)imageLargeURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
