//
//  ECUpcomingViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSearchType.h"
#import "ECEventProfileStatusManager.h"
#import "ECChangeConcertStateButton.h"
@protocol ECUpcomingViewControllerDelegate <NSObject>
- (void) profileUpdated;
@end

@interface ECUpcomingViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueAndDate;
@property (nonatomic,weak) ECChangeConcertStateButton* iamgoingButton;
@property (nonatomic,strong) ECEventProfileStatusManager* statusManager;
@property (nonatomic,strong) id <ECUpcomingViewControllerDelegate> eventStateDelegate; //for profile
@property (nonatomic,strong) NSString* previousArtist;
@property (nonatomic, assign) ECSearchType tense;
@property (nonatomic,strong) NSDictionary * concert;
@end

