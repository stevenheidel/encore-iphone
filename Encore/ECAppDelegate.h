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
@class ECProfileViewController;
@protocol FBGraphUser;

@interface ECAppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate, CLLocationManagerDelegate>

-(void) loginCompletedWithUser: (NSDictionary <FBGraphUser> *) user;
-(void) openSession;

@property (strong, nonatomic) UIWindow *window;
@property (strong,nonatomic) ECLoginViewController * loginViewController;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) ECProfileViewController *profileViewController;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property BOOL isNavigating;
@end
