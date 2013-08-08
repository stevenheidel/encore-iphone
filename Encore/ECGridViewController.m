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
#import "ATAppRatingFlow.h"
#import "EncoreURL.h"

@implementation ECPostCell

-(void) setPostType:(ECPostType)postType {
    _postType = postType;
    self.playButton.hidden = postType != ECVideoPost;
}

@end

@implementation ECGridHeaderView

@end


@interface ECGridViewController ()

@property(strong) NSTimer* timer;
@end

@implementation ECGridViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    [self askServerToPopulateConcert];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.postsCollectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = shareButton;
}
-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
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
        }
}
#pragma mark Event Populating
-(void) askServerToPopulateConcert{
    [ECJSONPoster populateConcert:self.concert.eventID completion:^(BOOL success) {
        //Check If concert finished Populating
        [self checkConcertIfPopulating];
        //Fire timer
        [self startTimer];
    }];
}
-(void) checkConcertIfPopulating {
    [ECJSONFetcher checkIfEventIsPopulating:[self.concert eventID] completion:^(BOOL isPopulating) {

        if(isPopulating)
        {
            //Show the footer
            [self showFooter];
        
        }else
        {
            //Call get images method
            [self loadConcertImages];
            //Stop timer
            [self stopTimer];
            //Remove the footer once timer finished
            [self hideFooter];

        }
        
       
    }];

}


-(void)loadConcertImages{
  
    [ECJSONFetcher fetchPostsForConcertWithID:self.concert.eventID completion:^(NSArray *fetchedPosts) {
        if(fetchedPosts.count > 0){
            self.posts = fetchedPosts;
            [self.postsCollectionView reloadData];
        }else{
            //Add No posts found Label
            [self showNoPostsLabel];
        }
    }];

}
#pragma mark - Timer (repeatedly checking populating/loading)
-(void) startTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                  target:self
                                                selector:@selector(checkConcertIfPopulating)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void) stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}
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
-(void)showNoPostsLabel{
    [UIView animateWithDuration:0.3 animations:^{
        [self.noPostsLabel setAlpha:1];
    }];
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
    
    NSDictionary* post = [self.posts objectAtIndex:indexPath.row];
    [cell.activityIndicator startAnimating];
    [cell.postImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[post imageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.postImageView.image = image;
        [cell.activityIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [cell.activityIndicator stopAnimating];
    }];
    
    cell.postType = [post postType];
    return cell;
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
    
    return [NSDictionary dictionaryWithObjectsAndKeys:[self.posts objectAtIndex:newIndex], @"dic", [NSNumber numberWithInt:newIndex], @"index",nil];
}

#pragma mark FB Sharing
-(void) shareTapped {
    if([ApplicationDelegate isLoggedIn]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
        [Flurry logEvent:@"Share_Tapped_Concert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"past_grid_vc",@"source",self.concert.eventID,@"eventID", self.concert.eventName, @"eventName", nil]];
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



@end
