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
@interface ECProfileViewController : UIViewController <FBUserSettingsDelegate,KLHorizontalSelectDelegate,ECJSONFetcherDelegate>


@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
//@property (strong) NSDictionary * concerts;
@property (nonatomic, strong) KLHorizontalSelect* horizontalSelect;

@end
