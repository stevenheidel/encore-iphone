//
//  ECProfileViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileViewController.h"
#import "ECMyConcertViewController.h"
#import "ECConcertChildViewController.h"
#import "ECJSONFetcher.h"
#import "ECCellType.h"
#import "ECAddConcertViewController.h"
#import "ECTodayViewController.h"
static NSString *const BaseURLString = @"http://192.168.11.15:9283/api/v1/users";

@interface ECProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong,nonatomic) NSMutableArray * pastConcerts;
@property (strong,nonatomic) NSMutableArray * futureConcerts;
@property (strong, nonatomic) NSMutableDictionary * concerts;
@property (strong,nonatomic) ECConcertChildViewController * concertChildVC;
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
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(settingsButtonWasPressed:)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"TEST"
                                              style:UIBarButtonItemStyleBordered
                                              target:self
                                              action:@selector(viewConcerts:)];


}
-(void) viewWillAppear:(BOOL)animated {
    if (FBSession.activeSession.isOpen){
        [self populateUserDetails];
    }
      //  [self.navigationController setNavigationBarHidden:YES];
}
-(void) populateUserDetails {
    self.userNameLabel.text = self.userName;
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
    NSLog(@"Successfully fetched %d concerts", [concerts count]);
    self.concerts = [NSMutableDictionary dictionaryWithDictionary: concerts];
//    self.pastConcerts = [concerts objectForKey:@"past"];  //TODO: fix to use category
//    self.futureConcerts = [concerts objectForKey:@"future"];
    
    self.horizontalSelect = [[KLHorizontalSelect alloc] initWithFrame: self.view.bounds];
    self.horizontalSelect.delegate = self;
    [self.horizontalSelect setTableData: self.concerts];
    [self.view addSubview: self.horizontalSelect];

    [self.horizontalSelect.tableView reloadData];
    
    //TODO: get it to load first view for "Today"
    NSIndexPath * startIndexPath = [NSIndexPath indexPathForItem:[self.concerts count]-1 inSection:ECCellTypePastShows];
    UITableView * tableView = self.horizontalSelect.tableView;
    
    [tableView selectRowAtIndexPath:startIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    if([tableView.delegate respondsToSelector:@selector(tableView: didSelectRowAtIndexPath:)]){
        [tableView.delegate tableView:tableView didSelectRowAtIndexPath:startIndexPath];
    }
}

#pragma mark - horizontal slider
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
        case ECCellTypeAddPast:
        case ECCellTypeAddFuture:
            return self.addConcertVC;
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
            self.concertChildVC =[ECConcertChildViewController new];
            break;
        case ECCellTypeAddFuture:
        case ECCellTypeAddPast:
            self.addConcertVC = [ECAddConcertViewController new];
            break;
        default:
            break;
    }
}

-(void) removeFromViewForCurrentCellType: (ECCellType) cellType {
    if (cellType != ECCellTypeAddPast && cellType != ECCellTypeAddFuture) {
       // [self.addConcertVC removeFromParentViewController]; Doesn't seem to be necessary? //TODO: doublecheck
        [self.addConcertVC.view removeFromSuperview];
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
