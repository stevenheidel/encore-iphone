//
//  ECEventTableViewController.h
//  Encore
//
//  Created by Simon Bromberg on 2013-09-27.
//  Copyright (c) 2013 Encore. All rights reserved.
//  Superclass for properties and methods common to both past and upcoming view controllers

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ECSearchType.h"
#import "ECEventProfileStatusManager.h"
#import "ECChangeConcertStateButton.h"
#import <AVFoundation/AVFoundation.h>

typedef enum {
    Photos,
    Lineup,
    SongPreview,
    Details,
    Friends,
    Tickets,
    Location
} ECEventRow;

#define HUD_DELAY 1.0

static const int pastRows[] = {Photos, Lineup, SongPreview, Details, Friends}; //TODO: Currently, since friends is hidden depending on whether or not the person went/is going to a show, friends has to be last row, need to change implementation if want it differently
static const int upcomingRows[] = {Tickets, Lineup,SongPreview, Location, Details, Friends};

@protocol ECEventViewControllerDelegate <NSObject>
- (void) profileUpdated;
@end

@interface ECEventTableViewController : UITableViewController <UIAlertViewDelegate,ECEventProfileStatusManagerDelegate,FBFriendPickerDelegate,UISearchBarDelegate>

-(void) openFacebookPicker;
-(NSDictionary*) flurryParam;
-(NSString*) shareTextPrefix;
-(void) setRows;

@property (nonatomic, assign) BOOL checkedInvites;
@property (atomic, strong) NSMutableArray* uninvitedFriends;

@property (nonatomic, strong) NSArray* friends;
@property (nonatomic,strong) NSArray* rowOrder;
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueAndDate;

@property (nonatomic,strong) ECEventProfileStatusManager* statusManager;
@property (nonatomic,strong) id <ECEventViewControllerDelegate> eventStateDelegate; //for profile
@property (nonatomic,strong) NSString* previousArtist; //if the view was reached from an artist page, remembers in case user clicks on same artist again

@property (nonatomic,strong) AVPlayer* player;
@property (nonatomic,readonly) NSDictionary* songInfo;
@property (nonatomic,strong) NSArray * songs;
@property (assign) NSInteger currentSongIndex;

@property (nonatomic, assign) ECSearchType tense;
@property (nonatomic,strong) NSDictionary * concert;
@property (nonatomic,assign) BOOL hideShareButton;

@property (nonatomic,strong) FBFriendPickerViewController* friendPickerController;
@property (retain, nonatomic) UISearchBar *searchBar;
@property (retain, nonatomic) NSString *searchText;

@property (nonatomic,weak) ECChangeConcertStateButton* changeConcertStateButton;


@end
