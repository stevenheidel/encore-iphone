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
@class ECAddConcertViewController,ECTodayViewController;

@interface ECProfileViewController : UIViewController <FBUserSettingsDelegate,KLHorizontalSelectDelegate,ECJSONFetcherDelegate>

-(void) fetchConcerts;
@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) NSString * userCity;
//@property (strong) NSDictionary * concerts;
@property (nonatomic, strong) KLHorizontalSelect* horizontalSelect;
@property (nonatomic, strong) ECAddConcertViewController * addConcertVC;
@property (nonatomic, strong) ECTodayViewController * todayVC;
@end
