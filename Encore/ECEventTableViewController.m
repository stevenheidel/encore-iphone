//
//  ECEventTableViewController.m
//  Encore
//
//  Created by Simon Bromberg on 2013-09-27.
//  Copyright (c) 2013 Encore. All rights reserved.
//

//#import "LRGlowingButton.h"
#import "ECEventTableViewController.h"

#import "ECPastViewController.h"
#import "ECUpcomingViewController.h"

#import "UIimageView+AFNetworking.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "MBProgressHUD.h"

#import "ECAppDelegate.h"
#import "EncoreURL.h"
#import "ECAlertTags.h"
#import "UIImage+GaussBlur.h"
#import "UIImage+Merge.h"
#import "NSDictionary+ConcertList.h"
#import "UIFont+Encore.h"
#import "UIColor+EncoreUI.h"

#import "ECJSONFetcher.h"
#import "ECJSONPoster.h"

#import "NSUserDefaults+Encore.h"
#import "ECRowCells.h"

#import "defines.h"
#import "ECConstKeys.h"

#import "TUSafariActivity.h"
#import "ARChromeActivity.h"

#import "RDActivityViewController.h"

static NSString* const ActivityTypeOpenURL = @"com.encore.activityTypeOpenURL";
@interface MapViewAnnotation : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;
@end

@implementation MapViewAnnotation

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	if (self = [super init]) {
        self.title = ttl;
        self.coordinate = c2d;
    }
	return self;
}
@end

@interface ECEventTableViewController () <RDActivityViewControllerDelegate>
@property (nonatomic,strong) UIBarButtonItem* navAddbutton;
@property (nonatomic,strong) UIBarButtonItem* navRemovebutton;
@property (nonatomic,strong) UIView* friendCountView;
@end

@implementation ECEventTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    self.checkedInvites = FALSE; //OR load from nsuserdefaults? (ie global setting)
    
    self.eventName.text = [[self.concert eventName] uppercaseString];
    self.eventVenueAndDate.text = [self.concert venueAndDate];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self setAppearance];
    self.friends = [[NSArray alloc] init];
    
    //Fetch song previews
    [ECJSONFetcher fetchSongPreviewsForArtist:[self.concert headliner] completion:^(NSArray *songs) {
        self.songs = [NSArray arrayWithArray:songs];
        if(self.songs.count > 0){
            self.currentSongIndex = 0;
            [self.tableView reloadData];
        }
    }];
}

-(NSInteger) rowIndexForRowType:(ECEventRow) rowID {
    NSInteger i = 0;
    for (i=0; i<self.rowOrder.count; i++) {
        if ([self.rowOrder[i] integerValue] == rowID) return i;
    }
    return -1; //ERROR, not found
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.statusManager) {
        self.statusManager = [[ECEventProfileStatusManager alloc] init];
    }
    self.statusManager.eventID = self.concert.eventID;
    [self.statusManager setDelegate:self];
    if ([self isMovingToParentViewController]) {
        [self.statusManager checkProfileState];
    }
}
-(void) viewWillDisappear:(BOOL)animated {
//    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
//    }
    if ([self isMovingFromParentViewController]) {
        self.statusManager.delegate = nil;
        self.statusManager = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.statusManager];
    [self stopPlaying];
    [super viewWillDisappear:animated];
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) setRows {
    return; //meant to be overrided
}

-(void) setAppearance {
    
    //Background
    [self.eventImage setImageWithURLRequest:[NSURLRequest requestWithURL:self.concert.imageURL]
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                        self.eventImage.image = image;
                                        UIImage* backgroundImage = [UIImage mergeImage:[image imageWithGaussianBlur]
                                                                             withImage:[UIImage imageNamed:@"fullgradient"]];
                                        
                                        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:backgroundImage];
                                        [tempImageView setFrame:self.tableView.frame];
                                        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
                                        self.tableView.backgroundView = tempImageView;
                                        
                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        
                                        UIImage* image = [UIImage imageNamed:@"placeholder"];
                                        self.eventImage.image = image;
                                       UIImage* backgroundImage = [UIImage mergeImage:[image imageWithGaussianBlur]
                                                                            withImage:[UIImage imageNamed:@"fullgradient"]];
                                        
                                        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:backgroundImage];
                                        [tempImageView setFrame:self.tableView.frame];
                                        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
                                        self.tableView.backgroundView = tempImageView;

                                        
                                    }];
    
    //Event image
    self.eventImage.layer.cornerRadius = 5.0;
    self.eventImage.layer.masksToBounds = YES;
    self.eventImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.eventImage.layer.borderWidth = 0.1;
    
    //Fonts
    [self.eventName setFont:[UIFont heroFontWithSize:16]];
    [self.eventVenueAndDate setFont:[UIFont heroFontWithSize:12]];
    
    //Navigation bar
    UIImage *leftButImage = [UIImage imageNamed:@"backButton"];
    UIButton* leftButton = nil;
    if (self.backButtonShouldGlow) {
//        LRGlowingButton* leftButtonGlow = [LRGlowingButton buttonWithType:UIButtonTypeCustom];
//        leftButtonGlow.glowsWhenHighlighted = YES;
//        leftButtonGlow.highlightedGlowColor = [UIColor greenColor];
//        leftButton = leftButtonGlow;
//        [leftButtonGlow performSelector:@selector(startPulse) withObject:nil afterDelay:PULSE_DELAY];
        leftButImage = [UIImage imageNamed:@"orangeBackButton"];
    }
//    else {
        leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    }
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.tableView.separatorColor = [UIColor separatorColor];
    
}

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowID = [(NSNumber*)[self.rowOrder objectAtIndex:indexPath.row] integerValue];
    switch (rowID) {
        case Friends:
            return 125.0f;
        case Details:
            return 60.0f;
        case Lineup:
            return 142.0f;
        case SongPreview:
            return 76.0f;
        case Photos:
            return 74.0f;
        case Location:
            return 215.0f;
        case Tickets:
            return 60.0f;
        default:
            return 0.0f;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.statusManager.isOnProfile)
        return [self.rowOrder count];
    else
        return [self.rowOrder count] -1;
    
}

-(NSString*) identifierForRow: (NSUInteger) row {
    NSInteger rowID = [(NSNumber*)[self.rowOrder objectAtIndex:row] integerValue];
    switch (rowID) {
        case Friends:
            return @"friends";
        case Details:
            return @"details";
        case Lineup:
            return @"lineup";
        case Photos:
            return @"photos";
        case SongPreview:
            return @"songpreview";
        case Location:
            return @"location";
        case Tickets:
            return @"tickets";
        default:
            return nil;
    }
}


-(void) addFriends {
    if ([ApplicationDelegate isLoggedIn]) {
        [self openFacebookPicker];
    }
    else {
        //TODO: Login Alert
    }
}

-(void) checkInvites:(NSArray*) friends {
    [self.uninvitedFriends removeAllObjects];
    self.uninvitedFriends = [NSMutableArray arrayWithCapacity:self.friends.count];
    
    for (NSDictionary* friend in self.friends) {
        BOOL inviteSent = [[friend valueForKey:@"invite_sent"] boolValue]==1;
        
        if (!inviteSent) {
            [self.uninvitedFriends addObject:friend];
        }
    }
    if ([self.uninvitedFriends count] > 0) {
        NSString* alertMessage = [NSString stringWithFormat:@"%d of your friends haven't joined Encore. Invite them to share this concert with them.",self.uninvitedFriends.count];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Invite", nil];
        alert.tag = ECInviteFriendsTag;
        [alert show];        
    }
}

-(void) inviteFriends: (NSArray*) friends {
    NSString* message;
    
    NSString* date = [self.concert smallDate];
    if([self isKindOfClass:[ECPastViewController class]]){
        message = [NSString stringWithFormat:@"Check out the photos and videos of the %@ %@ concert we went to on Encore.",date,self.concert.headliner];

    }else{
        message = [NSString stringWithFormat:@"Check out the photos and videos of the %@ concert we're going to on Encore. They'll be up after the show.",self.concert.headliner];

    }
    
    
    NSString* stringOfFriends = [[friends valueForKey:@"facebook_id"] componentsJoinedByString:@", "];
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:stringOfFriends,@"to", nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:message
                                                    title:@"Invite"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      NSLog(@"%@",resultURL);
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                          [Flurry logEvent:@"Error_Inviting_Friends_On_Dialog"];
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                              [Flurry logEvent:@"Canceled_Inviting_Friends_On_Dialog"];
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                              [Flurry logEvent:@"Successfully_Invited_Friends" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:friends.count],@"num_invited", nil]];
                                                          }
                                                      }
                                                      [self openGraphShareTrigger];
                                                  }];
}

-(void) openGraphShareTrigger {
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Share on Facebook?" message:@"Share this concert on Facebook?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Share", nil];
//    alert.tag =  ECShareOpenGraphTag;
//    [alert show];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSString* identifier = [self identifierForRow:row];
    NSInteger rowID = [(NSNumber*)[self.rowOrder objectAtIndex:row] integerValue];
    switch (rowID) {
        case Friends: {
            FriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            cell.friends = self.friends;
            [cell.addFriendsButton addTarget:self action:@selector(addFriends) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        case Details: {
            DetailsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [cell.changeStateButton addTarget:self action:@selector(addToProfile) forControlEvents:UIControlEventTouchUpInside];
            self.changeConcertStateButton = cell.changeStateButton;
            [self.changeConcertStateButton setButtonIsOnProfile:self.statusManager.isOnProfile];
            return cell;
        }
        case Lineup: {
            LineupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            cell.navController = self.navigationController;
            cell.previousArtist = self.previousArtist;
            cell.lineup = self.concert.lineup;
            return cell;
        }
        case Photos: {
            GetPhotosCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if(self.hideShareButton){
                [cell.shareButton removeFromSuperview];
            }else{
                [cell.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
            }
            return cell;
        }
        case SongPreview:{
            SongPreviewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            
            if(!self.songInfo){
                [cell.btnPlay setEnabled:NO];
                [cell.btnItunes setEnabled:NO];
                
            }else{
                [cell.btnPlay setEnabled:YES];
                [cell.btnItunes setEnabled:YES];
                [cell.btnPlay addTarget:self
                                 action:@selector(playpauseButtonTapped:)
                       forControlEvents:UIControlEventTouchUpInside];
                [cell.btnItunes addTarget:self
                                   action:@selector(openItunesLink)
                         forControlEvents:UIControlEventTouchUpInside];
            }
            [cell.lblSongName setText:self.songInfo[@"trackCensoredName"]];
            
            if(self.player.rate == 1.0){
                [cell.btnPlay setSelected:YES];
            }
            return cell;
        }
        case Location: {
            LocationCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
           
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",[self.concert addressWithoutCountry]];
            
            NSString* time = [self.concert startTime];
            NSUInteger start = time.length - 5;
            NSString* lastTwoDigits =[time substringWithRange:NSMakeRange(start,2)];
            
            if([self.concert startTime] && ([lastTwoDigits isEqualToString:@"00"] || [lastTwoDigits isEqualToString:@"30"])){
                cell.startTimeLabel.text = [NSString stringWithFormat:@"Doors open at: %@",[self.concert startTime]];
            }else{
                cell.startTimeLabel.text = @"";
            }
            
            CLLocation* location = [self.concert coordinates];
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            cell.location2D = coord2D;
            cell.venueName = self.concert.venueName;
            
            MapViewAnnotation* annotation = [[MapViewAnnotation alloc] initWithTitle:[self.concert venueName] andCoordinate:coord2D];
            [cell.mapView setCenterCoordinate:coord2D];
            [cell.mapView addAnnotation:annotation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord2D, 1000, 1000);
            [cell.mapView setRegion:region animated:YES];
            [cell.mapView regionThatFits:region];
            
            return cell;
        }
        case Tickets: {
            GrabTicketsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            [cell.grabTicketsButton addTarget:self action:@selector(grabTicketTapped:) forControlEvents:UIControlEventTouchUpInside ];
            [cell.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        default:
            return nil;
    }
    
}

#pragma mark - Adding/Removing Concert
-(void) failedToChangeState: (BOOL) isOnProfile {
    [self alertError];
    [self.changeConcertStateButton setButtonIsOnProfile:isOnProfile];
    [Flurry logEvent:@"Failed_Adding_Concert" withParameters:[self flurryParam]];
    
}

//status checker delegate response
-(void) profileState:(BOOL)isOnProfile {
    [self.changeConcertStateButton setButtonIsOnProfile:isOnProfile];
    NSString* name = isOnProfile ? @"removeConcertBorder" : @"addConcertBorder";
    UIImage* image = [UIImage imageNamed:name];
    if (!isOnProfile && !self.navAddbutton) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(addToProfile) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        self.navAddbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navAddbutton.tintColor = [UIColor whiteColor];
    }
    if (isOnProfile && !self.navRemovebutton) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(addToProfile) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        [button setBackgroundImage:image forState:UIControlStateNormal];
        
        self.navRemovebutton = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navRemovebutton.tintColor = [UIColor whiteColor];
    }
    self.navigationItem.rightBarButtonItem = isOnProfile ? self.navRemovebutton : self.navAddbutton;
    
    //if user has this concert in his account
    if(isOnProfile)
    {
        //Fetch friends invites
        NSString* userID = [NSUserDefaults userID];
        [ECJSONFetcher fetchFriendsForUser:userID atEvent:[self.concert eventID] completion:^(NSArray *friends){
            self.friends = friends;
            [self.tableView reloadData];
        }];
        
    }else{
        //reload tableview to remove friends cell
        [self.tableView reloadData];
    }
}

-(void) addToProfile {
    [self.navAddbutton setEnabled:NO];
    
    if (ApplicationDelegate.isLoggedIn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.statusManager name:ECLoginCompletedNotification object:nil];
        
        [self.statusManager toggleProfileState];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To add this concert to your profile, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECChangeStateNotLoggedInAlert;
        [alert show];
    }
}

-(void)successChangingState:(BOOL)isOnProfile {
    [self profileState:isOnProfile];
    [self concertStateChangedHUD];
    
    if([self.eventStateDelegate respondsToSelector:@selector(profileUpdated)])
        [self.eventStateDelegate profileUpdated];
    
    [Flurry logEvent:@"Completed_Adding_Concert" withParameters:[self flurryParam]];
    
    if (isOnProfile) {
        [self openFacebookPicker];
    }
    [self.navAddbutton setEnabled: YES];
}

-(void) concertStateChangedHUD {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if(self.statusManager.isOnProfile){
        HUD.labelText = NSLocalizedString(@"concert_added",nil);
        HUD.color = [UIColor lightBlueHUDConfirmationColor];
    }else{
        HUD.labelText = NSLocalizedString(@"concert_removed", nil);
        HUD.color = [UIColor redHUDConfirmationColor];
    }
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:HUD_DELAY];
}

#pragma mark - friends

-(void) openFacebookPicker {
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        NSString* titleForPicker = @"Who's coming?"; //TODO: move to subclasses?
        if (self.tense == ECSearchTypePast) {
            titleForPicker = @"Who else went?";
        }
        self.friendPickerController.title = titleForPicker;
        self.friendPickerController.delegate = self;
    }
    [self.friendPickerController loadData];
    
    [self.friendPickerController clearSelection];
    
//    self.friendPickerController.userID = [NSUserDefaults userID];
    [self presentViewController:self.friendPickerController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self addSearchBarToFriendPickerView];
    }];
    
}

- (void) handlePickerDone {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    }
}

- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSArray* selection = self.friendPickerController.selection;
    if (selection.count>0) {
        NSMutableArray* subSelection = [NSMutableArray arrayWithCapacity:selection.count];
        for (NSDictionary* dic in selection) {
            [subSelection addObject:[NSDictionary dictionaryWithObjectsAndKeys:[dic objectForKey:@"id"],@"facebook_id", [dic objectForKey:@"name"], @"name",nil]];
        }
        self.friends = nil;
        //When user finish select friends, Check for un-invited friends and show Facebook invite dialoge
        [ECJSONPoster addFriends: subSelection
                          ofUser:[NSUserDefaults userID]
                         toEvent:[self.concert eventID]
                      completion:^(NSArray* uninvitedFriends) {
                          self.friends = uninvitedFriends;
                          [self checkInvites:self.friends];
                          [self.tableView reloadData];
        }];
    }
    
    [self handlePickerDone];
    [Flurry logEvent:@"Done_Friend_Tagging" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:selection.count],@"taggedFriendsCount",self.concert.eventID,@"eventID",self.concert.headliner,@"headliner", nil]];
}

-(void) facebookViewControllerCancelWasPressed:(id)sender {
    [self handlePickerDone];
}

-(void) friendPickerViewControllerSelectionDidChange:(FBFriendPickerViewController *)friendPicker {
    if (!self.friendCountView) {
        self.friendCountView = [[UIView alloc] initWithFrame:CGRectMake(0, friendPicker.view.frame.size. height - 40, friendPicker.view.frame.size.width, 40)];
        UILabel* countLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, friendPicker.view.frame.size.width, 35)];
        countLabel.tag = 45;
        countLabel.textColor = [UIColor whiteColor];
        countLabel.font = [UIFont heroFontWithSize:17.0];
        [self.friendCountView addSubview: countLabel];
        self.friendCountView.backgroundColor = [UIColor blueArtistTextColor];
        [friendPicker.view addSubview:self.friendCountView];
        [friendPicker.view bringSubviewToFront:self.friendCountView];
        
    }
    
    NSInteger count = friendPicker.selection.count;
    if (count == 0) {
        self.friendCountView.hidden = YES;
        return;
    }
    else {
        self.friendCountView.hidden = NO;
    }
    [(UILabel*)[self.friendCountView viewWithTag: 45] setText: [NSString stringWithFormat:@"%d friend%@ selected", count,count > 1 ? @"s" : @""]];
}

- (void)addSearchBarToFriendPickerView
{
    if (self.searchBar == nil) {
        CGFloat searchBarHeight = 44.0;
        self.searchBar =
        [[UISearchBar alloc]
         initWithFrame:
         CGRectMake(0,0,
                    self.view.bounds.size.width,
                    searchBarHeight)];
        self.searchBar.autoresizingMask = self.searchBar.autoresizingMask |
        UIViewAutoresizingFlexibleWidth;
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = NO;
        
        self.friendPickerController.tableView.tableHeaderView = self.searchBar;

        //HACK because Facebook SDK is messed up
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height = newFrame.size.height + 1;
        self.friendPickerController.tableView.frame = newFrame;
        self.friendPickerController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    }
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

-(BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(BOOL) searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

-(void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    searchBar.text = nil;
    [searchBar resignFirstResponder];
    [self.friendPickerController updateView];
}

- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    if (self.searchText && ![self.searchText isEqualToString:@""]) {
        NSRange result = [user.name
                          rangeOfString:self.searchText
                          options:NSCaseInsensitiveSearch];
        if (result.location != NSNotFound) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return YES;
    }
    return YES;
}

- (void)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                       handleError:(NSError *)error {
    NSLog(@"FBFriendPickerViewController error: %@",error);
}


#pragma mark - Sharing
-(NSString*) shareTextPrefix {
    NSString* eventName = [self.concert eventName];
    NSString* the = @"the ";
    NSString* substring = [[eventName substringToIndex:3]lowercaseString];
    if ([substring isEqualToString:@"the"]) {
        the = @"";
    }
    return the;
}

-(NSString*) shareTextForActivityType: (NSString*) activityType  {
    NSLog(@"Warning: %@ subclass has not overidden shareText.",NSStringFromClass(self.class));
    return [NSString stringWithFormat: @"Want to come to %@%@ show at %@, %@?",[self shareTextPrefix],[self.concert eventName],[self.concert venueName],[self.concert niceDateNotUppercase]];
}

-(NSURL*) shareURL {
    NSLog(@"Warning: %@ subclass has not overidden shareURL. Returning nil share URL",NSStringFromClass(self.class));
    return nil;
}

-(NSArray*) activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    NSURL* url = [self shareURL];
    NSString* text = [self shareTextForActivityType:activityType];
    UIImage* image = self.eventImage.image;
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return @[text,url];
    }
    
    if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
        return @[url];
    }
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return @[text,url];
    }
    
    if ([activityType isEqualToString:NSStringFromClass([TUSafariActivity class])] || [activityType isEqualToString:NSStringFromClass([ARChromeActivity class])]) {
        return @[url];
    }
    
    return @[text,url,image];
}

-(void) shareTapped {
    TUSafariActivity* safariActivity = [TUSafariActivity new];
    ARChromeActivity* chromeActivity = [ARChromeActivity new];
//    UIActivityViewController* shareDrawer = [[UIActivityViewController alloc] initWithActivityItems:[self activityViewController:nil itemsForActivityType:nil] applicationActivities:@[safariActivity]];
    
    RDActivityViewController* shareDrawer = [[RDActivityViewController alloc] initWithDelegate:self maximumNumberOfItems:3 applicationActivities:@[safariActivity,chromeActivity] placeholderItem:nil];
    shareDrawer.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypePrint];

    shareDrawer.completionHandler = ^(NSString *activityType, BOOL completed){
        if (completed) {
            NSLog(@"Selected activity was performed.");
        } else {
            if (activityType == NULL) {
                NSLog(@"User dismissed the view controller without making a selection.");
            } else {
                NSLog(@"Activity was not performed.");
            }
        }
        NSString* result = completed ? @"success" : @"fail";
        if (activityType == NULL) {
            result = @"dismissed";
        }
        [Flurry logEvent:FEShareTapped withParameters:[NSDictionary dictionaryWithObjectsAndKeys:activityType,@"ActivityType", result, @"result", self.concert.eventID,@"eventID",self.concert.headliner,@"headliner",[self tenseString],@"PageType",nil]];
    };
    [self presentViewController:shareDrawer animated:YES completion:nil];
}

-(void)grabTicketTapped: (id) sender
{
    NSLog(@"%@: grabTicketTapped must be overwritten",NSStringFromClass(self.class));
}
#pragma mark - misc
-(NSString*) tenseString {
    ECSearchType tense = self.tense;
    if (tense == ECSearchTypeToday) {
        return @"Today";
    }
    else return tense == ECSearchTypePast ? TenseStrPast : TenseStrFuture;
    return nil;
}


-(void) alertError {
    if ([self.navigationController.visibleViewController isEqual:self])  {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Try again", nil) message:NSLocalizedString(@"Sorry, an error occured. Please try again later.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


-(NSDictionary*) flurryParam {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.concert.eventID,@"eventID",self.concert.eventName,@"eventName",[self tenseString],@"tense", nil];
}

#pragma mark Autorotation
-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - uialertviewdelegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
        }
        
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Past_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
        return; //don't process other alerts
    }
    else if (alertView.tag == ECShareNotLoggedInAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareTapped) name:ECLoginCompletedNotification object:nil];
            
        }
    }else if (alertView.tag == ECChangeStateNotLoggedInAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self.statusManager selector:@selector(checkProfileState) name:ECLoginCompletedNotification object:nil];
        }
        [self.navAddbutton setEnabled:YES];
    }else if (alertView.tag == ECInviteFriendsTag)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self inviteFriends: self.uninvitedFriends];
        }
        else {
            [self openGraphShareTrigger];
        }
        [Flurry logEvent:@"Invite_Friends_Alert_Result" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[alertView buttonTitleAtIndex:buttonIndex],@"tappedButton", self.concert.eventID,@"eventID",self.concert.headliner,@"headliner", nil]];
    } else if (alertView.tag == ECShareOpenGraphTag) {
        NSMutableDictionary<FBGraphObject> *action = [FBGraphObject graphObject];
        action.provisionedForPost = YES;
        NSMutableDictionary<FBGraphObject> *object = [FBGraphObject openGraphObjectForPost];
        object.provisionedForPost = YES;
        
        object[@"og"] = @{@"title":self.concert.eventName,@"image":self.concert.imageURL.absoluteString,@"url":[NSString stringWithFormat:ShareConcertURL,self.concert.eventID],@"type":@"encorefm:concert"};
        object[@"artist"] = self.concert.headliner;
        object[@"venue"] = self.concert.venueName;
        object[@"date"] = self.concert[@"date"];
        object[@"city"] = self.concert.city;
        id<FBGraphObject> location = [FBGraphObject graphObject];
        location[KeyLatitude] = [NSNumber numberWithFloat:self.concert.coordinates.coordinate.latitude];
        location[KeyLongitude] = [NSNumber numberWithFloat:self.concert.coordinates.coordinate.longitude];
        object[@"coordinates"] = location;
        action[@"concert"] = object;
//        // Check if the Facebook app is installed and we can present the share dialog
//        
//        // Create an action
//        id<FBOpenGraphAction> action2 = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
//        
//        // Link the object to the action
//        [action setObject:object forKey:@"concert"];
//        FBOpenGraphActionShareDialogParams *params = [[FBOpenGraphActionShareDialogParams alloc] init];
//        params.action = action2;
//        params.actionType = @"encorefm:went_to";
//        
//        // If the Facebook app is installed and we can present the share dialog
//        if([FBDialogs canPresentShareDialogWithOpenGraphActionParams:params]) {
//            // Show the share dialog
//            [FBDialogs presentShareDialogWithOpenGraphAction:action2
//                                                  actionType:@"encorefm:went_to"
//                                         previewPropertyName:@"dish"
//                                                     handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//                                                         if(error) {
//                                                             // There was an error
//                                                             NSLog(@"Error publishing story: %@", error.description);
//                                                         } else {
//                                                             // Success
//                                                             NSLog(@"result %@", results);
//                                                         }
//                                                     }];
//            
//            // If the Facebook app is NOT installed and we can't present the share dialog
//        } else {
//            // FALLBACK GOES HERE
//        }
        
        
        [FBRequestConnection startForPostWithGraphPath:@"me/encorefm:went_to"
                                           graphObject:action
                                     completionHandler:^(FBRequestConnection *connection,
                                                         id result,
                                                         NSError *error) {
                                         if (error) {
                                             NSLog(@"%@: error posting FB open graph story, %@",NSStringFromClass(self.class),error.description);
                                         }
                                         else {
                                             NSLog(@"%@: Success posting FB open graph story",NSStringFromClass(self.class));
                                         }
                                     }];
    }
    
}


/**
 * A function for parsing URL parameters.
 */
//- (NSDictionary*)parseURLParams:(NSString *)query {
//    NSArray *pairs = [query componentsSeparatedByString:@"&"];
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    for (NSString *pair in pairs) {
//        NSArray *kv = [pair componentsSeparatedByString:@"="];
//        NSString *val =
//        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        params[kv[0]] = val;
//    }
//    return params;
//}


#pragma mark - Play/Pause Song preview

-(NSDictionary*) songInfo {
    if (self.songs.count >0) {
        return [self.songs objectAtIndex:self.currentSongIndex];
    }
    return nil;
}

-(void)prepareCurrentSong {
    NSURL *url = [NSURL URLWithString:self.songInfo[@"previewUrl"]];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
}

- (void) stopPlaying {
    if (self.player && self.player.rate == 1.0) {
        [self.player pause];
        SongPreviewCell* cell = (SongPreviewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:SongPreview inSection:0]];
        [cell.btnPlay setSelected:NO];
    }
}
- (void) playpauseButtonTapped:(UIButton*)button {
    if(!self.player)
        [self prepareCurrentSong];

    [button setSelected:!button.selected];
    if (self.player.rate == 1.0) {
        [self.player pause];
    } else {
        [self.player play];
    }
    [Flurry logEvent:@"Tapped_Play_Button" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self tenseString],@"PageType",self.concert.headliner, @"artist", nil]];
}

-(void)songDidFinishPlaying {
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:self.player.currentItem];
    if(self.currentSongIndex < self.songs.count-1){
        self.currentSongIndex++;
        [self prepareCurrentSong];
        [self.player play];

        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self rowIndexForRowType:SongPreview] inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        //Reset everything back
        self.currentSongIndex = 0;
        self.player= nil;
        //Reload the view
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SongPreview inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        //Deselect the button
        SongPreviewCell * songCell =(SongPreviewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self rowIndexForRowType:SongPreview] inSection:0]];
        [songCell.btnPlay setSelected:NO];
    }
    
}

-(void)openItunesLink {
    NSString* affliateURL = [self.songInfo[@"trackViewUrl"] stringByAppendingFormat:@"&at=%@",kAffiliateCode];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:affliateURL]];
    [Flurry logEvent:@"Tapped_iTunes_Link" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self tenseString], @"PageType", self.concert.headliner,@"artist", nil]];
}

@end


