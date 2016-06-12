//
//  CDUntappdBrewery.m
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import "CDUntappdBrewery.h"

@implementation CDUntappdBrewery

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               @"bid":              @0,
                               @"name":             @"",
                               @"slug":             @"",
                               @"labelImage":       [NSURL URLWithString:@""],
                               @"country":          @"",
                               @"twitterIdentifier":@"",
                               @"facebookURL":      [NSURL URLWithString:@""],
                               @"instagramURL":     [NSURL URLWithString:@""],
                               @"websiteURL":       [NSURL URLWithString:@""],
                               @"city":             @"",
                               @"state":            @"",
                               @"latitude":         @0.0,
                               @"longitude":        @0.0,
                               @"active":           @NO,
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"bid":                @"brewery_id",
             @"name":               @"brewery_name",
             @"slug":               @"brewery_slug",
             @"labelImage":         @"brewery_label",
             @"country":            @"country_name",
             @"twitterIdentifier":  @"contact.twitter",
             @"facebookURL":        @"contact.facebook",
             @"instagramURL":       @"contact.instagram",
             @"websiteURL":         @"contact.url",
             @"city":               @"location.brewery_city",
             @"state":              @"location.brewery_state",
             @"latitude":           @"location.lat",
             @"longitude":          @"location.lng",
             @"active":             @"brewery_active"
             };
}

+ (NSValueTransformer *)labelImageJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)facebookURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)instagramURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)websiteURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
