//
//  CDUntappdCategory.m
//  Pods
//
//  Created by Christopher de Haan on 6/4/16.
//
//

#import "CDUntappdCategory.h"

@implementation CDUntappdCategory

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    NSDictionary *defaults = @{
                               };
    dictionaryValue = [defaults mtl_dictionaryByAddingEntriesFromDictionary:dictionaryValue];
    return [super initWithDictionary:dictionaryValue error:error];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             };
}

@end
