//
//  ECPastViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSearchType.h"
#import "ECEventProfileStatusManager.h"
#import "ECChangeConcertStateButton.h"

@protocol ECPastViewControllerDelegate <NSObject>
- (void) profileUpdated;
@end

@interface ECPastViewController : UITableViewController <UIAlertViewDelegate,ECEventProfileStatusManagerDelegate>
@property (nonatomic,assign) BOOL isOnProfile;
@property (nonatomic,weak) ECChangeConcertStateButton* iwasthereButton;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueAndDate;
@property (nonatomic,strong) ECEventProfileStatusManager* statusManager;
@property (nonatomic,strong) id <ECPastViewControllerDelegate> eventStateDelegate; //for profile

@property (nonatomic, assign) ECSearchType tense;
@property (nonatomic,strong) NSDictionary * concert;
@end
