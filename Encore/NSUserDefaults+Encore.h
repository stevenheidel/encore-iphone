//
//  NSUserDefaults+Encore.h
//  Encore
//
//  Created by Shimmy on 2013-07-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
@interface NSUserDefaults (Encore)
+(NSString*) userName;
+(void) setUsername: (NSString*) username;

+(NSString*) userID;
+(void) setUserID: (NSString*) userID;

+(NSURL*) facebookProfileImageURL;
+(void) setFacebookProfileImageURL: (NSString*) url;

+(NSString*) userCity;
+(void) setUserCity: (NSString*) city;
+(double) latitude;
+(double) longitude;

+(void) setLongitude:(double)longitude latitude: (double) latitude;

+(int) lastSearchRadius;
+(void) setLastSearchRadius: (NSInteger) searchRadius;

+(NSString*) lastSearchLocation;
+(void) setLastSearchLocation: (NSString*) lastSearchLocation;
+(void) synchronize;
@end
