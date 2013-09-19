//
//  NSUserDefaults+Encore.m
//  Encore
//
//  Created by Shimmy on 2013-07-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//  Note that the set functions don't synchronize automatically, since you may want to do several sets at once.

#import "NSUserDefaults+Encore.h"
#import <CoreLocation/CoreLocation.h>

@implementation NSUserDefaults (Encore)
+(BOOL)shouldShowWalkthrough
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"walkthrough_showen"]){
        return NO;
    }else{
        return YES;
    }
}
-(void)setWalkthoughFinished
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"walkthrough_showen"];
}

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

+(CLLocation*) userCoordinate {
    return [[CLLocation alloc] initWithLatitude:[NSUserDefaults latitude] longitude:[NSUserDefaults longitude]];
}
            
+(void) setLongitude:(double)longitude latitude: (double) latitude{
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:@"longitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:@"latitude"];
}

+(void) setUserCoordinate: (CLLocation*) location {
    if (location) {
        [NSUserDefaults setLongitude:location.coordinate.longitude latitude:location.coordinate.latitude];
    }
    else {
        [NSUserDefaults setLongitude:0 latitude:0];
    }
}

+(float) lastSearchRadius {
    float retVal = [[NSUserDefaults standardUserDefaults] floatForKey:@"last_search_radius"];
    if (retVal == 0.0f) { //defaults to 0 if nothing saved
        return 0.5f;
    }
    return retVal;
}

+(void) setLastSearchRadius: (float) searchRadius {
    [[NSUserDefaults standardUserDefaults] setFloat:searchRadius forKey:@"last_search_radius"];
}

+(NSString*) searchCity {
    NSString* city = [[NSUserDefaults standardUserDefaults] objectForKey:@"search_city"];
//    if (city == nil) {
//        city = [NSUserDefaults userCity];
//    }
    return city;
}
+(void) setSearchCity: (NSString*) city {
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:@"search_city"];
}
//save the geocoded string for reference
+(void) setLastSearchArea: (NSString*) area {
    [[NSUserDefaults standardUserDefaults] setObject:area forKey:@"last_search_area"];
}
+(NSString*) lastSearchArea {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"last_search_area"];
}

+(CLLocation*) lastSearchLocation {
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"last_search_latitude"];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"last_search_longitude"];
    if (latitude == 0 || longitude == 0) {
        return [NSUserDefaults userCoordinate];
    }
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

+(void) setLastSearchLocation: (CLLocation*) lastSearchLocation {
    [[NSUserDefaults standardUserDefaults] setDouble:lastSearchLocation.coordinate.latitude forKey:@"last_search_latitude"];
    [[NSUserDefaults standardUserDefaults] setDouble:lastSearchLocation.coordinate.longitude  forKey:@"last_search_longitude"];
}

+(ECSearchType) lastSearchType {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"Last_Search_Type"];
}

+(void) setLastSearchType:(ECSearchType)searchType {
    [[NSUserDefaults standardUserDefaults] setInteger:searchType forKey:@"Last_Search_Type"];
}

+(void) synchronize {
    if([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"User defaults synchronized successfully");
    }
    else NSLog(@"User defaults failed to synchronize");
}

+(void) clearLoginDetails {
    [NSUserDefaults setUserID:nil];
    [NSUserDefaults setUsername:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBExpirationDateKey"];
}
@end
