//
//  CDUntappdToast.m
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import "CDUntappdToast.h"

@implementation CDUntappdToast

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
