//
//  CDUntappdNotification.h
//  Pods
//
//  Created by Christopher de Haan on 6/5/16.
//
//

#import <Mantle/Mantle.h>
#import "CDUntappdBeer.h"
#import "CDUntappdBrewery.h"

@interface CDUntappdNotification : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) CDUntappdBeer *beer;
@property (copy, nonatomic, readonly) CDUntappdBrewery *brewery;

@end
