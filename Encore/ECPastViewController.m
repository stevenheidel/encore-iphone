//
//  ECPastViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECPastViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIimageView+AFNetworking.h"
#import "NSDictionary+ConcertList.h"
#import "UIImage+GaussBlur.h"
#import "UIImage+Merge.h"
#import "UIFont+Encore.h"

#import <FacebookSDK/FacebookSDK.h>
#import "ATAppRatingFlow.h"

#import "ECAppDelegate.h"
#import "EncoreURL.h"
#import "ECAlertTags.h"
#import "UIColor+EncoreUI.h"

#import "ECJSONFetcher.h"
#import "NSUserDefaults+Encore.h"
#import "ECRowCells.h"
#import "ECGridViewController.h"
#import "ECJSONPoster.h"

#import "MBProgressHUD.h"


#define HUD_DELAY 1.0
typedef enum {
    Photos,
    Lineup,
    SongPreview,
    Details,
    NumberOfRows
} ECPastRow;

@implementation ECPastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.''
    self.eventName.text = [[self.concert eventName] uppercaseString];
    self.eventVenueAndDate.text = [self.concert venueAndDate];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self setAppearance];
    [ECJSONFetcher fetchSongPreviewForArtist:[self.concert headliner] completion:^(NSDictionary *song) {
        self.songInfo = [[NSDictionary alloc] initWithDictionary:song];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:SongPreview inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}
-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        [self.player pause];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super viewWillDisappear:animated];
}

-(void) viewWillAppear:(BOOL)animated {
    if(!self.statusManager) {
        self.statusManager = [[ECEventProfileStatusManager alloc] init];
    }
    self.statusManager.eventID = self.concert.eventID;
    [self.statusManager setDelegate:self];
    [self.statusManager checkProfileState];
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
    
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"];
//    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
//    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
//    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
//    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem = shareButton;
    
    self.tableView.separatorColor = [UIColor separatorColor];
    
}

#pragma mark - status delegate 
-(void) profileState:(BOOL)isOnProfile {
    [self.iwasthereButton setButtonIsOnProfile:isOnProfile];
   // self.iwasthereButton.titleLabel.text = isOnProfile ? @"YES" : @"NO";
    
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case Details:
            return 75.0f;
        case Lineup:
            return 142.0f;
        case SongPreview:
            return 76;
        case Photos:
            return 74.0f;
        default:
            return 0.0f;
    }
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NumberOfRows;
}

+(NSString*) identifierForRow: (NSUInteger) row {
    switch (row) {
        case Details:
            return @"details";
        case Lineup:
            return @"lineup";
        case Photos:
            return @"photos";
        case SongPreview:
            return @"songpreview";
        default:
            return nil;
    }
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = [ECPastViewController identifierForRow:indexPath.row];
    
    switch (indexPath.row) {
        case Details: {
            DetailsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[DetailsCell alloc] init];
            }
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            cell.changeStateButton.titleLabel.font = [UIFont heroFontWithSize:20];
            cell.changeStateButton.layer.cornerRadius = 5.0;
            cell.changeStateButton.layer.masksToBounds = YES;
            [cell.changeStateButton addTarget:self action:@selector(addToProfile) forControlEvents:UIControlEventTouchUpInside];
            self.iwasthereButton = cell.changeStateButton;
            [self.iwasthereButton setButtonIsOnProfile:self.statusManager.isOnProfile];
            
            return cell;
        }
        case Lineup: {
            LineupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[LineupCell alloc] init];
            }
            cell.lineupLabel.font = [UIFont lightHeroFontWithSize:16];
            cell.lineup = self.concert.lineup;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            cell.navController = self.navigationController;
            cell.previousArtist = self.previousArtist;
            return cell;
        }
        case Photos: {
            GetPhotosCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[GetPhotosCell alloc] init];
            }
            
            cell.grabPhotosButton.titleLabel.font = [UIFont heroFontWithSize:16];
            cell.grabPhotosButton.layer.cornerRadius = 5.0;
            cell.grabPhotosButton.layer.masksToBounds = YES;
             if(self.hideShareButton){
                 [cell.shareButton removeFromSuperview];
             }else{
                 [cell.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
             }
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            return cell;
        }
        case SongPreview:{
            SongPreviewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[SongPreviewCell alloc] init];
            }
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            cell.lblMusicTitle.font = [UIFont lightHeroFontWithSize:16];
            
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
            [cell.lblSongName setText:self.songInfo[@"collectionCensoredName"]];

            if(self.player.rate == 1.0){
                [cell.btnPlay setSelected:YES];
            }
            return cell;
        }
        default:
            return nil;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PastViewControllerToGridViewController"]) {
        ECGridViewController* vc = [segue destinationViewController];
        vc.concert = self.concert;
        vc.hideShareButton = self.hideShareButton;
        [Flurry logEvent:@"Tapped_See_Photos_Past" withParameters:[self flurryParam]];
    }
}
#pragma mark FB Sharing
-(void) shareTapped {
    NSString* eventName = [self.concert eventName];
    NSString* the = @"the ";
    NSString* substring = [[eventName substringToIndex:3]lowercaseString];
    if ([substring isEqualToString:@"the"]) {
        the = @"";
    }
    NSString* shareText = [NSString stringWithFormat: @"Check out these photos and videos on Encore from %@%@ show at %@, %@.",the,[self.concert eventName],[self.concert venueName],[self.concert niceDate]];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
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
//    if([ApplicationDelegate isLoggedIn]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
//        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
//        [Flurry logEvent:@"Share_Tapped_Concert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"pastvc",@"source",self.concert.eventID,@"eventID", self.concert.eventName, @"eventName", nil]];
//        [self share];
//    }
//    else {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To share this concert, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
//        alert.tag = ECShareNotLoggedInAlert;
//        [alert show];
//    }
}

//currently not in use, replaced with multishare
-(void) share {
    [self shareWithTaggedFriends:nil];
}

-(void) shareWithTaggedFriends: (NSArray*) taggedFriends {
    NSLog(@"Sharing with Facebook from Concert detail view controller");
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
    
    FBShareDialogParams* params = [[FBShareDialogParams alloc] init];
    params.link = url;
    if(taggedFriends)
        [params setFriends:[taggedFriends valueForKey:@"id"]];
    
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                NSLog(@"Error sharing concert: %@", error.description);
                [Flurry logEvent:@"Concert_Share_To_FB_Fail" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", error.description, @"error", nil]];
            } else {
                NSLog(@"Success sharing concert!");
                [Flurry logEvent:@"Concert_Share_To_FB_Success" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", nil]];
            }
            
        }];
    }
    else {
        NSMutableDictionary *params2 =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%@ on Encore",[self.concert eventName]], @"name",
         [NSString stringWithFormat:@"Check out photos and videos from %@'s %@ show on Encore.",[self.concert eventName], [self.concert niceDate]], @"caption",
         @"Encore is a free iPhone concert app that collects photos and videos from live shows and helps you keep track of upcoming shows in your area.",@"description",
         [NSString stringWithFormat:ShareConcertURL,self.concert.eventID], @"link",
         [NSString stringWithFormat:@"%@",[self.concert imageURL].absoluteString], @"picture",
         nil];
        [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                               parameters:params2
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                     } else {
                         // User clicked the Share button
                         NSString *msg = @"Posted to facebook";
                         NSLog(@"%@", msg);
                         [Flurry logEvent:@"Successfully_Posted_To_Facebook_With_Feed_Dialog" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Concert",@"type", nil]];
                         // Show the result in an alert
                         [[[UIAlertView alloc] initWithTitle:@"Result"  //TODO: replace with HUD
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil]
                          show];
                     }
                 }
             }
         }];
    }
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
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

#pragma mark AlertView delegate

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
#pragma mark - Play/Pause Song preview

- (void) playpauseButtonTapped:(UIButton*)button
{
    if(!self.player){
        NSURL *url = [NSURL URLWithString:self.songInfo[@"previewUrl"]];
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    }
    [button setSelected:!button.selected];
    if (self.player.rate == 1.0) {
        [self.player pause];
    } else {
        [self.player play];
    }
    
}
-(void)songDidFinishPlaying
{
    SongPreviewCell * songCell =(SongPreviewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:SongPreview inSection:0]];
    [songCell.btnPlay setSelected:NO];
}

-(void)openItunesLink
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: self.songInfo[@"collectionViewUrl"]]];
    
}

#pragma mark - Adding/Removing Concerts

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
    [self.iwasthereButton setButtonIsOnProfile:isOnProfile];
    [self concertStateChangedHUD];
    
    if([self.eventStateDelegate respondsToSelector:@selector(profileUpdated)])
        [self.eventStateDelegate profileUpdated];
    
    [Flurry logEvent:@"Completed_Adding_Concert" withParameters:[self flurryParam]];
    

}
-(void) failedToChangeState: (BOOL) isOnProfile;
{
    [self alertError];
    [self.iwasthereButton setButtonIsOnProfile:isOnProfile];
    [Flurry logEvent:@"Failed_Adding_Concert" withParameters:[self flurryParam]];

}



-(void) alertError {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, an error occured and your request was not processed.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



-(NSDictionary*) flurryParam {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.concert.eventID,@"eventID",self.concert.eventName,@"eventName", nil];
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



@end
