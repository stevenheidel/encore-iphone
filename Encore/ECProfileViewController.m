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
#import "ECEventTableViewController.h"
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

#define HEADER_HEIGHT 166.0  //height in nib is actually 170, but for some reason that leaves extra space at bottom
#define FLAG_HUD_DELAY 2.0
#define SECTION_LINE_SEPARATOR_HEIGHT 2.0

#import "ECAlertTags.h"

#import "ECAppDelegate.h"
#import "MBProgressHUD.h"
#import "ECWelcomeViewController.h"

typedef enum {
    FutureSection,
    PastSection,
    NumberOfSections
} ProfileTableViewSections;

typedef enum {
    SettingsActionSheet
}ProfileActionSheetTags;

typedef enum {
    LogoutIndex,
    FeedbackIndex,
    WalkthroughIndex,
    InviteIndex
} SettingsActionSheetButtonIndices;

@interface ECProfileViewController ()<ECEventViewControllerDelegate>

@property (strong,atomic) MBProgressHUD* hud;
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
    NSLog(@"%@: did load",NSStringFromClass(self.class));
    [self setUpBackButton];
//    [self setupLogoutButton];
    [self setupSettingsButton];
    [self setUpHeaderView];
    [self setupRefreshControl];
    [self setupHUD];
    self.shouldUpdateView = YES;
    [self setNavBarAppearance];
    
    self.tableView.tableFooterView = [UIView new];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"ECProfileConcertCell" bundle:nil]
         forCellReuseIdentifier:@"ECProfileConcertCell"];
    
    self.view.clipsToBounds = YES;
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];

    [[ATAppRatingFlow sharedRatingFlow] showRatingFlowFromViewControllerIfConditionsAreMet:self];
    
    self.tableView.sectionHeaderHeight = 0;
    self.tableView.sectionFooterHeight = 0;
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        self.edgesForExtendedLayout = UIRectEdgeNone;
        [self.navigationController.navigationBar setTranslucent:IS_IPHONE_5];
    }
}

-(void) setNavBarAppearance {
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
    UIImage* image = [UIImage imageNamed:@"noimage"];
    self.navigationController.navigationBar.shadowImage = image;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = [UIColor blueArtistTextColor];
    }
}

-(void) setupHUD {
    //add hud progress indicator
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor lightBlueHUDConfirmationColor];
}
- (void) setUpBackButton {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
}
-(void) setupSettingsButton {
    UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* rightButtonImage = [UIImage imageNamed:@"gearbutton"];
    [rightButton setBackgroundImage:rightButtonImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(settingsTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButtonImage.size.width, rightButtonImage.size.height);
    UIBarButtonItem* gearButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = gearButton;
    
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
    NSInteger nFut = self.futureEvents.count;
    NSInteger nPas = self.pastEvents.count;
    NSInteger total = nFut + nPas;
    NSString* suffix = total == 1 ? @"" : @"s";
    NSString* text = nil;
//    if (total == 1) {
//        NSString* temp = @"Past";
//        if (nFut == 1) {
//            temp = @"Upcoming";
//        }
//        text = [NSString stringWithFormat:@"%d %@ Concert",total,temp];
//    }
//    else {
//        text = [NSString stringWithFormat:@"%d Concert%@ (%d Upcoming)",total,suffix,nFut];
//    }
    text = [NSString stringWithFormat:@"%d Concert%@",total,suffix];
    self.lblConcerts.text = text;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self setupFeedback];
    
    //TODO: set shoudlupdateview to true when concert state change
    if(self.shouldUpdateView)
        [self fetchEvents];
    
    // if the list is empty show HUD
    if(self.events.count == 0)
    {
        [self.hud show:YES];
    }
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
        [self.hud hide:YES];
        self.shouldUpdateView = NO;
    }];
}
- (void) profileUpdated;
{
    self.shouldUpdateView = YES;
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

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

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
    if ([self sectionShouldNotHaveSeparator:section]){
        return 0;
    }
    return SECTION_LINE_SEPARATOR_HEIGHT;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
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

-(BOOL) sectionShouldNotHaveSeparator: (NSInteger) section {
    NSArray* arrayForSection = [self arrayForSection:section];
    NSInteger count = [arrayForSection count];
    return (count == 0 || section == 0 || (section == 1 && [[self arrayForSection:0] count] == 0));
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
       //no line if there isn't anything in the section, or if it's the first section (b/c it's intended as a separator only), or it's the second section and there isn't anything in the section before it
    if ([self sectionShouldNotHaveSeparator: section]) {
        return nil;//[UIView new];
    }
    
    UIView* line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, SECTION_LINE_SEPARATOR_HEIGHT)];
    line.backgroundColor = [UIColor profileSectionSeparatorColour];
    return line;
  
    
    
    //original full blue separators
    
//    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECProfileSectionHeaderView" owner:nil options:nil];
//    UIView* headerView = [subviewArray objectAtIndex:0];
//    UILabel* label = (UILabel*)[headerView viewWithTag:87];
//    [label setFont:[UIFont heroFontWithSize:14.0f]];
//    [label setText:[[ECProfileViewController titleForSection: section] uppercaseString]];
//    
//    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = indexPath.section;
    NSDictionary* concert = [[self arrayForSection:section] objectAtIndex:indexPath.row];
    
    ECSearchType tense = ECSearchTypePast;
    NSString* storyboardName = @"ECPastStoryboard";
    
    if(indexPath.section == FutureSection) {
        tense  = ECSearchTypeFuture;
        storyboardName = @"ECUpcomingStoryboard";
    }
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    ECEventTableViewController * vc = [sb instantiateInitialViewController];
    vc.tense = tense;
    vc.concert = concert;
    vc.eventStateDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
    
    [Flurry logEvent:@"Selected_Event_On_Profile" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:concert.eventID, @"eventID",concert.eventName,@"eventName",[NSNumber numberWithInt:indexPath.row],@"row",[ECProfileViewController tenseStringForSection:section],@"Tense", nil]];

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

#pragma mark - Logout / Settings
-(void) settingsTapped {
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle: [NSString stringWithFormat:@"Encore Version %@", [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]]
 delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Logout" otherButtonTitles:@"Give Feedback", @"Repeat Walkthrough",@"Invite Friends",nil];
    
    // Make sure the order of the button titles matches the order of the indices defined in the typedef at the top of the page.
    
    actionSheet.tag = SettingsActionSheet;
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == SettingsActionSheet) {
        if (buttonIndex == actionSheet.destructiveButtonIndex) {
            [self logoutTapped];
        }
        else if (buttonIndex == FeedbackIndex) {
            [self openFeedback];
        }
        else if (buttonIndex == WalkthroughIndex){
            [self dismissViewControllerAnimated:YES completion:^{
                [ApplicationDelegate showWalktrhoughView];
                [Flurry logEvent:@"Tapped_Repeat_Walkthrough" withParameters:nil];
            }];

        }
        else if (buttonIndex == InviteIndex){
            NSDictionary* params = nil;
            [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                          message:@"Check out this concert app for iPhone. It lets you find local concerts and rediscover past shows you've attended"
                                                            title:@"Invite Friends to Encore"
                                                       parameters:params
                                                          handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
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
                                                                      [Flurry logEvent:@"Successfully_Invited_Friends_From_Profile" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:resultURL, @"resultURL",nil]]; //TODO figure out how many friends were invited
                                                                      NSLog(@"result url %@",resultURL);
                                                                  }
                                                              }}];
            

        }
    }
    
}

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
    [ApplicationDelegate logout];
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


