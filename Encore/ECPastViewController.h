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
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
@protocol ECPastViewControllerDelegate <NSObject>
- (void) profileUpdated;
@end

@interface ECPastViewController : UITableViewController <UIAlertViewDelegate,ECEventProfileStatusManagerDelegate,FBFriendPickerDelegate>


@property (nonatomic,weak) ECChangeConcertStateButton* iwasthereButton;

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueAndDate;

@property (nonatomic,strong) ECEventProfileStatusManager* statusManager;
@property (nonatomic,strong) id <ECPastViewControllerDelegate> eventStateDelegate; //for profile
@property (nonatomic,strong) NSString* previousArtist; //if the view was reached from an artist page, remembers in case user clicks on same artist again

@property (nonatomic, assign) ECSearchType tense;
@property (nonatomic,strong) NSDictionary * concert;
@property (nonatomic,assign) BOOL hideShareButton;

@property (nonatomic,strong) AVPlayer* player;
@property (nonatomic,readonly) NSDictionary* songInfo;
@property (nonatomic,strong) NSArray * songs;

@property (nonatomic,strong) FBFriendPickerViewController* friendPickerController;

@end
