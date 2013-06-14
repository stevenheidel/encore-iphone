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

@interface ECProfileViewController : UIViewController <FBUserSettingsDelegate,KLHorizontalSelectDelegate>


@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
@property (strong) NSDictionary * concerts;
@property (nonatomic, strong) KLHorizontalSelect* horizontalSelect;

@end
