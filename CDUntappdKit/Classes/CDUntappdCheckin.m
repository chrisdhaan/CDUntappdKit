//
//  CDUntappdCheckin.m
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import "CDUntappdCheckin.h"
#import "CDUntappdBadge.h"

@implementation CDUntappdCheckin

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               @"cid":              @0,
                               @"createdAt":        [NSDate new],
                               @"checkinComment":   @"",
                               @"ratingScore":      @0,
                               @"user":             [CDUntappdUser new],
                               @"beer":             [CDUntappdBeer new],
                               @"brewery":          [CDUntappdBrewery new],
                               @"venue":            [CDUntappdVenue new],
                               @"comments":         [NSArray new],
                               @"toasts":           [NSArray new],
                               @"media":            [NSArray new],
                               @"sourceAppName":    @"",
                               @"sourceAppWebsite": [NSURL URLWithString:@""],
                               @"badges":           [NSArray new],
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cid":                @"checkin_id",
             @"createdAt":          @"created_at",
             @"checkinComment":     @"checkin_comment",
             @"ratingScore":        @"rating_score",
             @"user":               @"user",
             @"beer":               @"beer",
             @"brewery":            @"brewery",
             @"venue":              @"venue",
             @"comments":           @"comments.items",
             @"toasts":             @"toasts.items",
             @"media":              @"media.items",
             @"sourceAppName":      @"source.app_name",
             @"sourceAppWebsite":   @"source.app_website",
             @"badges":             @"badges.items"
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

+ (NSValueTransformer *)userJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[CDUntappdUser class]];
}

+ (NSValueTransformer *)beerJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[CDUntappdBeer class]];
}

+ (NSValueTransformer *)breweryJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[CDUntappdBrewery class]];
}

+ (NSValueTransformer *)venueJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[CDUntappdVenue class]];
}

+ (NSValueTransformer *)sourceAppWebsiteJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)badgesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[CDUntappdBadge class]];
}

@end
