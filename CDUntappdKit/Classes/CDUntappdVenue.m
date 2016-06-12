//
//  CDUntappdVenue.m
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import "CDUntappdVenue.h"

@implementation CDUntappdVenue

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               @"vid":                      @0,
                               @"name":                     @"",
                               @"primaryCategory":          @"",
                               @"parentCategoryIdentifier": @"",
                               @"categories":               [NSArray new],
                               @"streetAddress":            @"",
                               @"city":                     @"",
                               @"state":                    @"",
                               @"country":                  @"",
                               @"latitude":                 @0.0,
                               @"longitude":                @0.0,
                               @"twitterIdentifier":        @"",
                               @"venueURL":                 [NSURL URLWithString:@""],
                               @"publicVenue":              @NO,
                               @"foursquareIdentifier":     @"",
                               @"foursquareURL":            [NSURL URLWithString:@""],
                               @"venueIconSmallURL":        [NSURL URLWithString:@""],
                               @"venueIconMediumURL":       [NSURL URLWithString:@""],
                               @"venueIconLargeURL":        [NSURL URLWithString:@""]
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"vid":                        @"venue_id",
             @"name":                       @"venue_name",
             @"primaryCategory":            @"primary_category",
             @"parentCategoryIdentifier":   @"parent_category_id",
             @"categories":                 @"categories",
             @"streetAddress":              @"location.venue_address",
             @"city":                       @"location.venue_city",
             @"state":                      @"location.venue_state",
             @"country":                    @"location.venue_country",
             @"latitude":                   @"location.lat",
             @"longitude":                  @"location.lng",
             @"twitterIdentifier":          @"contact.twitter",
             @"venueURL":                   @"contact.venue_url",
             @"publicVenue":                @"public_venue",
             @"foursquareIdentifier":       @"foursquare.foursquare_id",
             @"foursquareURL":              @"foursquare.foursquare_url",
             @"venueIconSmallURL":          @"venue_icon.sm",
             @"venueIconMediumURL":         @"venue_icon.md",
             @"venueIconLargeURL":          @"venue_icon.lg"
             };
}

+ (NSValueTransformer *)venueURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)foursqsuareURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)venueIconSmallURLJSONTransformer {
    
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}
+ (NSValueTransformer *)venueIconMediumURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)venueIconLargeURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
