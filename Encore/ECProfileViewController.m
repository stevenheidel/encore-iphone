//
//  ECProfileViewController.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileViewController.h"
#import "ECProfileHeader.h"
#import "ECProfileConcertCell.h"
#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>
#import "UIImageView+AFNetworking.h"
#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

#import "UIImage+GaussBlur.h"
#import "NSUserDefaults+Encore.h"

#import "ATConnect.h"
#import "ATAppRatingFlow.h"

#import "ECJSONFetcher.h"
#import "MBProgressHUD.h"

#define HEADER_HEIGHT 154.0  //height in nib is actually 170, but for some reason that leaves extra space at bottom
#define FLAG_HUD_DELAY 2.0

#import "ECAlertTags.h"

#import "ECAppDelegate.h"

typedef enum {
    FutureSection,
    PastSection,
    NumberOfSections
} ProfileTableViewSections;

@interface ECProfileViewController ()

@end

@implementation ECProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view setup
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpBackButton];
    [self setupLogoutButton];
    
    self.tableView.tableFooterView = [UIView new];
   // self.tableView.tableFooterView = [self footerView]; //Commented out Songkick attribution
   
    [self.tableView registerNib:[UINib nibWithNibName:@"ECProfileConcertCell" bundle:nil]
         forCellReuseIdentifier:@"ECProfileConcertCell"];
    [self setUpHeaderView];
    self.view.clipsToBounds = YES;
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    
    [[ATAppRatingFlow sharedRatingFlow] showRatingFlowFromViewControllerIfConditionsAreMet:self];
}

- (void) setUpBackButton {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"];     [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void) setupLogoutButton {
    UIButton* logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamed:@"logout.png"];
    [logoutButton setBackgroundImage:image forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
    logoutButton.frame = CGRectMake(0,0,image.size.width, image.size.height);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
}

- (UIView *) footerView {
    // Who needs songkick when you have lastFm!!!
    UIImage *footerImage = [UIImage imageNamed:@"songkick"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, footerImage.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, footerImage.size.width, footerImage.size.height)];
    imageView.center = footerView.center;
    imageView.image = footerImage;
    footerView.backgroundColor = [UIColor lightGrayHeaderColor];
    [footerView addSubview:imageView];
    return footerView;
}

-(void) tappedProfilePhoto {
    [Flurry logEvent:@"Tapped_Profile_Photo"];
}
- (void) setUpHeaderView {
    
    ECProfileHeader * header = [[ECProfileHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, HEADER_HEIGHT) andOwner:self];
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, HEADER_HEIGHT)];
    [myView addSubview:header];
    self.tableView.tableHeaderView = myView;
    
    self.lblName.font = [UIFont heroFontWithSize: 18.0];
    self.lblName.textColor = [UIColor whiteColor];
    self.lblConcerts.font = [UIFont heroFontWithSize: 12.0];
    self.lblConcerts.textColor = [UIColor whiteColor];
        
    userID = [NSUserDefaults userID];
    self.imgProfile.profileID = userID;
    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2;
    self.imgProfile.layer.masksToBounds = YES;
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedProfilePhoto)];
    self.imgProfile.userInteractionEnabled = YES;
    tapRecognizer.numberOfTapsRequired = 1;
    tapRecognizer.numberOfTouchesRequired = 1;
    [self.imgProfile addGestureRecognizer:tapRecognizer];
    
    NSURL *imageURL = [NSUserDefaults facebookProfileImageURL];
    UIImage *profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    self.imgBackground.image = [profileImage imageWithGaussianBlur];
    
    self.lblName.text = [[NSUserDefaults userName] uppercaseString];
    
    self.lblLocation.text = [NSUserDefaults userCity];
    
    [self setupRefreshControl];
}

-(void) setupRefreshControl {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadConcerts)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    self.refreshControl.tintColor = [UIColor lightBlueNavBarColor];
}

-(void) reloadConcerts {
    [Flurry logEvent:@"Used_Refresh_On_Profile"];
    [self fetchEvents];
}


-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void) updateHeader {
    self.lblConcerts.text = [self.pastEvents count] == 1 ? [NSString stringWithFormat:@"%d Past Concert", [self.pastEvents count]] : [NSString stringWithFormat:@"%d Past Concerts", [self.pastEvents count]];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupFeedback];
    [self fetchEvents]; //TODO: only do this if requires refresh? 
}

//Custom getters
-(NSArray*) pastEvents {
    return [self.events objectForKey: @"past"];
}
-(NSArray*) futureEvents {
    return [self.events objectForKey: @"future"];
}

-(void) fetchEvents {
    [ECJSONFetcher fetchConcertsForUserID:userID completion:^(NSDictionary *concerts) {
        //NSLog(@"%@: User Concerts response = %@", NSStringFromClass([self class]), concerts);
        self.events = concerts;
        [self updateHeader];
        [self.tableView reloadData];
        if([self.refreshControl isRefreshing]){
            [self.refreshControl endRefreshing];
        }
    }];
}

-(void) backButtonWasPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"ECProfileConcertCell";
    
    ECProfileConcertCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [[self arrayForSection:indexPath.section] objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    [cell.imageArtist setImageWithURL:[concertDic imageURL] placeholderImage:nil];

    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

//-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [ECProfileViewController titleForSection:section];
//}

+(NSString*) titleForSection: (NSInteger) section {
    switch (section) {
        case PastSection:
            return NSLocalizedString(@"Past Events", @"User's past events for section header on profile");
        case FutureSection:
            return NSLocalizedString(@"Future Events", @"User's future/upcoming events for section header on profile");
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CONCERT_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16.0;
}

-(NSArray*) arrayForSection: (NSInteger) section {
    switch (section) {
        case PastSection:
            return self.pastEvents;
        case FutureSection:
            return self.futureEvents;
        default:
            return nil;
    }
    return nil;
}

-(NSInteger) rowCountForSection: (NSInteger) section {
    return [[self arrayForSection:section] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self rowCountForSection: section];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return NumberOfSections;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([[self arrayForSection:section] count]==0){
        return [UIView new];
    }
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECProfileSectionHeaderView" owner:nil options:nil];
    UIView* headerView = [subviewArray objectAtIndex:0];
    UILabel* label = (UILabel*)[headerView viewWithTag:87];
    [label setFont:[UIFont heroFontWithSize:14.0f]];
    [label setText:[[ECProfileViewController titleForSection: section] uppercaseString]];
    
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSDictionary* concert = [[self arrayForSection:section] objectAtIndex:indexPath.row];
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] initWithConcert:concert];
    concertDetail.tense = [ECProfileViewController searchTypeForSection: section];
    
    //flurry log
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:concert];
    [dic addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:indexPath.row], @"row", [ECProfileViewController tenseStringForSection:section], @"Tense", nil]];
    [Flurry logEvent:@"Selected_Event_On_Profile" withParameters:dic];

    
    [self.navigationController pushViewController:concertDetail animated:YES];
}

+(NSString*) tenseStringForSection: (NSUInteger) section {
    return section == PastSection ? @"Past": @"Future";
}
// Let concert detail know which kind of 
+(ECSearchType) searchTypeForSection: (NSUInteger) section {
    return section == PastSection ? ECSearchTypePast : ECSearchTypeFuture;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logout
-(void) logoutTapped {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_alert_title",nil) message:NSLocalizedString(@"logout_alert_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"logout", nil), nil];
    alertView.tag = LogoutTag;
    [alertView show];
    
    [Flurry logEvent:@"Logout_Tapped_Profile"];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == LogoutTag && buttonIndex == alertView.firstOtherButtonIndex) {
        [self logout];  
    }
    else {
        [Flurry logEvent:@"Canceled_Logout"];
    }
}

-(void) logout {
    [Flurry logEvent: @"Logged_out_facebook"];
    [self dismissViewControllerAnimated:NO completion:nil]; //necessary to get rid of the profile modal view controller first
    [ApplicationDelegate.facebook logout];
//    [FBSession.activeSession closeAndClearTokenInformation];

}

#pragma mark - Feedback solicitation
-(void) setupFeedback {
    //    UIButton* feedback = [[UIButton alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIButton* feedback = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamed:@"feedback.png"];
    [feedback setBackgroundImage:image forState:UIControlStateNormal];
    [feedback addTarget:self action:@selector(openFeedback) forControlEvents:UIControlEventTouchUpInside];
    feedback.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    self.navigationItem.titleView = feedback;
}

-(void) openFeedback {
    [Flurry logEvent:@"Opened_Feedback" withParameters:[NSDictionary dictionaryWithObject:@"Profile" forKey:@"source"]];
    ATConnect *connection = [ATConnect sharedConnection];
    [connection presentMessageCenterFromViewController: self];
}


@end


