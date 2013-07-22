//
//  ECAppDelegate.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class ECLoginViewController;
@class ECNewMainViewController;
@protocol FBGraphUser;

@interface ECAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate> {
    BOOL loggedIn;
}

-(void) loginCompletedWithUser: (NSDictionary <FBGraphUser> *) user;
-(void) openSession;
-(void) loginLater;
-(void) showLoginView: (BOOL) animated;
-(BOOL) isLoggedIn;
@property (nonatomic,assign) BOOL fullScreenVideoPlaying;
@property (strong, nonatomic) UIWindow *window;

@property (strong,nonatomic) ECLoginViewController * loginViewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) ECNewMainViewController *mainViewController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property BOOL isNavigating;
@end
