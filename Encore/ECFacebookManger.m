//
//  ECFacebookManger.m
//  Encore
//
//  Created by Mohamed Fouad on 7/24/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECFacebookManger.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation ECFacebookManger
+(ECFacebookManger *)sharedFacebookManger
{
    static ECFacebookManger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ECFacebookManger alloc] init];
    });
    return sharedInstance;
}

- (BOOL)loginUserWithCompletionHandler:(void (^)(NSError* error))handler
{
    BOOL isReturningUser = [FBSession openActiveSessionWithReadPermissions:[NSArray arrayWithObjects:@"basic_info",@"user_birthday",@"email",nil]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,FBSessionState state,NSError *error)
     {
         switch (state)
         {
             case FBSessionStateOpen:
                 break;
             case FBSessionStateClosed:
                 [Flurry logEvent:@"FBSessionClosed"];
                 break;
             case FBSessionStateClosedLoginFailed:
                 [Flurry logEvent:@"FBSessionStateClosedLoginFailed"];
                 [[FBSession activeSession] closeAndClearTokenInformation];
                 break;
             default:
                 break;
         }
         handler(error);
     }];
    
    return isReturningUser;
}
- (void)logout
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[FBSession activeSession] close];
    [FBSession  setActiveSession:nil];
}

- (void)fetchUserInformation:(void (^)(NSDictionary *))handler
{
    if([[FBSession activeSession] isOpen])
    {
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary <FBGraphUser> *user, NSError *error)
         {
             if(error == nil)
             {
                 handler(user);
             }else
             {
                 NSLog(@"ECAppDelegate Facebook request error: %@",error.debugDescription);
                 [Flurry logEvent:@"Facebook_Request_Error" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:error.debugDescription,@"error", nil]];
                 
                 handler(nil);
             }
         }];
    }
}
- (NSString *)accessToken
{
    return [[[FBSession activeSession] accessTokenData] accessToken];
}
- (NSDate *)expirationDate
{
    return [[[FBSession activeSession] accessTokenData] expirationDate];
}
- (BOOL)isLoggedIn
{
    if( [[FBSession activeSession] state] == FBSessionStateCreatedTokenLoaded || [[FBSession activeSession] state] == FBSessionStateOpen )
        return YES;
    else
         return NO;
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [[FBSession activeSession] handleOpenURL:url];
}
- (void)handleDidBecomeActive
{
    [[FBSession activeSession] handleDidBecomeActive];
}

@end
