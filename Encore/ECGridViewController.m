//
//  ECGridViewController.m
//  
//
//  Created by Shimmy on 2013-08-08.
//
//

#import "ECGridViewController.h"
#import "NSDictionary+ConcertList.h"
#import "NSDictionary+Posts.h"
#import "ECJSONFetcher.h"
#import "ECJSONPoster.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"
#import "ECPostViewController.h"
#import "ECAppDelegate.h"
#import "ECAlertTags.h"
#import "EncoreURL.h"
#import "MBProgressHUD.h"
#import "CMPopTipView.h"

#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "RDActivityViewController.h"

static const NSTimeInterval kInitialCheckConcertDelay = 5.0;
static const NSTimeInterval kSubsequentCheckConcertPopulatingDelay = 2.0;
typedef enum {
    NoPostsAlertTag
}GridVcAlertTags;
@implementation ECPostCell

-(void) setPostType:(ECPostType)postType {
    _postType = postType;
    self.playButton.hidden = postType != ECVideoPost;
}

@end

@implementation ECGridHeaderView

@end


@interface ECGridViewController () <UIAlertViewDelegate,CMPopTipViewDelegate> {
    BOOL _isPopulating;
    BOOL responseReceived;
    ECGridViewController* threeColVersion;
}
@property(strong) NSTimer* timer;
@end

@implementation ECGridViewController

#pragma mark Autorotation
-(BOOL)shouldAutorotate{
    if(self.interfaceOrientation ==  UIInterfaceOrientationMaskPortrait || self.interfaceOrientation ==  UIInterfaceOrientationMaskPortraitUpsideDown )
    return YES;
    else
        return NO;
}



-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _isPopulating = NO;
    responseReceived = NO;
    if (self.posts.count == 0) {
        [self loadConcertImages: YES];
    }
    
    [self setupLogo];
    
    self.postsCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
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

    if(!self.hideShareButton) {
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *rightButImage = [UIImage imageNamed:@"shareButton"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
        rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
        UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        self.navigationItem.rightBarButtonItem = shareButton;
    }
}

-(void) setupLogo {
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    encoreLogo.userInteractionEnabled = YES;
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navTap)];
    tapRecognizer.numberOfTapsRequired = 2;
    [encoreLogo addGestureRecognizer:tapRecognizer];
    self.navigationItem.titleView = encoreLogo;
}

-(void) hideToolTip: (CMPopTipView*) tooltip {
    [tooltip dismissAnimated:YES];
}

-(void) navTap {
    if (self.posts.count == 0) {
        return;
    }
    if (self.isSingleColumn) {
        if (!threeColVersion) {
            threeColVersion = [[UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"ECGridViewController2"];
            threeColVersion.concert = self.concert;
            threeColVersion.isSingleColumn = NO;
            threeColVersion.posts = self.posts;
            threeColVersion.concertDetailPage = self.concertDetailPage;
            threeColVersion.backButtonShouldGlow = self.backButtonShouldGlow;
        }
        [self.navigationController pushViewController:threeColVersion animated:NO];

    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    [Flurry logEvent:@"GridViewControllerNavTap" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:self.isSingleColumn], @"selfIsSingleCol",nil]];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void) viewWillDisappear:(BOOL)animated {
    [self.timer invalidate];
}

-(void) backButtonWasPressed {
    if (self.concertDetailPage) {
        [self.navigationController popToViewController:self.concertDetailPage animated:YES];
    }
    else [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"GridToPostViewController"]) {
        ECPostViewController* vc = (ECPostViewController*)[segue destinationViewController];
        NSUInteger row = [[[self.postsCollectionView indexPathsForSelectedItems] objectAtIndex:0] row];
        
        vc.post = [self.posts objectAtIndex:row];
        vc.artist = [self.concert eventName];
        vc.venueAndDate = [self.concert venueAndDate];
        vc.itemNumber = row;
        vc.delegate = self;
        vc.showShareButton = !self.hideShareButton;
        
    }
}

#pragma mark Event Populating
-(void) askServerToPopulateConcert{
    [ECJSONPoster populateConcert:self.concert.eventID completion:^(BOOL success) {
        //Check If concert finished Populating
//        [self checkConcertIfPopulating];
        //Fire timer
//        [self startTimer];
        [self showFooter];
        [self performSelector:@selector(checkConcertIfPopulating) withObject:nil afterDelay:kInitialCheckConcertDelay];
    }];
}

-(void) checkConcertIfPopulating {
    [ECJSONFetcher checkIfEventIsPopulating:[self.concert eventID] completion:^(BOOL isPopulating) {
        _isPopulating = isPopulating;
        if(isPopulating){
            //Show the footer
            [self showFooter];
            [self hideNoPostsLabel];
            [self performSelector:@selector(checkConcertIfPopulating) withObject:nil afterDelay:kSubsequentCheckConcertPopulatingDelay];
        
        }
        else {
            [self loadConcertImages: NO];
//            [self stopTimer];
            [self hideFooter];

        }
    }];

}

-(void) checkStatus {
    if (!responseReceived) {
        MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.userInteractionEnabled = NO;
        hud.color = [UIColor blueArtistTextColor];
    }
}

-(void)loadConcertImages: (BOOL) shouldAsk {
    [self performSelector:@selector(checkStatus) withObject:nil afterDelay:0.8];
    [ECJSONFetcher fetchPostsForConcertWithID:self.concert.eventID completion:^(NSArray *fetchedPosts) {
        responseReceived = YES;
        if(fetchedPosts.count > 0){
            self.posts = [NSMutableArray arrayWithArray:fetchedPosts];
            [self.postsCollectionView reloadData];
            [self doTooltip];
            [self hideNoPostsLabel];
        }else{
            NSLog(@"%@: no posts returned",NSStringFromClass(self.class));
            if (!_isPopulating && !shouldAsk) {
                [self alertNoPosts];
            }
            if(shouldAsk) {
             [self askServerToPopulateConcert];
            }
        }
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

#pragma mark - Timer (repeatedly checking populating/loading)
//-(void) startTimer {
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0
//                                                  target:self
//                                                selector:@selector(checkConcertIfPopulating)
//                                                userInfo:nil
//                                                 repeats:YES];
//}

-(void) doTooltip {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"GridViewControllerShownBefore"] && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CMPopTipView *tooltip = [[CMPopTipView alloc] initWithMessage:@"Double tap the logo to see more photos at once"];
        tooltip.delegate = self;
        tooltip.backgroundColor = [UIColor blueArtistTextColor];
        tooltip.textColor = [UIColor whiteColor];
        tooltip.hasGradientBackground = NO;
        tooltip.hasShadow = NO;
        tooltip.has3DStyle = NO;
        tooltip.borderColor = [UIColor blueArtistTextColor];
        tooltip.textFont = [UIFont systemFontOfSize:17.0];
//        tooltip.textFont = [UIFont heroFontWithSize:17.0]; //Screws it up for some reason
        tooltip.dismissTapAnywhere = YES;
        //HACK ALERT (wouldn't let me easily point to the titleView)
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.topLayoutGuide.length, 0, 0)];
        [self.view addSubview:view];
        [self.view bringSubviewToFront:view];
        [tooltip presentPointingAtView:view inView:self.view animated:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GridViewControllerShownBefore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self performSelector:@selector(hideToolTip:) withObject:tooltip afterDelay:5.0];
    }
}

//-(void) stopTimer {
//    [self.timer invalidate];
//    self.timer = nil;
//}
#pragma mark - Footer
-(void)showFooter{
    [UIView animateWithDuration:0.3 animations:^{
        [self.footerView setAlpha:1];
    }];
    
}
-(void)hideFooter{
    [UIView animateWithDuration:0.3 animations:^{
        [self.footerView setAlpha:0];
    }];

}
-(void)alertNoPosts{
//    if ([self.navigationController.visibleViewController isEqual:self]) {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No posts found" message:@"Unfortunately we could not find any posts for this show." delegate:self cancelButtonTitle:@"Back" otherButtonTitles: nil];
//        alert.tag = NoPostsAlertTag;
//    
//        [alert show];
//    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.noPostsLabel setAlpha:1];
    }];
}

-(void)hideNoPostsLabel{
    [UIView animateWithDuration:0.3 animations:^{
        [self.noPostsLabel setAlpha:0];
    }];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == NoPostsAlertTag && buttonIndex == alertView.cancelButtonIndex) {
//        if (self.concertDetailPage) {
//            [self.navigationController popToViewController:self.concertDetailPage animated:YES];
//        }
//        else {
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//    }
}

#pragma mark - collection view
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    __weak ECPostCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"post" forIndexPath:indexPath];
    cell.postImageView.image = nil;
    NSInteger row = indexPath.row;
    if (row >= self.posts.count) {
        return cell;
    }
    NSDictionary* post = [self.posts objectAtIndex:row];
    [cell.activityIndicator startAnimating];
    [cell.postImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[post imageURL]] placeholderImage:[[UIImage alloc] init] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.postImageView.image = image;
        [cell.activityIndicator stopAnimating];
        cell.postImageView.contentMode = UIViewContentModeScaleAspectFit;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [cell.activityIndicator stopAnimating];
        cell.postImageView.image = [UIImage imageNamed:@"placeholderimg2"];
        cell.postImageView.contentMode = UIViewContentModeCenter;
//        [self deletePostWithID: post.postID];
//        NSArray* indexPaths = [NSArray arrayWithObject:indexPath];
//        [collectionView deleteItemsAtIndexPaths:indexPaths];
    }];
    
    cell.postType = [post postType];
    return cell;
}

-(void) deletePostWithID: (NSString*) postID {
    for (NSInteger i = 0; i < self.posts.count; i++){
        NSDictionary* post = [self.posts objectAtIndex:i];
        if ([post.postID isEqualToString:postID]) {
            [self.posts removeObjectAtIndex:i];
            return;
        }
    }
}

-(UICollectionReusableView*) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        ECGridHeaderView* headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerview" forIndexPath:indexPath];
        
        headerView.eventLabel.text = [[self.concert eventName] uppercaseString];
        [headerView.eventLabel setFont:[UIFont heroFontWithSize:16.0f]];
        [headerView.eventLabel setTextColor:[UIColor blueArtistTextColor]];
        headerView.venueAndDateLabel.text = [self.concert venueAndDate];
        [headerView.venueAndDateLabel setFont:[UIFont heroFontWithSize:12.0f]];
        return headerView;
    }
    return nil;
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
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[self.posts objectAtIndex:newIndex], @"dic", [NSNumber numberWithInteger:newIndex], @"index",nil];
}

#pragma mark FB Sharing
//-(void) shareTapped {
//    if([ApplicationDelegate isLoggedIn]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
//        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
//        [Flurry logEvent:@"Share_Tapped_Concert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"past_grid_vc",@"source",self.concert.eventID,@"eventID", self.concert.eventName, @"eventName", nil]];
//        [self share];
//    }
//    else {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To share this concert, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
//        alert.tag = ECShareNotLoggedInAlert;
//        [alert show];
//    }
//}

-(NSArray*) activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    NSURL* url = [self shareURL];
    NSString* text = [self shareText];
    if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        return @[url,[NSString stringWithFormat:@"%@ via #encore",text]];
    }
    
    if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
        return @[url];
    }
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        return @[url,[NSString stringWithFormat:@"%@ via @encoretheapp",text]];
    }
    
    if ([activityType isEqualToString:NSStringFromClass([TUSafariActivity class])] || [activityType isEqualToString:NSStringFromClass([ARChromeActivity class])]) {
        return @[url];
    }
    
    return @[text,url];
}

-(void) shareTapped {
    TUSafariActivity* safariActivity = [TUSafariActivity new];
    ARChromeActivity* chromeActivity = [ARChromeActivity new];
    
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
        [Flurry logEvent:@"Share_Tapped_Concert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"past_grid_vc",@"source",self.concert.eventID,@"eventID", self.concert.eventName, @"eventName", nil]];
    };
    [self presentViewController:shareDrawer animated:YES completion:nil];
}


-(void) share {
    [self shareWithTaggedFriends:nil];
}

-(NSString*) shareText {
    return [NSString stringWithFormat:@"%@ in %@",self.concert.eventName,self.concert.city];
}

-(NSURL*) shareURL {
    return [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
}

-(void) shareWithTaggedFriends: (NSArray*) taggedFriends {
    NSLog(@"Sharing with Facebook from Concert detail view controller");
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
    
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

-(void) popTipViewWasDismissedByUser:(CMPopTipView *)popTipView {
    
}

@end
