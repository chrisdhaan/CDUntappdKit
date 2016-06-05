//
//  CDUntappdAPIClient.m
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import "CDUntappdAPIClient.h"
#import "CDUntappdModels.h"

@implementation CDUntappdAPIClient

+ (Class)errorModelClass {
    return [NSObject class];
}

+ (NSDictionary *)responseClassesByResourcePath {
    return @{
             };
    
}

+ (NSDictionary *)modelClassesByResourcePath {
    return @{
             @"checkin/recent":     [CDUntappdCheckin class],
             @"user/checkins**":    [CDUntappdCheckin class],
             @"thepub/local":       [CDUntappdUser class],
             @"venue/checkins**":   [CDUntappdCheckin class],
             @"beer/checkins**":    [CDUntappdCheckin class],
             @"brewery/checkins**": [CDUntappdCheckin class],
             @"notifications":      [CDUntappdNotification class],
//             @"user/info**":
//             @"user/wishlist**"
//             @"user/friends**"
             @"user/badges**":      [CDUntappdBadge class],
//             @"user/beers**"
//             @"brewery/info**"
//             @"beer/info**"
//             @"venue/info**"
             @"search/beer":        [CDUntappdBeer class],
             @"search/brewery":     [CDUntappdBrewery class]
             };
}

@end
