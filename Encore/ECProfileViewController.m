//
//  ECProfileViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileViewController.h"
#import "ECAppDelegate.h"
#import "ECMyConcertViewController.h"
#import "ECConcertChildViewController.h"
#import "ECConcertDetailViewController.h"
#import "ECJSONFetcher.h"
#import "ECCellType.h"
#import "ECAddConcertViewController.h"
#import "NSDictionary+ConcertList.h"
#import "ECTodayViewController.h"
static NSString *const BaseURLString = @"http://192.168.11.15:9283/api/v1/users";

@interface ECProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong,nonatomic) NSMutableArray * pastConcerts;
@property (strong,nonatomic) NSMutableArray * futureConcerts;
@property (strong, nonatomic) NSMutableDictionary * concerts;
//@property (strong,nonatomic) ECConcertChildViewController * concertChildVC;
@property (strong,nonatomic) ECConcertDetailViewController * concertChildVC;
-(IBAction)viewConcerts:(id)sender;
-(IBAction)viewFriends:(id)sender;
@end

@implementation ECProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.hidesBackButton = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"Settings"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(settingsButtonWasPressed:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"TEST"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(viewConcerts:)];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
    [[UITableView appearance] setBackgroundColor:[UIColor blackColor]];
    ECAppDelegate *appDelegate = (ECAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate performSelectorInBackground:@selector(getUserLocation) withObject:nil];
}

-(void) updateViewWithNewConcert: (NSNumber *) concertID {
    [ECJSONFetcher fetchConcertsForUserID:self.facebook_id completion:^(NSDictionary *concerts) {
        [self.concerts setDictionary:concerts];
        [self.horizontalSelect setTableData: self.concerts];
        [self.horizontalSelect.tableView reloadData];
    }];
 //TODO: scroll to the new concert
    [self scrollToConcertWithID: concertID];
}

-(void) scrollToConcertWithID: (NSNumber*) concertID{
    [self selectIndexPath:[self indexPathForConcert: concertID]];
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
        if ([[arr objectAtIndex:index] songkickID] == concertID) {
            return index;
        }
    }
    return -1;
}

-(void) viewWillAppear:(BOOL)animated {
    if (FBSession.activeSession.isOpen){
        [self populateUserDetails];
    }
    //  [self.navigationController setNavigationBarHidden:YES];
    
    
}
-(void) populateUserDetails {
//    self.userNameLabel.text = self.userName;
                // self.userProfileImage.profileID = [user objectForKey:@"id"];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)settingsButtonWasPressed:(id)sender {
    if (self.settingsViewController == nil) {
        self.settingsViewController = [[FBUserSettingsViewController alloc] init];
        self.settingsViewController.delegate = self;
    }
    
    [self.navigationController pushViewController:self.settingsViewController animated:YES];
}

#pragma mark - button actions
-(IBAction)viewConcerts:(id)sender{
    ECMyConcertViewController * concertsVC = [[ECMyConcertViewController alloc] init];
    ECJSONFetcher * jsonFetcher = [[ECJSONFetcher alloc] init];
    jsonFetcher.delegate = concertsVC;
    concertsVC.title = @"My Concerts";
    [jsonFetcher fetchConcertsForUserId:self.facebook_id];
    [self.navigationController pushViewController:concertsVC animated:YES];
}
-(void) fetchConcerts {
    ECJSONFetcher * jsonFetcher = [[ECJSONFetcher alloc] init];
    jsonFetcher.delegate = self;
    [jsonFetcher fetchConcertsForUserId:self.facebook_id];
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

#pragma mark - json fetcher delegate
-(void) fetchedConcerts: (NSDictionary *) concerts {
    NSLog(@"Successfully fetched %d past concerts and %d future concerts", [[concerts past] count],[[concerts future]count]);
    self.concerts = [NSMutableDictionary dictionaryWithDictionary: concerts];
    [self setUpHorizontalSelect]; //only setting up horizontal select once the concert data is received
    [self selectTodayCell];
}

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
    
    [self selectIndexPath:startIndexPath];
}

-(void) selectIndexPath: (NSIndexPath*) indexPath {
    UITableView * tableView = self.horizontalSelect.tableView;
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
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
        self.concertChildVC.concert = [[self.concerts objectForKey: key]objectAtIndex:indexPath.row];
        [self.concertChildVC updateView];
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
            //self.concertChildVC =[ECConcertChildViewController new];
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
@end
