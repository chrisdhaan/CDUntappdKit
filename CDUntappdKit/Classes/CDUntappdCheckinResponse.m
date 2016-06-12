//
//  CDUntappdCheckinResponse.m
//  Pods
//
//  Created by Christopher de Haan on 6/12/16.
//
//

#import "CDUntappdCheckinResponse.h"

@implementation CDUntappdCheckinResponse

+ (NSString *)resultKeyPathForJSONDictionary:(NSDictionary *)JSONDictionary {
    return @"checkins.items";
}

@end
