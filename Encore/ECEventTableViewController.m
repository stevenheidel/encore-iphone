//
//  ECEventTableViewController.m
//  Encore
//
//  Created by Simon Bromberg on 2013-09-27.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECEventTableViewController.h"

#import "UIimageView+AFNetworking.h"
#import "ATAppRatingFlow.h"
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
#define kAffiliateCode @"10lbaN"
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

@interface ECEventTableViewController ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.checkedInvites = FALSE; //OR load from nsuserdefaults?
    
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
        self.currentSongIndex = 0;
        [self.tableView reloadData];
    }];
    
   
    //self.friends = nil;
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
    [self.statusManager checkProfileState];
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self.player pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
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
                                        
                                        self.eventImage.image = [UIImage imageNamed:@"placeholder.jpg"];
                                        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Black"] imageWithGaussianBlur] ];
                                        [tempImageView setFrame:self.tableView.frame];
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
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    self.tableView.separatorColor = [UIColor separatorColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowID = [(NSNumber*)[self.rowOrder objectAtIndex:indexPath.row] integerValue];
    switch (rowID) {
        case Friends:
            return 100.0f;
        case Details:
            return 75.0f;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
    NSMutableArray* uninvitedFriends = [NSMutableArray arrayWithCapacity:self.friends.count];
    for (NSDictionary* friend in self.friends) {
        BOOL inviteSent = [[friend valueForKey:@"invite_sent"] boolValue]==1;
        
        if (!inviteSent) {
            [uninvitedFriends addObject:friend];
        }
    }
    if ([uninvitedFriends count] > 0) {
        [self inviteFriends: uninvitedFriends];
    }
}

-(void) inviteFriends: (NSArray*) friends {
    NSString* stringOfFriends = [[friends valueForKey:@"facebook_id"] componentsJoinedByString:@", "];
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:stringOfFriends,@"to", nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:@"Check out Encore on iOS!"
                                                    title:@"Invite"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      NSLog(@"%@",resultURL);
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                              [Flurry logEvent:@"Canceled_Inviting_Friends_On_Dialog"];
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                              [Flurry logEvent:@"Successfully_Invited_Friends" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:friends.count],@"num_invited", nil]];
                                                          }
                                                      }}];
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
           
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",[self.concert address]];
            cell.startTimeLabel.text = [self.concert startTime];
            
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
            if (cell == nil) {
                cell = [[GrabTicketsCell alloc] init];
                
            }
            cell.lastfmURL = [self.concert lastfmURL];
            cell.grabTicketsButton.titleLabel.font = [UIFont heroFontWithSize:20];
            cell.grabTicketsButton.layer.cornerRadius = 5.0;
            cell.grabTicketsButton.layer.masksToBounds = YES;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            [cell.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        default:
            return nil;
    }
    
}

#pragma mark - Adding/Removing Concert
-(void) failedToChangeState: (BOOL) isOnProfile;
{
    [self alertError];
    [self.changeConcertStateButton setButtonIsOnProfile:isOnProfile];
    [Flurry logEvent:@"Failed_Adding_Concert" withParameters:[self flurryParam]];
    
}

-(void) profileState:(BOOL)isOnProfile {
    [self.changeConcertStateButton setButtonIsOnProfile:isOnProfile];
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

-(void) addToProfile{
    if (ApplicationDelegate.isLoggedIn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.statusManager name:ECLoginCompletedNotification object:nil];
        
        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
        [self.statusManager toggleProfileState];
        
    }else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To add this concert to your profile, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECChangeStateNotLoggedInAlert;
        [alert show];
    }
}

-(void)successChangingState:(BOOL)isOnProfile
{
    [self profileState:isOnProfile];
    [self concertStateChangedHUD];
    
    if([self.eventStateDelegate respondsToSelector:@selector(profileUpdated)])
        [self.eventStateDelegate profileUpdated];
    
    [Flurry logEvent:@"Completed_Adding_Concert" withParameters:[self flurryParam]];
    
    if (isOnProfile) {
        [self openFacebookPicker];
    }
}

-(void) concertStateChangedHUD{
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
        self.friendPickerController.title = NSLocalizedString(@"Who else went?", @"Title for facebook friend picker"); //TODO: change for upcoming
        self.friendPickerController.delegate = self;
    }

    [self.friendPickerController loadData];
    
    [self.friendPickerController clearSelection];
    
    self.friendPickerController.userID = [NSUserDefaults userID];
    [self presentViewController:self.friendPickerController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self addSearchBarToFriendPickerView];
    }];
    
}

- (void) handlePickerDone
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{
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
    
}

-(void) facebookViewControllerCancelWasPressed:(id)sender {
    [self handlePickerDone];
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
        self.searchBar.showsCancelButton = YES;
        
        [self.friendPickerController.canvasView addSubview:self.searchBar];
        CGRect newFrame = self.friendPickerController.view.bounds;
        newFrame.size.height -= searchBarHeight;
        newFrame.origin.y = searchBarHeight;
        self.friendPickerController.tableView.frame = newFrame;
    }
}

- (void) handleSearch:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    self.searchText = searchBar.text;
    [self.friendPickerController updateView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self handleSearch:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    self.searchText = nil;
    [searchBar resignFirstResponder];
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

-(NSString*) shareTextPrefix {
    NSString* eventName = [self.concert eventName];
    NSString* the = @"the ";
    NSString* substring = [[eventName substringToIndex:3]lowercaseString];
    if ([substring isEqualToString:@"the"]) {
        the = @"";
    }
    return the;
}

-(NSString*) shareText {
       return [NSString stringWithFormat: @"Encore: Who wants to come to %@%@ show at %@, %@?",[self shareTextPrefix],[self.concert eventName],[self.concert venueName],[self.concert niceDate]];
    //meant to be overrided
}

#pragma mark FB Sharing
-(void) shareTapped {
    
    NSString* shareText = [self shareText];
    
    NSURL* url = [self.concert lastfmURL];
    NSArray *activityItems = [NSArray arrayWithObjects:shareText,url, self.eventImage.image, nil];
    
    UIActivityViewController* shareDrawer = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    shareDrawer.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypePrint];
    
    //TODO: do something with this completion handler, ie. analytics.
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
    };
    [self presentViewController:shareDrawer animated:YES completion:nil];
}


#pragma mark - misc
-(NSString*) tenseString {
    ECSearchType tense = self.tense;
    if (tense == ECSearchTypeToday) {
        return @"Today";
    }
    else return tense == ECSearchTypePast ? @"Past" : @"Future";
    return nil;
}


-(void) alertError {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, an error occured and your request was not processed.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
//    NSLog(@"Song %@",[self.songs objectAtIndex:self.currentSongIndex]);
    return [self.songs objectAtIndex:self.currentSongIndex];
}

-(void)prepareCurrentSong
{
    NSURL *url = [NSURL URLWithString:self.songInfo[@"previewUrl"]];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
}
- (void) playpauseButtonTapped:(UIButton*)button
{
    if(!self.player)
        [self prepareCurrentSong];

    [button setSelected:!button.selected];
    if (self.player.rate == 1.0) {
        [self.player pause];
    } else {
        [self.player play];
    }
    
}
-(void)songDidFinishPlaying
{
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:AVPlayerItemDidPlayToEndTimeNotification
                                                 object:self.player.currentItem];
    if(self.currentSongIndex < self.songs.count-1){
        self.currentSongIndex++;
        [self prepareCurrentSong];
        [self.player play];

        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SongPreview inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        //Reset everything back
        self.currentSongIndex = 0;
        self.player= nil;
        //Reload the view
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SongPreview inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
        //Deselect the button
        SongPreviewCell * songCell =(SongPreviewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SongPreview inSection:0]];
        [songCell.btnPlay setSelected:NO];
    }
    
}

-(void)openItunesLink
{
    NSString* affliateURL = [self.songInfo[@"trackViewUrl"] stringByAppendingFormat:@"&at=%@",kAffiliateCode];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:affliateURL]];
    
}

@end