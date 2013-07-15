//
//  NSUserDefaults+Encore.m
//  Encore
//
//  Created by Shimmy on 2013-07-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSUserDefaults+Encore.h"
#import <CoreLocation/CoreLocation.h>

@implementation NSUserDefaults (Encore)
+(NSString*) userName {
   return [[NSUserDefaults standardUserDefaults] stringForKey:@"user_name"];
}
+(void) setUsername: (NSString*) username {
   [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"user_name"];
}

+(NSString*) userID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"user_id"];
}
+(void) setUserID: (NSString*) userID {
   [[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"user_id"];
}

+(NSURL*) facebookProfileImageURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:@"facebook_image_url"];
}
+(void) setFacebookProfileImageURL: (NSString*) url {
    [[NSUserDefaults standardUserDefaults] setURL: [NSURL URLWithString:url] forKey:@"facebook_image_url"];
}

+(NSString*) userCity {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"user_city"];
}
+(void) setUserCity: (NSString*) city {
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"user_city"];
}

#pragma mark - Location
+(double) latitude {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"latitude"];
}
+(double) longitude {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"longitude"];
}
+(void) setLongitude:(double)longitude latitude: (double) latitude{
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:@"longitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:@"latitude"];
}

+(NSInteger) lastSearchRadius {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"last_search_radius"];
}

+(void) setLastSearchRadius: (NSInteger) searchRadius {
    [[NSUserDefaults standardUserDefaults] setInteger:searchRadius forKey:@"last_search_radius"];
}

+(NSString*) lastSearchLocation {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"last_search_location"];
}

+(void) setLastSearchLocation: (NSString*) lastSearchLocation {
    [[NSUserDefaults standardUserDefaults] setObject:lastSearchLocation forKey:@"last_search_location"];
}

+(void) synchronize {
    if([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"User defaults synchronized successfully");
    }
    else NSLog(@"User defaults failed to synchronize");
}

@end
