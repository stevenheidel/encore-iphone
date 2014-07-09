//
//  NSUserDefaults+Encore.m
//  Encore
//
//  Created by Shimmy on 2013-07-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//  Note that the set functions don't synchronize automatically, since you may want to do several sets at once.

#import "NSUserDefaults+Encore.h"
#import <CoreLocation/CoreLocation.h>
#import "ECConstKeys.h"

static NSString* const KeyUserCity = @"user_city";
static NSString* const KeyUserID = @"user_id";
static NSString* const KeyWalkthroughShown = @"walkthrough_showen";
static NSString* const KeyLastSearchType = @"Last_Search_Type";
static NSString* const KeySearchCity = @"search_city";
static NSString* const KeyArtistAutocompletionsVersion = @"ArtistAutocompletionsVersion";
static NSString* const KeyFirstDetailPostsView = @"FirstDetailPostsView";
static NSString* const KeyLastSearchLatitude = @"last_search_latitude";
static NSString* const KeyLastSearchLongitude = @"last_search_longitude";
static NSString* const KeyLastSearchArea = @"last_search_area";
static NSString* const KeyLastSearchRadius = @"last_search_radius";

@implementation NSUserDefaults (Encore)
+(BOOL)shouldShowWalkthrough
{
    if([[NSUserDefaults standardUserDefaults] boolForKey:KeyWalkthroughShown]){
        return NO;
    }else{
        return YES;
    }
}
-(void)setWalkthoughFinished
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KeyWalkthroughShown];
}

+(NSString*) userName {
   return [[NSUserDefaults standardUserDefaults] stringForKey:KeyUsername];
}
+(void) setUsername: (NSString*) username {
   [[NSUserDefaults standardUserDefaults] setObject:username forKey:KeyUsername];
}

+(NSString*) userID {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KeyUserID];
}
+(void) setUserID: (NSString*) userID {
   [[NSUserDefaults standardUserDefaults] setObject:userID forKey:KeyUserID];
}

+(NSURL*) facebookProfileImageURL {
    return [[NSUserDefaults standardUserDefaults] URLForKey:KeyFacebookImageURL];
}
+(void) setFacebookProfileImageURL: (NSString*) url {
    [[NSUserDefaults standardUserDefaults] setURL: [NSURL URLWithString:url] forKey:KeyFacebookImageURL];
}

+(NSString*) userCity {
    return [[NSUserDefaults standardUserDefaults] stringForKey:KeyUserCity];
}
+(void) setUserCity: (NSString*) city {
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:KeyUserCity];
}

#pragma mark - Location
+(double) latitude {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:KeyLatitude];
}
+(double) longitude {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:KeyLongitude];
}

+(CLLocation*) userCoordinate {
    return [[CLLocation alloc] initWithLatitude:[NSUserDefaults latitude] longitude:[NSUserDefaults longitude]];
}
            
+(void) setLongitude:(double)longitude latitude: (double) latitude{
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:KeyLongitude];
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:KeyLatitude];
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
//    float retVal = [[NSUserDefaults standardUserDefaults] floatForKey:KeyLastSearchRadius];
//    if (retVal == 0.0f) { //defaults to 0 if nothing saved
//        return 1.0f;
//    }
//    return retVal;
    return 1.0f;
}

+(void) setLastSearchRadius: (float) searchRadius {
    [[NSUserDefaults standardUserDefaults] setFloat:searchRadius forKey:KeyLastSearchRadius];
}

+(NSString*) searchCity {
    NSString* city = [[NSUserDefaults standardUserDefaults] objectForKey:KeySearchCity];
//    if (city == nil) {
//        city = [NSUserDefaults userCity];
//    }
    return city;
}
+(void) setSearchCity: (NSString*) city {
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:KeySearchCity];
}
//save the geocoded string for reference
+(void) setLastSearchArea: (NSString*) area {
    [[NSUserDefaults standardUserDefaults] setObject:area forKey:KeyLastSearchArea];
}
+(NSString*) lastSearchArea {
    return [[NSUserDefaults standardUserDefaults] objectForKey:KeyLastSearchArea];
}

+(CLLocation*) lastSearchLocation {
    double latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:KeyLastSearchLatitude];
    double longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:KeyLastSearchLongitude];
    if (latitude == 0 || longitude == 0) {
        return [NSUserDefaults userCoordinate];
    }
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}

+(void) setLastSearchLocation: (CLLocation*) lastSearchLocation {
    [[NSUserDefaults standardUserDefaults] setDouble:lastSearchLocation.coordinate.latitude forKey:KeyLastSearchLatitude];
    [[NSUserDefaults standardUserDefaults] setDouble:lastSearchLocation.coordinate.longitude  forKey:KeyLastSearchLongitude];
}

+(ECSearchType) lastSearchType {
    return (ECSearchType)[[NSUserDefaults standardUserDefaults] integerForKey:KeyLastSearchType];
}

+(void) setLastSearchType:(ECSearchType)searchType {
    [[NSUserDefaults standardUserDefaults] setInteger:searchType forKey:KeyLastSearchType];
}

#pragma mark -
+(void) synchronize {
    if([[NSUserDefaults standardUserDefaults] synchronize]);
    else NSLog(@"User defaults failed to synchronize");
}

+(void) clearLoginDetails {
    [NSUserDefaults setUserID:nil];
    [NSUserDefaults setUsername:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBAccessTokenKey"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FBExpirationDateKey"];
}

//+(BOOL) postsLayout {
//    return [[NSUserDefaults standardUserDefaults] boolForKey:@"GridisSingleColumn"];
//}
//+(void) setPostsLayout: (BOOL) isSingleColumn {
//    [[NSUserDefaults standardUserDefaults] setBool:isSingleColumn forKey:@"GridisSingleColumn"];
//}

+(NSInteger) autocompletionsVersion {
    return [[NSUserDefaults standardUserDefaults] integerForKey:KeyArtistAutocompletionsVersion];
}
+(void) setAutocompletionsVersion: (NSInteger) version {
    [[NSUserDefaults standardUserDefaults] setInteger:version forKey:KeyArtistAutocompletionsVersion];
}

+(BOOL) firstDetailPostsView { //show details on posts the first time it appears so they know it's there
    return [[NSUserDefaults standardUserDefaults] boolForKey:KeyFirstDetailPostsView];
}

+(void) setFirstDetailPostsView: (BOOL) shown {
    [[NSUserDefaults standardUserDefaults] setBool:shown forKey:KeyFirstDetailPostsView];
}

+(void) registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{KeyArtistAutocompletionsVersion: @2}];
}
@end
