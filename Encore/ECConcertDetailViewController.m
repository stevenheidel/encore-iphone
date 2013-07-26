//
//  ECConcertDetailViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import "EncoreURL.h"
#import <QuartzCore/QuartzCore.h>
#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"
#import "Cell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDictionary+Posts.h"
#import "ECJSONPoster.h"
#import "ECJSONFetcher.h"

#import "ATAppRatingFlow.h"

#import "ECPostViewController.h"
//#import "ECMainViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ECPostCollectionHeaderView.h"
#import "ECCollectionViewFlowLayout.h"

#import "ECAppDelegate.h"

#import "UIImage+GaussBlur.h"
#import "NSUserDefaults+Encore.h"
#import "MBProgressHUD.h"

#import "ECPictureViewController.h"

#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

#import "ECAlertTags.h"

#import "UIViewController+KNSemiModal.h"
#import "KNMultiItemSelector.h"
#import  "ECCustomNavController.h"
#define HUD_DELAY 1.0
#define HEADER_HEIGHT 150.0
#define HEADER_HEIGHT_PLUS_ONE_LINE 172.0
#define HEADER_HEIGHT_PLUS_TWO_LINES 195.0

#import "ECAppDelegate.h"

#import "SAMRateLimit.h"

NSString *kCellID = @"cellID";

@interface ECConcertDetailViewController (){
    NSInteger numTimesGetStuffPressed;
}
@property (assign) BOOL isExpanded;
@end

@implementation ECConcertDetailViewController

#pragma mark Inits
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id) initWithConcert:(NSDictionary *)concert {
    self = [super init];
    if (self) {
        self.concert = concert;
    }
    return self;
}

-(NSString*) userID {
    return [NSUserDefaults userID];
}

#pragma mark - View Setup
- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@: did load",NSStringFromClass(self.class));
    self.isOnProfile = FALSE;
    self.isPopulating = FALSE;
    self.isExpanded = FALSE;
    numTimesGetStuffPressed = 0;
    [self.collectionView registerClass:[Cell class] forCellWithReuseIdentifier:@"generic"];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
    self.headerView = [[ECPostCollectionHeaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.collectionView.frame.size.width, HEADER_HEIGHT) andOwner:self];
    
    UITapGestureRecognizer* recognizerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapArtistPhoto)];
    recognizerTap.numberOfTapsRequired = 1;
    recognizerTap.numberOfTouchesRequired = 1;
    [self.imgArtist addGestureRecognizer:recognizerTap];
    
    [self setupArtistUIAttributes];

    [self setUpNavBarButtons];
    [self loadArtistDetails];
    [self setUpPlaceholderView];
    if (self.tense != ECSearchTypeFuture) {
        [self loadImages];
    }
    
    if (ApplicationDelegate.isLoggedIn) {
        [ECJSONFetcher checkIfConcert:[self.concert eventID] isOnProfile:self.userID completion:^(BOOL isOnProfile) {
            self.isOnProfile = isOnProfile;
            [self setImageForConcertStatusButton];
            [self updatePlaceholderText];
        }];
    }
    
    self.view.clipsToBounds = YES;
    self.collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    [(UILabel*)[self.footerIsPopulatingView viewWithTag:49] setFont:[UIFont heroFontWithSize:14]];
    
    [self setupRefreshControl];
    friends = [[NSMutableArray alloc] init];
}

-(void) setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadImages)
                  forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.tintColor = [UIColor lightBlueNavBarColor];
}

-(void) setupArtistUIAttributes {
    //    [self.artistNameLabel setAdjustsFontSizeToFitWidth:YES];
    self.artistNameLabel.font = [UIFont heroFontWithSize: 16.0];
    self.artistNameLabel.textColor = [UIColor blueArtistTextColor];
    
    //    [self.venueNameLabel setAdjustsFontSizeToFitWidth:YES];
    self.venueNameLabel.font = [UIFont heroFontWithSize: 14.0];
    self.dateLabel.font = [UIFont heroFontWithSize: 12.0];
    self.imgArtist.layer.cornerRadius = 5.0;
    self.imgArtist.layer.masksToBounds = YES;
    self.imgArtist.layer.borderColor = [UIColor grayColor].CGColor;
    self.imgArtist.layer.borderWidth = 0.1;
}


-(void) setUpNavBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = self.shareButton;
}

-(void) viewWillAppear:(BOOL)animated {
    [self togglePopulatingIndicator];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopTimer];
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) loadArtistDetails {
    self.artistNameLabel.text = [[self.concert eventName] uppercaseString];
    self.venueNameLabel.text = [self.concert venueName];
    self.artistsLabel.text = [[self.concert artists] componentsJoinedByString:@","];

    if([[self.concert eventName] isEqualToString:[self.concert headliner]])
       [self.headlinerLabel removeFromSuperview];
    else
        self.headlinerLabel.text = [self.concert headliner];

    
    if([self.artistsLabel.text isEqualToString:@""])
        [self.artistsLabel removeFromSuperview];

    self.dateLabel.text = [NSString stringWithFormat:@"%@, %@", [self.concert venueName], [self.concert niceDate]];
    
    NSURL *imageURL = [self.concert imageURL];
    if (imageURL) {
        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        
        if (regImage) {
            self.imgArtist.image = regImage;
            self.imgBackground.image = [regImage imageWithGaussianBlur];
        } else {
            self.imgBackground.image = [UIImage imageNamed:@"Black"];
            self.imgArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
        }
    } else {
        self.imgBackground.image = [[UIImage imageNamed:@"Black"] imageWithGaussianBlur];
        self.imgArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
    }
}

-(void) loadImages {
    NSString* serverID = [self.concert eventID];
    if (serverID) {
        [ECJSONFetcher fetchPostsForConcertWithID:serverID completion:^(NSArray *fetchedPosts) {
            [self fetchedPosts:fetchedPosts];
        }];
    }
    else {
        NSLog(@"%@: Can't load images, object doesn't have a server_id", NSStringFromClass([self class]));
    }
}

-(void) fetchedPosts: (NSArray *) posts {
    self.posts = posts;
    if ([self.posts count] > 0) {
        [self.placeholderView removeFromSuperview];
    }
    else {
        [self setUpPlaceholderView];
    }
    
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    if([self.posts count] > 0 && self.savedPosition.y != 0) {
        //retain scroll position of view
        self.collectionView.contentOffset = self.savedPosition;
    }
    if (self.refreshControl.refreshing) {
        [self.refreshControl endRefreshing];
    }
}


#pragma mark -
//check if concert is populating and setup 
-(void) checkIfPopulating {
    if(self.tense != ECSearchTypeFuture) { //don't search for posts if the event hasn't happened yet
        [ECJSONFetcher checkIfEventIsPopulating:[self.concert eventID] completion:^(BOOL isPopulating) {
            self.isPopulating = isPopulating;
            [self togglePopulatingIndicator];
            if(!self.posts.count>0){
               [self updatePlaceholderText];
            }
            if(!self.isPopulating) {
                [self stopTimer];
                if(!self.posts.count >0)
                    [self.getStuffButton setEnabled:YES];
            }
        }];
    }
    else {
        NSLog(@"ECConcertDetailViewController: Not checking if populating because concert is in the future");
        [self stopTimer];
    }
}

-(void) togglePopulatingIndicator {
    [UIView animateWithDuration:0.5 animations:^{
        self.footerIsPopulatingView.alpha = self.isPopulating ? 1.0 : 0.0;
    } completion:nil];
    if(self.isPopulating) {
        [self.footerActivityIndicator startAnimating];
    }
    if (self.isPopulating && self.timer == nil) {
        [self startTimer];
    }
}

-(void) clearCollectionView { //old
    self.posts = nil;
    [self.collectionView reloadData];
}

//Toggle whether or not the profile is on the user's profile.
-(void) toggleOnProfileState {
    self.isOnProfile = !self.isOnProfile;
    [self setImageForConcertStatusButton];
    [self updatePlaceholderText];
}

-(void) setImageForConcertStatusButton {
    if (self.isOnProfile) {
        [self.concertStausButton setImage:[UIImage imageNamed:@"removeEventButton"] forState:UIControlStateNormal];
    }
    else {
        [self.concertStausButton setImage:[UIImage imageNamed:@"addEventButton.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Timer (repeatedly checking populating/loading)
-(void) startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(timerFire)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void) stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

-(void) timerFire {
    NSLog(@"Timer Fired");
    [self checkIfPopulating];
    if (self.posts.count>0) {
        self.savedPosition = self.collectionView.contentOffset;
    }
    else {
        
    }
    [self loadImages];
}

#pragma mark - Interactions
-(void) tapArtistPhoto {
    [Flurry logEvent:@"Tapped_Artist_Photo_DetailVC"];
    [self togglePopulatingIndicator];
}

- (IBAction)getStuff {
    if(self.tense == ECSearchTypeFuture)
    {
        //TODO: Buy ticket
        NSLog(@"Buy ticket");
        [Flurry logEvent:@"Clicked_Buy_Ticket" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self.concert eventName], @"eventName",[self.concert eventID], @"eventID", [self.concert headliner], @"headliner", nil]];
        NSURL* lastfmURL = [self.concert lastfmURL];
        [[UIApplication sharedApplication] openURL:lastfmURL];
    }
    else {
        
        numTimesGetStuffPressed++;
        [Flurry logEvent:@"Find_Photos_and_Videos_Pressed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self.concert eventID],@"eventID", [NSNumber numberWithInteger:numTimesGetStuffPressed], @"num_times_pressed", nil]];
        [SAMRateLimit executeBlock:^{
            NSLog(@"here");
            [ECJSONPoster populateConcert:[self.concert eventID] completion:^(BOOL success) {
                [self checkIfPopulating];
                self.getStuffButton.enabled = NO;
            }];
        } name:@"GetStuff" limit:5.0];
    }
}

#pragma mark FB Sharing
-(void) shareTapped {
    if([ApplicationDelegate isLoggedIn]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
        [Flurry logEvent:@"Share_Tapped_Concert"];
        [self share];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To share this concert, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECShareNotLoggedInAlert;
        [alert show];
    }
}

-(void) share {
    [self shareWithTaggedFriends:nil];
}

-(void) shareWithTaggedFriends: (NSArray*) taggedFriends {
    NSLog(@"Sharing with Facebook from Concert detail view controller");
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.eventID]];
    
    FBShareDialogParams* params = [[FBShareDialogParams alloc] init];
    params.link = url;
    if(taggedFriends)
        [params setFriends:[taggedFriends valueForKey:@"id"]];

    //    params.description =  [NSString stringWithFormat:@"Check out photos and videos from %@'s %@ show in %@ at the %@ on Encore.",[self.concert artistName], [self.concert niceDate], [self.concert city], [self.concert venueName]];
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
         [NSString stringWithFormat:ShareConcertURL,self.eventID], @"link",
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


#pragma mark - Adding/Removing Concerts

-(IBAction) addToProfile {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    if (!self.isOnProfile) {
        [self addConcert];
    }
    else {
        [self removeConcert];
    }
}

-(void) addConcert {
    if (ApplicationDelegate.isLoggedIn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];

        //        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_add_title", nil) message:NSLocalizedString(@"confirm_add_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"add", nil), nil];
        //        alert.tag = AddConcertConfirmTag;
        //        [alert show];
        //
        NSString * userID = self.userID;
        NSString * eventID = [self.concert eventID];
        NSLog(@"%@: Adding concert %@ to profile %@", NSStringFromClass(self.class), eventID, userID);
        [Flurry logEvent:@"Added_Concert" withParameters:[self flurryParam]];
        
        [ECJSONPoster addConcert:eventID toUser:userID completion:^(BOOL success) {
            if (success) {
                [self completedAddingConcert];
                [Flurry logEvent:@"Completed_Adding_Concert" withParameters:[self flurryParam]];
                [self checkIfPopulating];
                [self startTimer];
            }
            else {
                [self alertError];
            }
        }];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"You must be logged in to add a concert to your profile", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECNotLoggedInAlert;
        [alert show];
    }
}

-(void) removeConcert {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    if (ApplicationDelegate.isLoggedIn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];

        [Flurry logEvent:@"Tapped_Remove_Concert" withParameters:[self flurryParam]];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_remove_title", nil) message:NSLocalizedString(@"confirm_remove_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"remove", nil), nil];
        alert.tag = RemoveConcertConfirmTag;
        [alert show];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"You must be logged in to remove a concert from your profile", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECNotLoggedInAlert;
        [alert show];
    }
}
//-(void) addConcert {
//
//    [Flurry logEvent:@"Tapped_Add_Concert" withParameters:[self flurryParam]];
//    
//    if([ApplicationDelegate isLoggedIn];) {
////        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"confirm_add_title", nil) message:NSLocalizedString(@"confirm_add_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"add", nil), nil];
////        alert.tag = AddConcertConfirmTag;
////        [alert show];
////
//        KNMultiItemSelector * selector = [[KNMultiItemSelector alloc] initWithItems:friends
//                                                                   preselectedItems:nil
//                                                                              title:@"Who else went?"
//                                                                    placeholderText:@"Search by name"
//                                                                           delegate:self];
//        
//        [selector.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0.0f,1.0f)],UITextAttributeTextShadowOffset, [UIFont systemFontOfSize:12.0f], UITextAttributeFont, nil]];
//        
//        selector.allowSearchControl = YES;
//        selector.useTableIndex      = YES;
//        selector.useRecentItems     = YES;
//        selector.maxNumberOfRecentItems = 4;
//        UINavigationController * uinav = [[UINavigationController alloc] initWithRootViewController:selector];
//        uinav.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        uinav.modalPresentationStyle = UIModalPresentationFormSheet;
//        [self presentViewController:uinav animated:YES completion:nil];
//    }
//    else {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"You must be logged in to add a concert to your profile", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
//        alert.tag = ECNotLoggedInAlert;
//        [alert show];
//    }
//}
-(void) loadAndSelectFriends {
    if(friends.count ==0) {
        [[FBRequest requestForMyFriends]  startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if(!error)
             {
                 NSDictionary * rawObject = result;
                 NSArray * dataArray = [rawObject objectForKey:@"data"];
                 for (NSDictionary * f in dataArray) {
                     [friends addObject:[[KNSelectorItem alloc] initWithDisplayValue:[f objectForKey:@"name"]
                                                                         selectValue:[f objectForKey:@"id"]
                                                                            imageUrl:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [f objectForKey:@"id"]]]];
                 }
                 [friends sortUsingSelector:@selector(compareByDisplayValue:)];
                 [self selectFriends];
             }else{
                 NSLog(@"Facebook request error: %@",error.debugDescription);
             }
         }];
    }
    else {
        [self selectFriends];
    }
    //TODO start HUD
}



-(void) selectFriends {
    
    NSString* title = nil;
    switch (self.tense) {
        case ECSearchTypeToday:
        case ECSearchTypeFuture:
            title = @"Who else is going?";
            break;
        case ECSearchTypePast:
            title = @"Who else went?";
            break;
        default:
            break;
    }
    KNMultiItemSelector * selector = [[KNMultiItemSelector alloc] initWithItems:friends
                                                               preselectedItems:nil
                                                                          title:title
                                                                placeholderText:@"Search by name"
                                                                       delegate:self];
    
    [selector.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, [UIColor clearColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0.0f,1.0f)],UITextAttributeTextShadowOffset, [UIFont systemFontOfSize:12.0f], UITextAttributeFont, nil]];
    
    selector.allowSearchControl = YES;
    selector.useTableIndex      = YES;
    selector.useRecentItems     = YES;
    selector.maxNumberOfRecentItems = 4;
    ECCustomNavController * uinav = [[ECCustomNavController alloc] initWithRootViewController:selector];
    uinav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    uinav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:uinav animated:YES completion:nil];
}

#pragma mark KNMultiItemSelectorDelegate methods
-(void)selectorDidCancelSelection {
    [self dismissViewControllerAnimated:YES completion:^{
        [Flurry logEvent:@"Cancelled_Sharing_From_Friend_Picker"];
    }];
}
-(void) selectorDidFinishSelectionWithItems:(NSArray *)selectedItems {
    [self dismissViewControllerAnimated:YES completion:^{
        [Flurry logEvent:@"Added_Friends_To_Concert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self.concert eventName],@"artist", [self.concert eventID],@"eventID", [NSNumber numberWithInt: selectedItems.count], @"friend_count", nil]];
        
        NSLog(@"Sharing: Tagged %d friends",selectedItems.count);
        if (selectedItems.count == 0) {
            return;
        }
        NSMutableArray* taggedFriends = [[NSMutableArray alloc] initWithCapacity:selectedItems.count];
//        NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:nil];
//        NSMutableString* ids = [NSMutableString stringWithString:@""];
        for (KNSelectorItem * i in selectedItems) {
            [taggedFriends addObject:[NSDictionary dictionaryWithObjectsAndKeys:i.selectValue, @"id", i.displayValue, @"name", nil]];
//            [ids appendString:[NSString stringWithFormat:@"%@,",i.selectValue]];
        }
//        [params setObject:ids forKey:@"to"];
        
        [self shareWithTaggedFriends:taggedFriends];

    }];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
//        [self.navigationController popToRootViewControllerAnimated:NO];
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
           // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToProfile) name:ECLoginCompletedNotification object:nil];

        }
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Detail_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
        return; //don't process other alerts
    }else if (alertView.tag == ECShareNotLoggedInAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareTapped) name:ECLoginCompletedNotification object:nil];
            
        }
    }
    
    
    if (alertView.tag == AddConcertConfirmTag || alertView.tag == RemoveConcertConfirmTag) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            NSString * userID = self.userID;
            NSString * eventID = [self.concert eventID];
            switch (alertView.tag) {
                case AddConcertConfirmTag: {
                    [self addConcert];

                    break;
                }
                case RemoveConcertConfirmTag: {
                    [Flurry logEvent:@"Confirmed_Remove_Concert" withParameters:[self flurryParam]];
                    
                    NSLog(@"%@: Removing a concert %@ from profile %@", NSStringFromClass(self.class), eventID, userID);
                    [ECJSONPoster removeConcert:eventID toUser:userID completion:^(BOOL success) {
                        if(success) {
                            [self completedRemovingConcert];
                        }
                        else {
                            [self alertError];
                        }
                        [Flurry logEvent:@"Completed_Removing_Concert" withParameters:[self flurryParam]];
                    }];
                    break;
                }
                default:
                    break;
            }
        }
        else {
            [Flurry logEvent:@"Canceled_Adding_or_Removing_Concert" withParameters:[self flurryParam]];
        }
        return;
    }
}

-(void) alertError {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, an error occured and your request was not processed.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void) completedAddingConcert {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.labelText = NSLocalizedString(@"concert_added",nil);
    HUD.color = [UIColor lightBlueHUDConfirmationColor];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
    [self toggleOnProfileState];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (HUD_DELAY-0.5) * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        [self loadAndSelectFriends];
    });

}

-(void) completedRemovingConcert {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.navigationController.view addSubview:HUD];
	
	// TODO replace with our own or a free X icon
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.labelText = NSLocalizedString(@"concert_removed", nil);
    HUD.color = [UIColor redHUDConfirmationColor];
	[HUD show:YES];
	[HUD hide:YES afterDelay:HUD_DELAY];
    
    [self toggleOnProfileState];
}

#pragma mark - collection view delegate/data source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.posts count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    Cell *cell = (Cell*)[cv dequeueReusableCellWithReuseIdentifier:@"generic" forIndexPath:indexPath];
    
    
    // load the image for this cell
    if(!cell.image) {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
        cell.image=imageView;
        cell.contentView.clipsToBounds = YES;
    }
    if(self.posts.count > 0) {
        NSDictionary * postDic = [self.posts objectAtIndex:indexPath.row];
        NSURL *imageToLoad = [postDic imageURL];
        [cell.image setImageWithURL:imageToLoad];
        
        cell.postType = [postDic postType];
    }
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    ECPostViewController * postVC = [[ECPostViewController alloc]initWithPost: [self.posts objectAtIndex:indexPath.item]];
    postVC.itemNumber = indexPath.item;
    postVC.delegate = self;
    postVC.artist = [self.concert eventName];
    postVC.venueAndDate = [self.concert venueAndDate];
    [self.navigationController pushViewController:postVC animated:YES];
}

-(UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView* reusableView = nil;

    if (kind == UICollectionElementKindSectionHeader) {
        reusableView = self.headerView;
    }
    return reusableView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    CGFloat height = HEADER_HEIGHT_PLUS_TWO_LINES;
    if((!self.artistsLabel && self.headlinerLabel) || (self.artistsLabel && !self.headlinerLabel))
        height = HEADER_HEIGHT_PLUS_ONE_LINE;
    else if (!self.artistsLabel && !self.headlinerLabel)
        height = HEADER_HEIGHT;
    
    if(self.isExpanded)
        height +=[self.artistsLabel.text sizeWithFont:[UIFont systemFontOfSize:12]
                                    constrainedToSize:CGSizeMake(280, 100)
                                        lineBreakMode:NSLineBreakByTruncatingTail].height;

        
    //Manually set to desired height
    return CGSizeMake(self.collectionView.frame.size.width, height);
}

-(void) setUpPlaceholderView {
    if(!self.placeholderView){
        
        //Manually set the height of the placeholder view so it fits in under the collection view's header (so that the header scrolls out of the way when you're searching through posts
        //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
        
        self.placeholderView = [[ECPlaceHolderView alloc] initWithFrame:CGRectMake(0.0, HEADER_HEIGHT, self.collectionView.frame.size.width, self.collectionView.frame.size.height-HEADER_HEIGHT) owner: self];
        UITapGestureRecognizer* recognizerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlaceholder)];
        recognizerTap.numberOfTapsRequired = 1;
        recognizerTap.numberOfTouchesRequired = 1;
        [self.placeholderView addGestureRecognizer:recognizerTap];
    }
    
    [self updatePlaceholderText];
    if(self.tense == ECSearchTypeFuture)
    {
        [self.getStuffButton setImage:[UIImage imageNamed:@"ticketsbutton"] forState:UIControlStateNormal];
        [self.getStuffButton setImage:[UIImage imageNamed:@"ticketsbutton"] forState:UIControlStateHighlighted];

    }
    //self.getStuffButton.hidden = self.tense == ECSearchTypeFuture;
    self.getStuffButton.enabled = YES;
    
    if(!self.placeholderView.superview) {
        [self.view addSubview:self.placeholderView];
    }
}
-(void) tapPlaceholder {
   if (self.isPopulating) {
        [self loadImages];
    }
}
-(void) updatePlaceholderText {
    NSLog(@"ECConcertDetailViewController: update placeholder text called");
    NSString* placeHolderText = nil;
    
    if (!self.isOnProfile) {
        if(self.tense == ECSearchTypePast){
            placeHolderText = @"Add the concert to your profile by clicking the + sign above.";
        }
        if (self.tense == ECSearchTypeFuture) {
            placeHolderText = @"Add this concert to your profile by clicking the + sign above and check back again soon for some awesome stuff";
        }
        if (self.tense == ECSearchTypeToday) {
            placeHolderText = @"Concert is today! Hooray! I can almost smell the photos and videos. Oh wait, that's BO.";
        }
    }
    else if (self.isPopulating) {
        placeHolderText = nil;//@"Images are still loading, please check back again soon! Tap here to check again.";
    }
    else {
        placeHolderText = @"Sorry, no content for this concert yet :(";
    }
    self.placeholderView.label1.text = placeHolderText;
}

#pragma mark - ADDING PHOTOS (currently not used)
-(IBAction)addPhoto {
    [Flurry logEvent:@"Tapped_Add_Photo" withParameters:[self flurryParam]];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Post photo" delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"pick_from_lib", nil),[UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ? NSLocalizedString(@"new_from_camera", nil):nil, nil];
    actionSheet.tag = PhotoSourcePickerTag;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

#pragma mark Action Sheet Delegate
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == PhotoSourcePickerTag ) {
        NSString* selectedSource;
        UIImagePickerControllerSourceType sourceType;
        if(buttonIndex != actionSheet.cancelButtonIndex){
            selectedSource = [actionSheet buttonTitleAtIndex:buttonIndex];
            if ([selectedSource isEqualToString:NSLocalizedString(@"new_from_camera", nil)]) {
                sourceType = UIImagePickerControllerSourceTypeCamera;
            }
            else sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self showImagePickerForSourceType: sourceType];
        }
        else {
            [Flurry logEvent:@"Canceled_Photo_Adding" withParameters:[self flurryParam]];
        }
    }
}

-(void) showImagePickerForSourceType: (UIImagePickerControllerSourceType) sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if(sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.showsCameraControls = YES;
        [Flurry logEvent:@"Showed_Camera" withParameters:[self flurryParam]];
    }
    else {
        [Flurry logEvent:@"Showed_Photo_Library" withParameters:[self flurryParam]];
    }
    self.imagePickerController = imagePickerController;
    [self presentViewController: self.imagePickerController animated:YES completion: nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [Flurry logEvent:@"Finished_Picking_Image" withParameters:[self flurryParam]];
    UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:^{
        ECPictureViewController* pictureVC = [[ECPictureViewController alloc] initWithImage:image];
        pictureVC.delegate = self;
        [self presentViewController:pictureVC animated:NO completion:nil];
    }];
}

#pragma mark Picture View Controller Delegate
-(void) postImage:(UIImage *)image {
    NSDictionary * imageDic = [NSDictionary dictionaryWithObjectsAndKeys:image, @"image",[self eventID], @"concert", self.userID, @"user", nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    [ECJSONPoster postImage: imageDic completion:^{
        NSLog(@"Completed posting image!");
        MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [HUD setColor:[UIColor lightBlueHUDConfirmationColor]];
        [HUD show:YES];
        [HUD hide:YES afterDelay:HUD_DELAY];
        [Flurry logEvent:@"Completed_Posting_Image" withParameters:[self flurryParam]];
    }];
}
-(NSDictionary*) flurryParam {
    return self.concert;
}
#pragma mark - PostViewControllerDelegate (swipe transitions between posts)

-(NSDictionary*) requestPost:(NSInteger)direction currentIndex:(NSInteger)index {
    if(self.posts.count <= 1) { //if only one or zero posts, no need to switch
        return nil;
    }
    
    NSInteger newIndex = index + direction;
    if (newIndex < 0) {
        newIndex = self.posts.count - 1; //loop to the end
    }
    else if (newIndex >= self.posts.count) {
        newIndex = 0;  //loop to the beginning
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[self.posts objectAtIndex:newIndex], @"dic", [NSNumber numberWithInt:newIndex], @"index",nil];
}

#pragma mark - getters
//Property readonly getter to grab id in a slightly shorter way
-(NSString*) eventID {
    return [self.concert eventID];
}


-(ECAppDelegate*) appDelegate {
    return (ECAppDelegate *)[UIApplication sharedApplication].delegate;
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

- (IBAction)artistsLabelTapped:(id)sender {
        
    CGSize artistTextSize = [self.artistsLabel.text sizeWithFont:[UIFont systemFontOfSize:12]
                                                  constrainedToSize:CGSizeMake(280, 100)
                                                      lineBreakMode:NSLineBreakByTruncatingTail];
    
    //if the size of the text is bigger than the label size EXPAND 
    if(!self.isExpanded && (artistTextSize.height > self.artistsLabel.bounds.size.height))
    {
        self.isExpanded = TRUE;
       
        [UIView animateWithDuration:0.4 animations:^{
            [self.artistsLabel setNumberOfLines:0];
            [self.artistLabelConstraint setConstant:artistTextSize.height];
         }];
        [self.collectionView reloadData];

    }else if(self.isExpanded)
    {
        
        self.isExpanded = FALSE;
        [UIView animateWithDuration:0.2 animations:^{
            [self.artistsLabel setNumberOfLines:0];
            [self.artistLabelConstraint setConstant:21];
        }];
        [self.collectionView reloadData];

    }
    
    

}
@end

#pragma mark -
@implementation ECPlaceHolderView

-(id) initWithFrame:(CGRect)frame owner: (id) owner {
    if (self = [super initWithFrame:frame]){
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECPostPlaceholder" owner:owner options:nil];
        self = [subviewArray objectAtIndex:0];
        self.frame = frame;
        self.label1.font = [UIFont heroFontWithSize: 18.0];
        
//        self.label2.font = [UIFont heroFontWithSize: 18.0];
        
//        self.label1.text = NSLocalizedString(@"POST_PLACEHOLDER_TEXT_1", nil);
//        self.label2.text = NSLocalizedString(@"POST_PLACEHOLDER_TEXT_2", nil);
        
//        self.button.titleLabel.font = [UIFont heroFontWithSize: 22.0];
    }
    return self;
}

@end
