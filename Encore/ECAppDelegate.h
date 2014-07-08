//
//  ECAppDelegate.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>

#define ApplicationDelegate ((ECAppDelegate *)[UIApplication sharedApplication].delegate)
static NSString* const ECLocationAcquiredNotification = @"com.encoretheapp.Encore:ECLocationAcquiredNotification";
static NSString* const ECLocationFailedNotification = @"com.encoretheapp.Encore:ECLocationFailed";
static NSString* const ECLoginCompletedNotification = @"com.encoretheapp.Encore:ECLoginCompletedNotification";

@class ECLoginViewController;
@class ECNewMainViewController;
@class MBProgressHUD;
@protocol FBGraphUser;

@interface ECAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate> {
}
-(void)beginFacebookAuthorization;
//-(void) loginCompletedWithUser: (NSDictionary /*<FBGraphUser>*/ *) user;
//-(void) openSession;
-(void) loginLater;
-(void) logout;
-(void) showLoginView: (BOOL) animated;
-(void) showLoginHUD;
-(BOOL) isLoggedIn;
-(BOOL) connected;
-(void) setUpLocationManager;
@property (strong,nonatomic) UIView* unreachableIndicatorView;
@property (strong,nonatomic) MBProgressHUD* hud;
@property (nonatomic,assign) BOOL fullScreenVideoPlaying;
@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) ECLoginViewController * loginViewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) ECNewMainViewController *mainViewController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property BOOL isNavigating;
-(void) showWalkthroughView;
-(NSURL *) applicationDocumentsDirectory;
@end
