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
static NSString *const BaseURLString = @"http://192.168.11.15:9283/api/v1/users";

@interface ECProfileViewController ()
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong,nonatomic) NSMutableArray * concerts;
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
    

    //Initialize the informtion to feed the control
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"SectionData"
                                                          ofType: @"plist"];
    // Build the array from the plist
    
    [self fetchConcerts];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.horizontalSelect = [[KLHorizontalSelect alloc] initWithFrame: self.view.bounds];
    self.horizontalSelect.delegate = self;
    [self.horizontalSelect setTableData: self.concerts];
    [self.view addSubview: self.horizontalSelect];


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
-(void) fetchedConcerts: (NSArray *) concerts {
    NSLog(@"Successfully fetched %d concerts", [concerts count]);
    self.concerts = [NSMutableArray arrayWithArray:concerts];
    self.horizontalSelect.tableData = concerts;
    [self.horizontalSelect.tableView reloadData];
}

#pragma mark - horizontal slider
- (void) horizontalSelect:(id)horizontalSelect didSelectCell:(KLHorizontalSelectCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if(self.concertChildVC == nil){
        self.concertChildVC = [[ECConcertChildViewController alloc] init];
     self.concertChildVC.view.frame = CGRectMake(self.horizontalSelect.frame.origin.x,self.horizontalSelect.frame.origin.y+self.horizontalSelect.frame.size.height, self.horizontalSelect.frame.size.width, self.view.frame.size.height-self.horizontalSelect.frame.size.height);
    [self addChildViewController: self.concertChildVC];
    [self.view addSubview: self.concertChildVC.view];
    [self.view bringSubviewToFront:self.horizontalSelect.viewForBaselineLayout];
    }
    self.concertChildVC.concert = [self.concerts objectAtIndex:indexPath.row];
    [self.concertChildVC updateView];
}

@end
