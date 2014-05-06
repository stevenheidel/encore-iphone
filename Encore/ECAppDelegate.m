//
//  ECAppDelegate.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import <Tapjoy/Tapjoy.h>
#import <Crashlytics/Crashlytics.h>
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
#import "Reachability.h"
#import "ECWelcomeViewController.h"

@implementation ECAppDelegate


-(void) checkReachability {
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
//    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA  old, don't know why you wouldn't want to be reachable on that
    //suppose you don't want to use data
    
    reach.reachableOnWWAN = YES;
    
    
    // Here we set up a NSNotification observer. The Reachability that caused the notification
    // is passed in the object parameter
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    [reach startNotifier];
}

-(BOOL) connected {
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

-(void) reachabilityChanged: (NSNotification*) notification {
    Reachability* reach = (Reachability*)notification.object;
    if (reach.isReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            [self.unreachableIndicatorView removeFromSuperview];
        });
        
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UNREACHABLE!");
            [[UIApplication sharedApplication].keyWindow addSubview:self.unreachableIndicatorView];
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self.unreachableIndicatorView];
        });
    }
}
-(void) setupUnreachableIndicatorView {
    self.unreachableIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.window.frame.size.height-30, self.window.frame.size.width, 30)];
    [self.unreachableIndicatorView setBackgroundColor:[UIColor redColor]];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5, 7.5, self.window.frame.size.width, 15)];
    label.text = @"No Internet connection detected  ";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.unreachableIndicatorView addSubview:label];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Tapjoy requestTapjoyConnect:@"8a67e52a-3769-4ab5-bf9a-7984d94706d4" secretKey:@"CmtwVtjY6QnBL9y9qKLU" options:@{ TJC_OPTION_ENABLE_LOGGING : @(YES) } ];


    [self startAnalytics];
    [Crashlytics startWithAPIKey:@"c12b678409321970d5cec21099c268564caa15c1"];
    
    [self setupUnreachableIndicatorView];
    [self checkReachability];
    self.navigationController = (UINavigationController*)self.window.rootViewController;
    self.mainViewController = (ECNewMainViewController*)[[self.navigationController viewControllers] objectAtIndex:0];
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowColor = nil;
    shadow.shadowOffset = CGSizeMake(0, 0);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, shadow, NSShadowAttributeName, [UIFont heroFontWithSize:24.0f], NSFontAttributeName, nil]];
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    if([NSUserDefaults shouldShowWalkthrough] || TESTING_WALKTHROUGH){
        [self showWalktrhoughView];
    }else{
        [self setUpLocationManager];
        [Flurry setUserID:[NSUserDefaults userID]];
    }
   
//    if (![self isLoggedIn])
//        [self showLoginView:NO];
//    else {
//    }
    [self setupAutocompletionsFile];
    return YES;
}

-(void) setupAutocompletionsFile {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FirstLaunchEver_autocompletion"]) {
        NSArray* suggestions = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ArtistAutocomplete" ofType:@"plist"]];
        NSString *path = [[self applicationDocumentsDirectory].path stringByAppendingPathComponent:@"SavedAutocompletions.plist"];
        [suggestions writeToFile:path atomically:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"FirstLaunchEver_autocompletion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(NSURL *) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [[ECFacebookManger sharedFacebookManger] handleOpenURL:url];
}

-(void) startAnalytics
{
    
//#if DO_ANALYTICS
    [Flurry setDebugLogEnabled:FLURRY_LOGGING];
    [Flurry setAppVersion:[NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
    [Flurry startSession:@"GM2TRR7TWT9DRX9N9PG9"];

    [Flurry setEventLoggingEnabled:YES];

    ATConnect * connection = [ATConnect sharedConnection];
    connection.apiKey = kApptentiveAPIKey;
    
    ATAppRatingFlow *sharedFlow = [ATAppRatingFlow sharedRatingFlow];
    sharedFlow.appID = kApptentiveAppID;
//#endif 
    
#if IN_BETA
     //   [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
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
            [self saveUserInfoToDefaults:user];
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
                        
                        [self.mainViewController profileTapped];
                }];
                [[NSNotificationCenter defaultCenter] postNotificationName:ECLoginCompletedNotification object:nil];

                
            }];
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
//    if(!self.loginViewController) {
//        self.loginViewController = [[ECLoginViewController alloc] init];
//    }
//    [self.window.rootViewController presentViewController:self.loginViewController animated:YES completion:nil];
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
        self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:self.hud];
    }
    [self.hud show:YES];
}

#pragma mark - Walktrhough management

-(void) showWalktrhoughView{
    UIViewController *topViewController = [self.navigationController topViewController];    
    UIStoryboard* walkthroughStoryboard = [UIStoryboard storyboardWithName:@"ECWalkthrough" bundle:nil];

    ECWelcomeViewController* welcomeController = [walkthroughStoryboard instantiateInitialViewController];
    welcomeController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [topViewController presentViewController:welcomeController animated:YES completion:nil];
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
        if(newLocation.horizontalAccuracy < 2000.0){ //in meters. If a person's wifi is off the accuracy can go way down, we don't care that much about the accuracy
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
//    [NSUserDefaults setLastSearchRadius:self.mainViewController.currentSearchRadius];
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
//    [NSUserDefaults setLastSearchRadius:self.mainViewController.currentSearchRadius];
    [NSUserDefaults synchronize];
}

-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSString* urlString = [url absoluteString];
    NSString* searchString = @"events/";
    NSRange range = [urlString rangeOfString:searchString];
    if (range.location != NSNotFound) {
        NSString* eventID = [urlString substringFromIndex:range.location+searchString.length];
        [self.mainViewController loadConcertWithID: eventID];
        [Flurry logEvent:@"LoadedConcertSharedOnFacebook" withParameters:[NSDictionary dictionaryWithObject:eventID forKey:@"eventID"]];
    }
    return YES;
}

@end
