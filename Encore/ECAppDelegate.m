//
//  ECAppDelegate.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECAppDelegate.h"
#import "ECNewMainViewController.h"
#import "ECLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ECJSONPoster.h"

#import "ATConnect.h"
#import "ATAppRatingFlow.h"
#import "defines.h"

#import "UIFont+Encore.h"
#import "NSUserDefaults+Encore.h"

//#if IN_BETA
#import "TestFlight.h"
//#endif

#import "AFNetworking.h"

#import "Staging.h"

NSString *const ECSessionStateChangedNotification = @"com.encoretheapp.Encore:ECSessionStateChangedNotification";

@implementation ECAppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
//    // Facebook SDK * login flow *
//    // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
//    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
//        // Facebook SDK * App Linking *
//        // For simplicity, this sample will ignore the link if the session is already
//        // open but a more advanced app could support features like user switching.
//        if (call.accessTokenData) {
//            if ([FBSession activeSession].isOpen) {
//                NSLog(@"INFO: Ignoring app link because current session is open.");
//            }
//            else {
//                [self handleAppLink:call.accessTokenData];
//            }
//        }
//    }];

      return [self.facebook handleOpenURL:url];
}

-(void) startAnalytics {
    [Flurry setDebugLogEnabled:FLURRY_LOGGING];
    [Flurry setAppVersion:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]];
    [Flurry startSession:@"GM2TRR7TWT9DRX9N9PG9"];

    [Flurry setEventLoggingEnabled:YES];

    ATConnect * connection = [ATConnect sharedConnection];
    connection.apiKey = kApptentiveAPIKey;
    
    ATAppRatingFlow *sharedFlow = [ATAppRatingFlow sharedRatingFlow];
    sharedFlow.appID = kApptentiveAppID;
    
#if IN_BETA
        [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
        [TestFlight takeOff:@"019687e0-0d30-4959-bf90-f52ba008c834"];
#endif

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self startAnalytics];
    
//  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//  Override point for customization after application launch.
    
    self.navigationController = (UINavigationController*)self.window.rootViewController;
    self.mainViewController = (ECNewMainViewController*)[[self.navigationController viewControllers] objectAtIndex:0];
    
    [self setUpLocationManager];

    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0.0f,1.0f)],UITextAttributeTextShadowOffset, [UIFont heroFontWithSize:24.0f], UITextAttributeFont, nil]];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    
    self.facebook = [[Facebook alloc] initWithAppId:@"170378959802810" andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        self.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        self.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    // See if the app has a valid token for the current state.
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//        [self openSession];
//    } else {
//        // No, display the login page.
//        
//        [self showLoginView: NO];
//    }
    
    //TODO switchover to using Facebook object for connection based on KNFBFriendSelectorDemo
    // Intro screen, connect to Facebook
    
    if (![self.facebook isSessionValid]) {
        [self showLoginView:NO];
    }

    return YES;
}

- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Delegate fbDidNotLogin");
}
- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[self.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self.facebook requestWithGraphPath:@"me" andDelegate:self];
//    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error) {
//        if (error) {
//            NSLog(@"ECAppDelegate Facebook request error: %@",error.debugDescription);
//            [Flurry logEvent:@"Facebook_Request_Error" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:error.debugDescription,@"error", nil]];
//        }
//        else {
//            [ECJSONPoster postUser:(NSDictionary<FBGraphUser>*)user completion:^(NSDictionary *response) {
//                NSURL* defaultURL = [NSUserDefaults facebookProfileImageURL];
//                if (!defaultURL || ![defaultURL isEqual:[response objectForKey:@"facebook_image_url"]]) {
//                    [NSUserDefaults setFacebookProfileImageURL:[response objectForKey:@"facebook_image_url"]]; //expecting a string -- converts to URL inside nsuserdefaults
//                    [NSUserDefaults synchronize];
//                }
//                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//            }];
//            [self saveUserInfoToDefaults:(NSDictionary<FBGraphUser>*)user];
//
//        }
//    }];
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"ECAppDelegate Facebook request error: %@",error.debugDescription);
    [Flurry logEvent:@"Facebook_Request_Error" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:error.debugDescription,@"error", nil]];
}


- (void)request:(FBRequest *)request didLoad:(id)result {
    NSDictionary* user = result;
    [ECJSONPoster postUser:user completion:^(NSDictionary *response) {
        NSURL* defaultURL = [NSUserDefaults facebookProfileImageURL];
        if (!defaultURL || ![defaultURL isEqual:[response objectForKey:@"facebook_image_url"]]) {
            [NSUserDefaults setFacebookProfileImageURL:[response objectForKey:@"facebook_image_url"]]; //expecting a string -- converts to URL inside nsuserdefaults
            [NSUserDefaults synchronize];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self saveUserInfoToDefaults:user];
}


- (void)fbDidLogout {
    if(!self.loginViewController) {
        self.loginViewController = [[ECLoginViewController alloc] init];
    }
    [self.window.rootViewController presentViewController:self.loginViewController animated:YES completion:nil];
    [NSUserDefaults clearLoginDetails];
}
- (void)fbSessionInvalidated {}
- (void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"TOKEN EXTENDED");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}
-(void)beginFacebookAuthorization {
    [self.facebook authorize:[NSArray arrayWithObjects:@"basic_info",@"user_birthday",@"email", nil]];
}

#pragma mark - Login management
- (void) openSession {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}


- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error {

    
    switch (state) {
        case FBSessionStateOpen: {
            NSDictionary* params = [NSDictionary dictionaryWithObject:@"id,gender,name,username,age_range,birthday" forKey:@"fields"];
            FBRequest* request = [FBRequest requestWithGraphPath:@"me" parameters:params HTTPMethod:nil];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error){
                    [self loginCompletedWithUser:result];
                }
            }];
            break;
        }
        case FBSessionStateClosed: //no break on purpose
            
        case FBSessionStateClosedLoginFailed: {
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [self.navigationController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            [self showLoginView: YES];
            break;
        }
        default:{
            break;
        }
    }
    
    if (state == FBSessionStateClosed) {
        [Flurry logEvent:@"FBSessionClosed"];
    }
    else if (state == FBSessionStateClosedLoginFailed) {
        [Flurry logEvent:@"FBSessionStateClosedLoginFailed"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ECSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
-(BOOL) isLoggedIn {
    return [self.facebook isSessionValid];
}

-(void) loginLater {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
}
-(void) showLoginView: (BOOL) animated {
    UIViewController *topViewController = [self.navigationController topViewController];
    
    UIViewController *modalViewController = [topViewController presentedViewController];
    
    // If the login screen is not already displayed, display it. If the login screen is
    // displayed, then getting back here means the login in progress did not successfully
    // complete. In that case, notify the login view so it can update its UI appropriately.
    if (![modalViewController isKindOfClass:[ECLoginViewController class]]) {
        ECLoginViewController* loginViewController = [[ECLoginViewController alloc]
                                                      initWithNibName:@"ECLoginViewController"
                                                      bundle:nil];
        loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [topViewController presentViewController:loginViewController animated:animated completion:nil];
    } else {
        ECLoginViewController* loginViewController = (ECLoginViewController*)modalViewController;
        [loginViewController loginFailed];
    }
}

// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
//                                  [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}

-(void) loginCompletedWithUser:(NSDictionary <FBGraphUser>*) user {
    NSString* userid = user.id;
    NSLog(@"Logged in user with id: %@",userid);
    
    [ECJSONPoster postUser:user completion:^(NSDictionary *response) {
        NSURL* defaultURL = [NSUserDefaults facebookProfileImageURL];
        if (!defaultURL || ![defaultURL isEqual:[response objectForKey:@"facebook_image_url"]]) {
            [NSUserDefaults setFacebookProfileImageURL:[response objectForKey:@"facebook_image_url"]]; //expecting a string -- converts to URL inside nsuserdefaults
            [NSUserDefaults synchronize];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
    [self saveUserInfoToDefaults:user];
}

-(void) saveUserInfoToDefaults: (NSDictionary /*<FBGraphUser>*/ *) user {
    NSString* defaultID = [NSUserDefaults userID];

    NSString* userID = [user objectForKey: @"id"];
    if (!defaultID || ![defaultID isEqualToString:userID]) {
        [NSUserDefaults setUserID:userID];
    }
    else !defaultID ? NSLog(@"No default ID saved") : NSLog(@"No change in User ID. Defaults not changed");
    
    NSString* defaultName = [NSUserDefaults userName];
    NSString* userName = [user objectForKey:@"name"];
    if (!defaultName || ![defaultName isEqualToString:userName]) {
        [NSUserDefaults setUsername:userName];
    }
    
//    NSString* defaultCity = [NSUserDefaults userCity];
//    if(!defaultCity || ![defaultCity isEqualToString:userInfo.location.location.city]) {
//        [NSUserDefaults setUserCity:userInfo.location.location.city];
//    }
    
    [NSUserDefaults synchronize];
    

}

#pragma mark - location

-(void) setUpLocationManager {
    if(self.locationManager==nil){
        
        _locationManager = [CLLocationManager new];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter = 5000;
        self.locationManager=_locationManager;
    }
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //Ensure location update is recent
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        if(newLocation.horizontalAccuracy < 1000.0){
            //Ensure location is accurate to the nearest kilometer
            NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
            NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
            //turn off location services once we've gotten a good location
            [manager stopUpdatingLocation];
            [self saveLocationToUserDefaults:newLocation];
        }
    }
}

-(void) saveLocationToUserDefaults: (CLLocation *) location {
    double latitude = location.coordinate.latitude;
    double longitude = location.coordinate.longitude;
    [NSUserDefaults setUserCoordinate:location];
    [NSUserDefaults synchronize];
    
    [Flurry setLatitude:latitude longitude:longitude horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy];
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    self.isNavigating = NO;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.isNavigating = YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [Flurry logEvent:@"Application_Will_Resign_Active"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [NSUserDefaults setLastSearchType:self.mainViewController.currentSearchType];
    [NSUserDefaults setLastSearchRadius:self.mainViewController.currentSearchRadius];
    [NSUserDefaults synchronize];
    
    [Flurry logEvent:@"Application_Did_Enter_Background"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    [FBSession.activeSession handleDidBecomeActive];
    [self.facebook extendAccessTokenIfNeeded];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [Flurry logEvent:@"Application_Will_Terminate"];
    [NSUserDefaults setLastSearchType:self.mainViewController.currentSearchType];
    [NSUserDefaults setLastSearchRadius:self.mainViewController.currentSearchRadius];
    [NSUserDefaults synchronize];
}

@end
