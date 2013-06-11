//
//  ECProfileViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ECProfileViewController : UIViewController <FBUserSettingsDelegate>


@property (strong, nonatomic) FBUserSettingsViewController *settingsViewController;
@end
