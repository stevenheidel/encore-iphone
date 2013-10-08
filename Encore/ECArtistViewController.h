//
//  ECArtistViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSearchType.h"
#import <AVFoundation/AVFoundation.h>
@class MBProgressHUD;
typedef enum {
    PastSegment,
    UpcomingSegment
} SegmentedControlIndices;

@class ECPastUpcomingSectionHeader;
@interface ECArtistViewController : UITableViewController

@property (nonatomic,strong) AVPlayer* player;
@property (nonatomic,readonly) NSDictionary* songInfo;
@property (nonatomic,strong) NSArray * songs;
@property (assign) NSInteger currentSongIndex;
@property (nonatomic,weak) MBProgressHUD* hud;
@property (nonatomic,strong) NSString* artist;
@property (nonatomic,strong) NSDictionary* events;
@property (nonatomic, readonly) NSArray* pastEvents;
@property (nonatomic, readonly) NSArray* upcomingEvents;
@property (weak,nonatomic) IBOutlet UIImageView* artistImageView;
@property (weak,nonatomic) UIImage* artistImage;
@property (weak,nonatomic) IBOutlet UILabel* artistNameLabel;
@property (nonatomic,assign) SegmentedControlIndices currentSelection;
@property (nonatomic, strong) ECPastUpcomingSectionHeader* sectionHeaderView;
@end

@interface ECPastUpcomingSectionHeader : UIView
- (IBAction)switchedSelection:(id)sender;
@property (nonatomic,weak) IBOutlet UISegmentedControl* segmentedControl;
@property (nonatomic, weak) ECArtistViewController* artistVC;
@property (nonatomic, weak) IBOutlet UILabel* titleLabel;
@end