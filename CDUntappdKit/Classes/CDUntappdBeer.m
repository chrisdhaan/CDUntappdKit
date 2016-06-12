//
//  CDUntappdBeer.m
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import "CDUntappdBeer.h"

@implementation CDUntappdBeer

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               @"bid":              @0,
                               @"name":             @"",
                               @"labelURL":         [NSURL URLWithString:@""],
                               @"style":            @"",
                               @"alcoholByVolume":  @0,
                               @"authorRating":     @0,
                               @"onWishList":       @NO,
                               @"active":           @NO
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"bid":                @"bid",
             @"name":               @"beer_name",
             @"labelURL":           @"beer_label",
             @"style":              @"beer_style",
             @"alcoholByVolume":    @"beer_abv",
             @"authorRating":       @"auth_rating",
             @"onWishList":         @"wish_list",
             @"active":             @"beer_active"
             };
}

+ (NSValueTransformer *)labelURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
