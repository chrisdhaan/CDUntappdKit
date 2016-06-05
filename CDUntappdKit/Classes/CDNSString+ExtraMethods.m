//
//  CDNSString+ExtraMethods.m
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import "CDNSString+ExtraMethods.h"

@implementation NSString (ExtraMethods)

+ (NSString *)stringFromBool:(BOOL)value {
    return [NSString stringWithFormat:@"%@", value ? @"true" : @"false"];
}

@end