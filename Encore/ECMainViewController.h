//
//  ECProfileViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "KLHorizontalSelect.h"
#import "ECJSONFetcher.h"
#import "ECConcertDetailViewController.h"
#import "ECProfileViewController.h"
//#import "ECTodayViewController.h"


@class ECAddConcertViewController,ECTodayViewController;

@interface ECMainViewController : UIViewController <FBUserSettingsDelegate,KLHorizontalSelectDelegate,ECJSONFetcherDelegate/*, ECTodayViewControllerDelegate*/>

-(void) fetchConcerts;
-(void) updateViewWithNewConcert: (NSNumber *) concertID;
-(void) showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer;
-(void) refreshForConcertID: (NSNumber*) concertID;

@property (strong, nonatomic) ECProfileViewController *profileViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) NSString * userCity;
//@property (strong) NSDictionary * concerts;
@property (nonatomic, strong) KLHorizontalSelect* horizontalSelect;
@property (nonatomic, strong) ECAddConcertViewController * addPastConcertVC;
@property (nonatomic, strong) ECAddConcertViewController * addFutureConcertVC;
@property (nonatomic, strong) ECTodayViewController * todayVC;


@end
