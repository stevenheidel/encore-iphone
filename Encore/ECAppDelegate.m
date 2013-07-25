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
#import "ECFacebookManger.h"

#import "ECJSONPoster.h"

#import "ATConnect.h"
#import "ATAppRatingFlow.h"
#import "defines.h"

#import "UIFont+Encore.h"
#import "NSUserDefaults+Encore.h"
#import "MBProgressHUD.h"

#import "TestFlight.h"

#import "AFNetworking.h"

#import "Staging.h"

@implementation ECAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self startAnalytics];
    
    //  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //  Override point for customization after application launch.
    
    self.navigationController = (UINavigationController*)self.window.rootViewController;
    self.mainViewController = (ECNewMainViewController*)[[self.navigationController viewControllers] objectAtIndex:0];
    
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0.0f,1.0f)],UITextAttributeTextShadowOffset, [UIFont heroFontWithSize:24.0f], UITextAttributeFont, nil]];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
   
    if (![self isLoggedIn])
        [self showLoginView:NO];
    else
        [self setUpLocationManager];
    
    return YES;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [[ECFacebookManger sharedFacebookManger] handleOpenURL:url];
}

-(void) startAnalytics
{
    [Flurry setDebugLogEnabled:FLURRY_LOGGING];
    [Flurry setAppVersion:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
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


#pragma mark - Login management


- (void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"Delegate fbDidNotLogin");
}
- (void)fetchUserinfo
{
    //Get user's facebook data
    [[ECFacebookManger sharedFacebookManger] fetchUserInformation:^(NSDictionary *user) {
        if(user)
        {
            //Post to Encore server
            [ECJSONPoster postUser:user completion:^(NSDictionary *response) {
                    NSURL* defaultURL = [NSUserDefaults facebookProfileImageURL];
                    if (!defaultURL || ![defaultURL isEqual:[response objectForKey:@"facebook_image_url"]]) {
                        [NSUserDefaults setFacebookProfileImageURL:[response objectForKey:@"facebook_image_url"]]; //expecting a string -- converts to URL inside nsuserdefaults
                        [NSUserDefaults synchronize];
                    }
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [self.hud hide:YES];
                        [self setUpLocationManager];

                }];
            }];
            [self saveUserInfoToDefaults:user];
        }else{
            //TODO: error message
             [self.hud hide:YES];
        }
        
    }];
    
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


-(void)beginFacebookAuthorization
{
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];

    [[ECFacebookManger sharedFacebookManger] loginUserWithCompletionHandler:^(NSError* error) {
        if(error)
            [self handleAuthError:error];
        else
            [self fetchUserinfo];
        
    }];
}
- (void)logout
{
    if(!self.loginViewController) {
        self.loginViewController = [[ECLoginViewController alloc] init];
    }
    [self.window.rootViewController presentViewController:self.loginViewController animated:YES completion:nil];
    [[ECFacebookManger sharedFacebookManger] logout];
    [NSUserDefaults clearLoginDetails];
}

- (void)handleAuthError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    [self.hud hide:YES];
    
    if (error.fberrorShouldNotifyUser) {
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}
-(void) showLoginHUD {
    if(!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithView:self.loginViewController.view];
        [self.loginViewController.view addSubview:self.hud];
    }
    [self.hud show:YES];
}
#pragma mark - Login management

-(BOOL) isLoggedIn
{
    return [[ECFacebookManger sharedFacebookManger] isLoggedIn];
}

-(void) loginLater {
    [self setUpLocationManager];

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
        self.loginViewController = [[ECLoginViewController alloc]
                                                      initWithNibName:@"ECLoginViewController"
                                                      bundle:nil];
        self.loginViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [topViewController presentViewController:self.loginViewController animated:animated completion:nil];
    } else {
        self.loginViewController = (ECLoginViewController*)modalViewController;
        [self.loginViewController loginFailed];
    }
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
            [[NSNotificationCenter defaultCenter] postNotificationName:ECLocationAcquiredNotification object:nil];

        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error domain] == kCLErrorDomain) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ECLocationFailedNotification object:nil];
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
    [[ECFacebookManger sharedFacebookManger] handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];

    [Flurry logEvent:@"Application_Will_Terminate"];
    [NSUserDefaults setLastSearchType:self.mainViewController.currentSearchType];
    [NSUserDefaults setLastSearchRadius:self.mainViewController.currentSearchRadius];
    [NSUserDefaults synchronize];
}

@end
