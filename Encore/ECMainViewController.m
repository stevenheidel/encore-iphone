//
//  ECProfileViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECMainViewController.h"
#import "ECAppDelegate.h"
#import "ECConcertDetailViewController.h"
#import "ECJSONFetcher.h"
#import "ECCellType.h"
#import "ECAddConcertViewController.h"
#import "NSDictionary+ConcertList.h"
#import "ECTodayViewController.h"
static NSString *const BaseURLString = @"http://192.168.11.15:9283/api/v1/users";

@interface ECMainViewController ()
@property (strong,nonatomic) NSMutableArray * pastConcerts;
@property (strong,nonatomic) NSMutableArray * futureConcerts;
@property (strong, nonatomic) NSMutableDictionary * concerts;
@property (strong,nonatomic) ECConcertDetailViewController * concertChildVC;

@property (strong,nonatomic) UIBarButtonItem* shareButton;

-(IBAction)viewFriends:(id)sender;
@end

@implementation ECMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.hidesBackButton = YES;
    }
    return self;
}

#pragma mark - View Setup
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBarButtons]; 
    [self setNavBarAppearance];
    
    ECAppDelegate *appDelegate = (ECAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate performSelectorInBackground:@selector(getUserLocation) withObject:nil];
    
    [self setupGestureRecgonizers];
    [self.horizontalSelect.tableView setScrollsToTop:NO];
}

-(void) setNavBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
}


//Set up left bar button for going to profile and right bar button for sharing
-(void) setupBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"profileButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(profileButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width*0.75, leftButImage.size.height*0.75);
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width*0.75, rightButImage.size.height*0.75);
    self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = self.shareButton;
}

-(void) shareTapped {
    [self.concertChildVC shareTapped];
    [Flurry logEvent:@"Share_Tapped_From_ProfileVC"];

}

-(void) setupGestureRecgonizers {
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    recognizerLeft.numberOfTouchesRequired = 1;
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    recognizerRight.numberOfTouchesRequired = 1;
    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizerRight];
    [self.view addGestureRecognizer:recognizerLeft];
}

#pragma mark View Updating
-(void) refreshForConcertID:(NSNumber*) concertID {
    [self.navigationController popToViewController:self animated:YES];
    [self updateViewWithNewConcert: concertID];
}

-(void) updateViewWithNewConcert: (NSNumber *) concertID {
    [ECJSONFetcher fetchConcertsForUserID:self.facebook_id completion:^(NSDictionary *concerts) {
        [self.concerts setDictionary:concerts];
        [self.horizontalSelect setTableData: self.concerts];
        [self.horizontalSelect.tableView reloadData];
        [self scrollToConcertWithID:concertID];
        //If concertID is nil, as in the case of a removal, then the scrolling function will scroll to the today cell
    }];
}

-(void) scrollToConcertWithID: (NSNumber*) concertID {
    if(concertID) {
        [self selectIndexPath:[self indexPathForConcert: concertID] animated: NO];
    }
    else
        [self selectTodayCell];
}

-(NSIndexPath *) indexPathForConcert: (NSNumber*) concertID{
    NSArray * pastConcerts = [self.concerts objectForKey:@"past"];
    NSArray * futureConcerts = [self.concerts objectForKey:@"future"];
    
    NSUInteger row = [self rowForConcertID: concertID forArray: pastConcerts];
    NSUInteger section = ECCellTypePastShows;
    if (row == -1) {
            row = [self rowForConcertID: concertID forArray: futureConcerts];
        section = ECCellTypeFutureShows;
    }
    if (row == -1) {
        NSLog(@"Error: %@ not found",concertID.stringValue);
    }
    
    //If error, just send it back to the Today cell]
    return row == -1  ? [NSIndexPath indexPathForItem:0 inSection:ECCellTypeToday] : [NSIndexPath indexPathForItem:row inSection:section];
}

-(NSUInteger) rowForConcertID: (NSNumber*) concertID forArray: (NSArray*) arr {
    NSUInteger index;
    for (index = 0; index < [arr count]; index++){
        if ([[[arr objectAtIndex:index] songkickID] isEqualToNumber: concertID]) {
            return index;
        }
    }
    return -1;
}

//-(void) viewWillAppear:(BOOL)animated {
//    if (FBSession.activeSession.isOpen){
//        [self populateUserDetails];
//    }
//    //  [self.navigationController setNavigationBarHidden:YES];
//}
//-(void) populateUserDetails {
////    self.userNameLabel.text = self.userName;
//                // self.userProfileImage.profileID = [user objectForKey:@"id"];
//}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)profileButtonWasPressed:(id)sender {
    if (self.profileViewController == nil) {
        self.profileViewController = [[ECProfileViewController alloc] init];
        self.profileViewController.arrPastConcerts = [self.concerts objectForKey:@"past"];
    }
    
    [self.navigationController pushViewController:self.profileViewController animated:YES];
    [Flurry logEvent:@"Profile_Button_Pressed"];
}

#pragma mark - button actions

-(void) fetchConcerts {
    [ECJSONFetcher fetchConcertsForUserID:self.facebook_id completion:^(NSDictionary *concerts) {
        NSLog(@"Successfully fetched %d past concerts and %d future concerts", [[concerts past] count],[[concerts future]count]);
        //NSLog(@"Fetched concerts for user:%@", concerts);
        self.concerts = [NSMutableDictionary dictionaryWithDictionary: concerts];
        [self setUpHorizontalSelect]; //only setting up horizontal select once the concert data is received
        [self selectTodayCell];
    }];
}

-(IBAction)viewFriends:(id)sender{
    FBRequest * friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray * friends = [result objectForKey:@"data"];
        NSLog(@"Found: %i friends", friends.count);
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"I have a friend named %@ with id %@", friend.name, friend.id);
        }
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [Flurry logEvent:@"Received_Memory_Warning" withParameters:[NSDictionary dictionaryWithObject:NSStringFromClass(self.class) forKey:@"class"]];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FBUserSettingsDelegate methods

- (void)loginViewControllerDidLogUserOut:(id)sender {
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBLoginView delegate (SCLoginViewController)
    // will already handle logging out so this method is a no-op.
}

- (void)loginViewController:(id)sender receivedError:(NSError *)error{
    // Facebook SDK * login flow *
    // There are many ways to implement the Facebook login flow.
    // In this sample, the FBUserSettingsViewController is only presented
    // as a log out option after the user has been authenticated, so
    // no real errors should occur. If the FBUserSettingsViewController
    // had been the entry point to the app, then this error handler should
    // be as rigorous as the FBLoginView delegate (SCLoginViewController)
    // in order to handle login errors.
    if (error) {
        NSLog(@"Unexpected error sent to the FBUserSettingsViewController delegate: %@", error);
    }
}

//#pragma mark - json fetcher delegate
//-(void) fetchedConcerts: (NSDictionary *) concerts {
//    NSLog(@"Successfully fetched %d past concerts and %d future concerts", [[concerts past] count],[[concerts future]count]);
//    self.concerts = [NSMutableDictionary dictionaryWithDictionary: concerts];
//    [self setUpHorizontalSelect]; //only setting up horizontal select once the concert data is received
//    [self selectTodayCell];
//}

#pragma mark - horizontal slider
-(void) setUpHorizontalSelect {
    if (!self.horizontalSelect) {
        self.horizontalSelect = [[KLHorizontalSelect alloc] initWithFrame: self.view.bounds];
        self.horizontalSelect.delegate = self;
        [self.view addSubview: self.horizontalSelect];
    }
    [self.horizontalSelect setTableData: self.concerts];
    [self.horizontalSelect.tableView reloadData];
}

-(void) selectTodayCell {
    NSIndexPath * startIndexPath = [NSIndexPath indexPathForItem:0 inSection:ECCellTypeToday];
    
    [self selectIndexPath:startIndexPath animated: NO];
}

-(void) selectIndexPath: (NSIndexPath*) indexPath animated: (BOOL) animated{
    UITableView * tableView = self.horizontalSelect.tableView;
    [tableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:UITableViewScrollPositionTop];
    if([tableView.delegate respondsToSelector:@selector(tableView: didSelectRowAtIndexPath:)]){
        [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (void) horizontalSelect:(id)horizontalSelect didSelectCell:(KLHorizontalSelectCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    ECCellType cellType = indexPath.section;
    
    [self addChildViewForCellType:cellType];
    [self removeFromViewForCurrentCellType:cellType];
    [self.view bringSubviewToFront:self.horizontalSelect.viewForBaselineLayout];
    
    if (cellType == ECCellTypeFutureShows || cellType == ECCellTypePastShows) {
        NSString * key = cellType == ECCellTypePastShows ? @"past" : @"future";
        NSDictionary* concert = [[self.concerts objectForKey: key]objectAtIndex:indexPath.row];
        self.concertChildVC.concert = concert;
        [self.concertChildVC updateView];
        self.shareButton.enabled = YES;
        [Flurry logEvent:[NSString stringWithFormat:@"Selected_%@_Cell_HS",key] withParameters:concert];
    }
    else {
        self.shareButton.enabled = NO;
        [Flurry logEvent:[NSString stringWithFormat:@"Selected_Cell_Type_%d",cellType]];
    }
    
}

-(void) addChildViewForCellType:(ECCellType) cellType {
    UIViewController * child = [self childViewControllerForCellType: cellType];
    if ([self childViewControllerForCellType: cellType] == nil) {
        [self allocateChildViewControllerForCellType: cellType];
        child = [self childViewControllerForCellType:cellType];
        child.view.frame = [self childViewControllerRect];
        [self addChildViewController:child];
    }
    [self.view addSubview:child.view];
}

-(UIViewController *) childViewControllerForCellType: (ECCellType) cellType {
    switch (cellType) {
        case ECCellTypeAddFuture:
            return self.addFutureConcertVC;
        case ECCellTypeAddPast:
            return self.addPastConcertVC;
        case ECCellTypeFutureShows:
        case ECCellTypePastShows:
            return self.concertChildVC;
        case ECCellTypeToday:
            return self.todayVC;
        default:
            return nil;
    }
    return nil;
}

-(void) allocateChildViewControllerForCellType: (ECCellType) cellType {
    switch (cellType) {
        case ECCellTypeToday:
            self.todayVC = [ECTodayViewController new];
            break;
        case ECCellTypePastShows:
        case ECCellTypeFutureShows:
            self.concertChildVC = [ECConcertDetailViewController new];
            break;
        case ECCellTypeAddFuture:
            self.addFutureConcertVC = [ECAddConcertViewController new];
            self.addFutureConcertVC.searchType = ECSearchTypeFuture;
            break;
        case ECCellTypeAddPast:
            self.addPastConcertVC = [ECAddConcertViewController new];
            self.addPastConcertVC.searchType = ECSearchTypePast;
            break;
        default:
            break;
    }
}

-(void) removeFromViewForCurrentCellType: (ECCellType) cellType {
    if (cellType != ECCellTypeAddPast) {
       // [self.addConcertVC removeFromParentViewController]; Doesn't seem to be necessary? //TODO: doublecheck
        [self.addPastConcertVC.view removeFromSuperview];
    }
    
    if (cellType !=  ECCellTypeAddFuture) {
        [self.addFutureConcertVC.view removeFromSuperview];
    }
    
    if (cellType != ECCellTypeFutureShows && cellType != ECCellTypePastShows) {
        //[self.concertChildVC removeFromParentViewController];
        [self.concertChildVC.view removeFromSuperview];
    }
    
    if (cellType != ECCellTypeToday) {
        //[self.todayVC removeFromParentViewController];
        [self.todayVC.view removeFromSuperview];
    }
}
-(CGRect) childViewControllerRect{
    return CGRectMake(self.horizontalSelect.frame.origin.x, self.horizontalSelect.frame.origin.y+self.horizontalSelect.frame.size.height, self.horizontalSelect.frame.size.width, self.view.frame.size.height-self.horizontalSelect.frame.size.height);
}

#pragma mark - gestures
- (void)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
	//CGPoint location = [recognizer locationInView:self.view];
    int direction = 0;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        direction = +1;

    }
    else {
        direction = -1;
    }
    [Flurry logEvent:@"Swipe_Gesture_PVC" withParameters:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:direction] forKey:@"direction"]];
    [self gesture:direction];
}

-(void) gesture: (NSInteger) direction {
    NSIndexPath * selected = self.horizontalSelect.tableView.indexPathForSelectedRow;
    NSIndexPath * newIndexPath = [self newIndexPathForStart: selected direction: direction];
    [self selectIndexPath:newIndexPath animated: YES];
}


//TODO: CLEAN UP
-(NSIndexPath*) newIndexPathForStart: (NSIndexPath*) start direction: (NSInteger) direction {
    NSInteger newRow = start.row;
    NSInteger newSection = start.section;
    NSUInteger futureCount = [[self.concerts future] count];
    NSUInteger pastCount = [[self.concerts past] count];
    
    switch (start.section) {
        case ECCellTypeAddFuture: {
            if (direction == -1) {
                if (futureCount > 0) {
                    newSection = ECCellTypeFutureShows;
                    newRow = futureCount-1;//go to last of future concerts
                }
                else {
                    newSection = ECCellTypeToday;
                    newRow = 0;
                }
            }
            break;
        }
        case ECCellTypeAddPast: {
            if (direction == 1) { 
                if(pastCount > 0){
                    newSection = ECCellTypePastShows;
                    newRow = 0;
                }
                else {
                    newSection = ECCellTypeToday;
                    newRow = 0;
                }
            }
            break;
        }
        case ECCellTypeToday: {
            if (direction == -1) {
                if (pastCount > 0) {
                    newSection = ECCellTypePastShows;
                    newRow = pastCount-1;
                }
                else {
                    newSection = ECCellTypeAddPast;
                    newRow = 0;
                }
            }
            else {
                if (futureCount > 0) {
                    newSection = ECCellTypeFutureShows;
                    newRow = 0;
                }
                else {
                    newSection = ECCellTypeAddFuture;
                    newRow = 0;
                }
            }
            break;
        }
        case ECCellTypeFutureShows: {
            if (direction == -1) {
                if (start.row == 0){
                    newSection = ECCellTypeToday;
                    newRow = 0;
                }
                else {
                    newRow--;
                }
            }
            else { //moving forward
                if (start.row == futureCount - 1) {
                    newSection = ECCellTypeAddFuture;
                    newRow = 0;
                }
                else {
                    newRow++;
                }
            }
            break;
        }
        case ECCellTypePastShows: {
            if (direction == - 1) {
                if(start.row == 0){
                    newSection = ECCellTypeAddPast;
                    newRow = 0;
                }
                else {
                    newRow--;
                }
            }
            else {
                if (start.row == pastCount - 1) {
                    newSection = ECCellTypeToday;
                    newRow = 0;
                }
                else {
                    newRow++;
                }
            }
            break;
        }
        default:
            newRow = start.row;
            newSection = start.section;
            break;
    }
    
    return [NSIndexPath indexPathForItem:newRow inSection:newSection];
    
}

@end
