//
//  NSUserDefaults+Encore.h
//  Encore
//
//  Created by Shimmy on 2013-07-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

@class CLLocation;
#import <Foundation/Foundation.h>

#import "ECSearchType.h"

@interface NSUserDefaults (Encore)
+(BOOL)shouldShowWalkthrough;
-(void)setWalkthoughFinished;

+(NSString*) userName;
+(void) setUsername: (NSString*) username;

+(NSString*) userID;
+(void) setUserID: (NSString*) userID;

+(NSURL*) facebookProfileImageURL;
+(void) setFacebookProfileImageURL: (NSString*) url;

+(NSString*) userCity;
+(void) setUserCity: (NSString*) city;
+(CLLocation*) userCoordinate;
+(void) setUserCoordinate:(CLLocation*) location;


+(float) lastSearchRadius;
+(void) setLastSearchRadius: (float) searchRadius;
+(NSString*) lastSearchArea;
+(void) setLastSearchArea: (NSString*) area;
+(NSString*) searchCity;
+(void) setSearchCity: (NSString*) city;
+(CLLocation*) lastSearchLocation;
+(void) setLastSearchLocation: (CLLocation*) lastSearchLocation;

+(ECSearchType) lastSearchType;
+(void) setLastSearchType: (ECSearchType) searchType;

+(void) synchronize;

+(void) clearLoginDetails;

//+(BOOL) postsLayout;
//+(void) setPostsLayout: (BOOL) isSingleColumn;
@end
