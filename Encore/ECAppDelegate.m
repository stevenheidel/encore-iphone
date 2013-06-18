//
//  ECAppDelegate.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECAppDelegate.h"
#import "ECProfileViewController.h"
#import "ECLoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ECJSONPoster.h"
NSString *const ECSessionStateChangedNotification = @"com.encoretheapp.Encore:ECSessionStateChangedNotification";

@implementation ECAppDelegate

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Facebook SDK * login flow *
    // Attempt to handle URLs to complete any auth (e.g., SSO) flow.
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        // Facebook SDK * App Linking *
        // For simplicity, this sample will ignore the link if the session is already
        // open but a more advanced app could support features like user switching.
        if (call.accessTokenData) {
            if ([FBSession activeSession].isOpen) {
                NSLog(@"INFO: Ignoring app link because current session is open.");
            }
            else {
                [self handleAppLink:call.accessTokenData];
            }
        }
    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.profileViewController = [[ECProfileViewController alloc] init];
    self.loginViewController = [[ECLoginViewController alloc] init];
    
    if(self.locationManager==nil){
        _locationManager = [[CLLocationManager alloc] init];
    
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        _locationManager.distanceFilter = 5000;
        self.locationManager=_locationManager;
    }
    
    self.profileViewController.title = @"Encore";
    
    //self.navigationController   = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
    self.navigationController   = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    
    self.window.rootViewController = self.navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [FBLoginView class];
    
    // See if the app has a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [self openSession];
    } else {
        // No, display the login page.
        [self showLoginView: NO];
    }
    return YES;
}

#pragma mark - Login management
-(void) openSession {
    
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
    
    UIViewController *topViewController;
    
    switch (state) {
        case FBSessionStateOpen: {
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection,NSDictionary<FBGraphUser> *user,NSError *error){
                if(!error){
                    [self loginCompletedWithUser:user];
                }
            }];
            topViewController = [self.navigationController topViewController];
            if ([[topViewController presentedViewController] isKindOfClass:[ECLoginViewController class]]) {
                [topViewController dismissViewControllerAnimated:YES completion:nil];
            }
            if (![topViewController isKindOfClass:[ECProfileViewController class]]) {
            }
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
                                  [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}

-(void) loginCompletedWithUser:(NSDictionary <FBGraphUser>*) user {
    NSString * userid = user.id;
    NSLog(@"Logged in user with id: %@",userid);
    self.profileViewController.facebook_id = userid;
    self.profileViewController.userName = user.name; //TODO: remove if not needed
    
    [ECJSONPoster postUserID:userid];
    [self.profileViewController fetchConcerts];
    [self saveUserIDToDefaults: userid];
}

-(void) saveUserIDToDefaults: (NSString *) userID {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * userIDKey = NSLocalizedString(@"user_id", nil);
    NSString * defaultID = [defaults stringForKey:userIDKey];
    if (!defaultID || ![defaultID isEqualToString:userID]) {
        [defaults setObject:userID forKey:userIDKey];
        [defaults synchronize];
    }
    else defaultID ? NSLog(@"No default ID saved") : NSLog(@"No change in User ID. Defaults not changed");
}

#pragma mark - location
- (void)getUserLocation {
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    //Ensure location update is recent
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        if(newLocation.horizontalAccuracy < 1000.0){
            //Ensure location is accurate to the nearest kilometer
            NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
            NSLog(@"Horizontal Accuracy:%f", newLocation.horizontalAccuracy);
            //turn off location services once we've gotten a good location
            [manager stopUpdatingLocation];
            //TODO: add code for getting the user's city from the server using coordinates
        }
    }
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
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
