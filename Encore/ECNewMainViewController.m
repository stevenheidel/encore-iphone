//
//  ECNewMainViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

#import "ATConnect.h"
#import "ATAppRatingFlow.h"

#import "ECNewMainViewController.h"
#import "ECJSONFetcher.h"

#import "ECConcertCellView.h"
#import "ECSearchResultCell.h"
#import "NSDictionary+ConcertList.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "ECConcertDetailViewController.h"
#import "ECAppDelegate.h"
#import "UIImage+GaussBlur.h"
#import <QuartzCore/QuartzCore.h>

#import "UIViewController+KNSemiModal.h"

#import "ECAlertTags.h"
#import "ECLocationSetterViewController.h"

#import "NSUserDefaults+Encore.h"
#import "ECCustomNavController.h"

#define SearchCellIdentifier @"ECSearchResultCell"
#define ConcertCellIdentifier @"ECConcertCellView"
#define ALERT_HIDE_DELAY 2.0
#define SEARCH_HEADER_HEIGHT 98.0f
#define ECLocationAcquiredNotification  @"com.encoretheapp.Encore:ECLocationAcquiredNotification"
#define ECLocationFailedNotification  @"com.encoretheapp.Encore:ECLocationFailed"

typedef enum {
    ECSearchResultSection,
    ECSearchLoadOtherSection,
    ECNumberOfSearchSections //always have this one last
}ECSearchSection;


@interface ECNewMainViewController () {
    BOOL showingSearchBar;
    UIView* emptyView;
}

@end

@implementation ECNewMainViewController

#pragma mark - View loading
- (void)viewDidLoad {
    [super viewDidLoad];
    emptyView = [UIView new];
    //Initializations;
    self.searchHeaderView = nil;
    self.hasSearched = FALSE;
    self.comboSearchResultsDic = nil;
    showingSearchBar = NO; //by default hidden (see storyboard)
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ECSearchResultCell" bundle:nil]
         forCellReuseIdentifier:SearchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:ConcertCellIdentifier];
    
    //Setups
    [self setupBarButtons];
    [self setNavBarAppearance];
    [self setSegmentedControlAppearance];
    [self setDateLabel];
    [self setupHUD];
    [self setupSearchBar];
    [self setupRefreshControl];
    
    
    self.tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self initializeSearchLocation];
    
    self.currentSearchType = [NSUserDefaults lastSearchType];
    if (self.currentSearchType == 0) { //default if nothing saved is 0, which is invalid.
        self.currentSearchType = ECSearchTypeToday;
    }
    [self displayViewsAccordingToSearchType];
    
    [self.segmentedControl setSelectedSegmentIndex:[ECNewMainViewController segmentIndexForSearchType:self.currentSearchType]];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    self.view.clipsToBounds = YES;

    
    //if user already set location using select location controller don't listen to location changes 
    if([NSUserDefaults lastSearchLocation].coordinate.latitude == 0 && [NSUserDefaults lastSearchLocation].coordinate.longitude == 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationAcquired) name:ECLocationAcquiredNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationFailed) name:ECLocationFailedNotification object:nil];
    }else
    {
        [self fetchConcerts];
    }
  
}

-(void)LocationAcquired
{
    if([NSUserDefaults lastSearchLocation].coordinate.latitude != 0 && [NSUserDefaults lastSearchLocation].coordinate.longitude != 0)
    {
         [self fetchConcerts];
    }
}
-(void)LocationFailed
{
    // Failed to get location using location services and there is no location saved
    if([NSUserDefaults lastSearchLocation].coordinate.latitude == 0 && [NSUserDefaults lastSearchLocation].coordinate.longitude == 0)
    {
        //Show alert
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Needed", nil) message:NSLocalizedString(@"To re-enable, please go to Settings and turn on Location Service for this app or set location manually", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Manually", nil),NSLocalizedString(@"OK", nil), nil];
        alert.tag = NoLocationAlert;
        [alert show];

    }
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

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[ATAppRatingFlow sharedRatingFlow] showRatingFlowFromViewControllerIfConditionsAreMet:self];
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [NSUserDefaults setLastSearchType: self.currentSearchType];
    [NSUserDefaults synchronize];
}

-(void) initializeSearchLocation {
    self.currentSearchLocation = [NSUserDefaults lastSearchLocation];
    self.currentSearchRadius = [NSUserDefaults lastSearchRadius];
}

-(void) setEventArray: (NSArray*) concerts forType: (ECSearchType) searchType {
    switch (searchType) {
        case ECSearchTypeToday:
            self.todaysConcerts = concerts;
            break;
        case ECSearchTypeFuture:
            self.futureConcerts = concerts;
            break;
        case ECSearchTypePast:
            self.pastConcerts = concerts;
            break;
        default:
            break;
    }
}
-(UIView*) noConcertsFooterView {
    if(_noConcertsFooterView == nil) {
        _noConcertsFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        _noConcertsFooterView.backgroundColor = [UIColor blackColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(5,5,315,20)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor blackColor];
        label.text = NSLocalizedString(@"No shows in your area. Change location?", @"If no results for popular shows, this appears in the table footer view");
        [_noConcertsFooterView addSubview:label];
    }
    return _noConcertsFooterView;
}

-(void) showLoadingHUD {
    self.hud.detailsLabelText = nil;
    self.hud.labelText = NSLocalizedString(@"Loading",nil);
    [self.hud show:YES];
}

-(void) fetchConcerts {
    NSLog(@"fetch concerts called");
    [self fetchPopularConcertsWithSearchType:ECSearchTypeToday];
    [self fetchPopularConcertsWithSearchType:ECSearchTypePast];
    [self fetchPopularConcertsWithSearchType:ECSearchTypeFuture];
}

-(void) fetchPopularConcertsWithSearchType: (ECSearchType) type {
    if(self.currentSearchType == type) {
        [self showLoadingHUD];
    }
    [ECJSONFetcher fetchPopularConcertsWithSearchType:type location:self.currentSearchLocation radius:[NSNumber numberWithFloat:self.currentSearchRadius] completion:^(NSArray *concerts) {
        [self fetchedPopularConcerts:concerts forType:type];
    }];
}

-(void) fetchedPopularConcerts: (NSArray*) concerts forType: (ECSearchType) searchType {
    [self setEventArray: concerts forType: searchType];
    
    if(searchType == self.currentSearchType){
        if ([self currentEventArray].count == 0) {
            self.tableView.tableFooterView = self.noConcertsFooterView;
        }
        else {
            self.tableView.tableFooterView = emptyView;
        }
        [self.hud hide:YES];
    }
    if (self.segmentedControl.selectedSegmentIndex == [ECNewMainViewController segmentIndexForSearchType:searchType]) {
        [self.tableView reloadData];
        [self setBackgroundImage];
    }
}

-(void) setupHUD {
    //add hud progress indicator
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor lightBlueHUDConfirmationColor];
//    self.hud.labelFont = [UIFont heroFontWithSize:self.hud.labelFont.pointSize];
//    self.hud.detailsLabelFont = [UIFont heroFontWithSize:self.hud.detailsLabelFont.pointSize];
}

-(void) setupRefreshControl {
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(reloadData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    self.refreshControl.tintColor = [UIColor lightBlueNavBarColor];
}
-(void) reloadData {
    [Flurry logEvent:@"Used_Refresh_Control_Main_View" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self currentSearchTypeString], @"search_type", nil]];
    [ECJSONFetcher fetchPopularConcertsWithSearchType:self.currentSearchType location: self.currentSearchLocation radius: [NSNumber numberWithFloat:self.currentSearchRadius] completion:^(NSArray *concerts) {
        NSArray* currentArray = [self currentEventArray];
        currentArray = concerts;
        [self.tableView reloadData];
        [self setBackgroundImage];
        [self.refreshControl endRefreshing];
    }];
}
-(void) setupSearchBar {
    //Add padding for search bar
    
    UIView* paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIImageView* magnifyingGlass = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 11, 11)];
    magnifyingGlass.image = [UIImage imageNamed:@"magnifyingglass"];
    [paddingView addSubview:magnifyingGlass];
    
    self.searchBar.leftView = paddingView;
    self.searchBar.leftViewMode = UITextFieldViewModeAlways;
    self.searchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.searchBar.font = [UIFont heroFontWithSize:18.0f];
    
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    [self.searchBar setTextColor:[UIColor blackColor]];
    
    UIColor *color = [UIColor darkGrayColor];
    self.searchBar.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Artist search..." attributes:@{NSForegroundColorAttributeName: color}];
}

//Set up left bar button for going to profile and right bar button for sharing
-(void) setupBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"profileButton"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(profileTapped) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"invite"];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(inviteTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    UIBarButtonItem *inviteButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = inviteButton;
}

-(void) inviteTapped {
     [Flurry logEvent:@"Tapped_Invite" withParameters:[NSDictionary dictionaryWithObject:@"MainView" forKey:@"source"]];
    //        //https://developers.facebook.com/docs/concepts/requests/#invites
    //        //TODO: filter out people that have not installed it
    //Provide a filter in your request interface that only lists people that have not installed the game. If you use the Requests dialog, you can enable this with the app_non_users filter.
    NSDictionary* params = nil;
    [FBWebDialogs presentRequestsDialogModallyWithSession:[FBSession activeSession]
                                                  message:@"Check out Encore on iOS"
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
                                                              [Flurry logEvent:@"Successfully_Invited_Friends"]; //TODO figure out how many friends were invited
                                                          }
                                                      }}];

}
-(void) feedbackTapped {
        [Flurry logEvent:@"Opened_Feedback" withParameters:[NSDictionary dictionaryWithObject:@"MainView" forKey:@"source"]];
    ATConnect *connection = [ATConnect sharedConnection];
    [connection presentMessageCenterFromViewController: self];
}

-(void) setNavBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarlandscape"] forBarMetrics:UIBarMetricsLandscapePhone];  //TODO: figure out what this isn't loading in on rotate for youtube.
    
    [[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
    UIImage* image = [UIImage imageNamed:@"noimage"];
    self.navigationController.navigationBar.shadowImage = image;
}

-(void) setSegmentedControlAppearance {
    UIImage* unselected = [UIImage imageNamed:@"defaultfull"];
    UIImage* selected = [UIImage imageNamed:@"activefull"];
    UIImage* dividerLeftActive = [UIImage imageNamed:@"divideractiveleft"];
    UIImage* dividerRightActive = [UIImage imageNamed:@"divideractiveright"];
    UIImage* bothInactive = [UIImage imageNamed:@"dividerdefault"];
    
    [self.segmentedControl setBackgroundImage:unselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setBackgroundImage:selected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [self.segmentedControl setDividerImage:dividerLeftActive forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:dividerRightActive forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setDividerImage:bothInactive forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSDictionary* selectedTextAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], UITextAttributeTextColor,
                                      [UIColor clearColor], UITextAttributeTextShadowColor,
                                      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                      [UIFont heroFontWithSize:17.0f], UITextAttributeFont,
                                       nil];
    NSDictionary* unselectedTextAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor unselectedSegmentedControlColor], UITextAttributeTextColor,
                                        [UIColor clearColor], UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                        [UIFont heroFontWithSize:17.0f], UITextAttributeFont,
                                        nil];

    [self.segmentedControl setTitleTextAttributes:selectedTextAttr forState:UIControlStateSelected];
    [self.segmentedControl setTitleTextAttributes:unselectedTextAttr forState:UIControlStateNormal];

    //Guess and check to get right offset. May not be perfect, seems to be good though
    [self.segmentedControl setContentPositionAdjustment:UIOffsetMake(4, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setContentPositionAdjustment:UIOffsetMake(0, 0) forSegmentType:UISegmentedControlSegmentCenter barMetrics:UIBarMetricsDefault];
    [self.segmentedControl setContentPositionAdjustment:UIOffsetMake(-4, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
}

-(void)setDateLabel {
    self.lblTodaysDate.font = [UIFont heroFontWithSize:self.lblTodaysDate.font.pointSize];
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    
     self.lblTodaysDate.text = [[formatter stringFromDate:[NSDate date]] uppercaseString];
}

-(BOOL) isLoggedIn {
    return [ApplicationDelegate isLoggedIn];
}

- (void) setBackgroundImage {
    if ([[self currentEventArray] count] > 0) {
        if(self.hasSearched) {
            NSURL* imageURL = [self.searchedArtistDic imageURL];
            if(!imageURL)
                imageURL = [[self.searchResultsEvents objectAtIndex:0] imageURL];
            UIImage *background = [[UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]] imageWithGaussianBlur];
            [self.imgBackground setImage: background];
            return;
        }
        UIImage *background = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[[[self currentEventArray] objectAtIndex:0] imageURL]]] imageWithGaussianBlur];
        [self.imgBackground setImage:background];
    }
    else [self.imgBackground setImage:nil];
}

#pragma mark - Buttons
-(void)profileTapped {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    [Flurry logEvent:@"Profile_Button_Pressed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.isLoggedIn ? @"Logged_In" : @"Not_Logged_In",@"Logged_In_State",[self currentSearchTypeString],@"Search_Type", nil]];
    if (self.isLoggedIn){
        if (self.profileViewController == nil) {
            ECProfileViewController* profileViewController = [ECProfileViewController new];
            self.profileViewController = [[ECCustomNavController alloc] initWithRootViewController:profileViewController];
            
            //        self.profileViewController.arrPastConcerts = [self.concerts objectForKey:@"past"];
        }
        self.profileViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.profileViewController animated:YES completion:nil];
    }
    
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To view your profile, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECNotLoggedInAlert;
        [alert show];
    }
}

- (IBAction)openLastFM:(id)sender {
    [Flurry logEvent:@"Opened_Last_FM" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self currentSearchTypeString], @"Search_Type",nil]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.last.fm"]];
}

- (IBAction)openLocationSetter {
    if (self.locationSetterView == nil) {
        self.locationSetterView = [ECLocationSetterViewController new];
        self.locationSetterView.delegate = self;
    }
    
    [NSUserDefaults setLastSearchRadius:self.currentSearchRadius];
    [NSUserDefaults synchronize];
    
    [self presentSemiViewController:self.locationSetterView withOptions:@{
     KNSemiModalOptionKeys.pushParentBack : @(NO),
     KNSemiModalOptionKeys.parentAlpha : @(0.8)
	 }];
    [self dismissKeyboard]; //dismiss the keyboard, otherwise it will obstruct the location setter view
}

-(void) hideLocationSetter {
    [self dismissSemiModalView];
}

#pragma mark ECLocationSetterDelegate Method
-(void) updateSearchLocation:(CLLocation *)location radius: (float) radius area: (NSString*) area {
    NSLog(@"new radius %f",radius);
    self.currentSearchLocation = location;
    self.currentSearchRadius = radius;
    self.currentSearchAreaString = area;
    [NSUserDefaults setLastSearchLocation:location];
    [NSUserDefaults setLastSearchRadius:radius];
    [NSUserDefaults setLastSearchArea: area];
    [NSUserDefaults synchronize];
    [self hideLocationSetter];
    
    [self fetchConcerts];
}

-(void) updateRadius:(float)radius {
    NSLog(@"Radius updated");
    self.currentSearchRadius = radius;
}

#pragma mark Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
        }
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Main_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
    }else if (alertView.tag == NoLocationAlert)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            //Manually
            //TODO : push the new location viewcontroller
            [self openLocationSetter];

        }
    }
}

-(void) showLogin {
    [ApplicationDelegate showLoginView: YES];
}

#pragma mark Segmented Control
-(IBAction) switchedSelection: (id) sender {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];

    [self.searchBar resignFirstResponder]; //hide keyboard in case it was visible
    
    UISegmentedControl* control = (UISegmentedControl*)sender;
    self.currentSearchType = [ECNewMainViewController searchTypeForSegmentIndex:control.selectedSegmentIndex];
    self.hasSearched = FALSE; //TODO this flagging system is prone to human error, clean it up.
    [self setBackgroundImage];
    [self resetTableHeaderView]; //remove artist image that appears during search results
    
    //reload data/images
    [self displayViewsAccordingToSearchType];
    [self.tableView reloadData];
    if ([self currentEventArray].count != 0) {
        self.tableView.tableFooterView = emptyView;
    }
    else {
        self.tableView.tableFooterView = self.noConcertsFooterView;
    }
        
    [Flurry logEvent:@"Switched_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self currentSearchTypeString], @"Search_Type",nil]];
}


//return a string based on the current search type for logging to Flurry etc
-(NSString*) currentSearchTypeString {
    switch (self.currentSearchType) {
        case ECSearchTypeToday:
            return @"Today";
        case ECSearchTypeFuture:
            return @"Future";
        case ECSearchTypePast:
            return @"Past";
        default:
            return nil;
    }
}
+(NSInteger) segmentIndexForSearchType:(ECSearchType) searchType {
    switch (searchType) {
        case ECSearchTypePast:
            return 0;
        case ECSearchTypeFuture:
            return 2;
        case ECSearchTypeToday:
            return 1;
        default:
            break;
    }
}
+(ECSearchType) searchTypeForSegmentIndex: (NSInteger) index {
    switch (index) {
        case 0:
            return ECSearchTypePast;
        case 1:
            return ECSearchTypeToday;
        case 2:
            return ECSearchTypeFuture;
        default:
            return ECSearchTypeToday;
    }
    return ECSearchTypeToday;
}

-(BOOL) shouldShowSearchBar {
    return self.currentSearchType != ECSearchTypeToday;
}
#define SEARCH_CONTAINER_HEIGHT 65.0 // HACK
- (void)displayViewsAccordingToSearchType {
    
    if (![self shouldShowSearchBar] && showingSearchBar) {
        CGRect frame = self.tableView.tableHeaderView.frame;
        frame.size.height = frame.size.height - SEARCH_CONTAINER_HEIGHT - 10; //the 10 was arbitrary, fix if needed
        UIView* view = self.tableView.tableHeaderView;
        [view setFrame:frame];
        self.tableView.tableHeaderView = view;
        showingSearchBar = NO;
    }
    else if(!showingSearchBar && [self shouldShowSearchBar]){
        //        [UIView animateWithDuration:1.0 animations:^{
        CGRect frame = self.tableView.tableHeaderView.frame;
        frame.size.height = frame.size.height + SEARCH_CONTAINER_HEIGHT + 10;
        UIView* view = self.tableView.tableHeaderView;

        [view setFrame:frame];

        self.tableView.tableHeaderView = view;
        showingSearchBar = YES;
        //        }];
    }
    self.searchContainer.hidden = self.currentSearchType == ECSearchTypeToday;
    self.searchContainer.userInteractionEnabled = self.currentSearchType != ECSearchTypeToday;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source + Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    if (self.hasSearched) {
//        return ECNumberOfSearchSections;
//    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.hasSearched) {
            return [self.searchResultsEvents count];
    }
    else {
        return [[self currentEventArray] count];
    }
    return 0;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSearched) {
        if (indexPath.section == ECSearchResultSection) {
            ECSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
            NSDictionary * eventDic = [self.searchResultsEvents objectAtIndex:indexPath.row];
            [cell setupCellForEvent:eventDic];
            return cell;
        }
    }
    else { //popular concert cell
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier forIndexPath:indexPath];
        NSArray* concerts = [self currentEventArray];
        NSDictionary * concertDic = [concerts objectAtIndex:indexPath.row];
        

        [cell setUpCellForConcert:concertDic];
        
        //Using UIImageView+AFNetworking, automatically set the cell's image view based on the URL
        [cell.imageArtist setImageWithURL:[concertDic imageURL] placeholderImage:nil]; //TODO add placeholder
        
        return cell;
    }
    
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboard];
}

-(NSArray*) currentEventArray {
    if(self.hasSearched /*&& self.currentSearchType != ECSearchTypeToday8*/) {
        return self.searchResultsEvents;
    }
    switch (self.currentSearchType) {
        case ECSearchTypePast:
            return self.pastConcerts;
        case ECSearchTypeToday:
            return self.todaysConcerts;
        case ECSearchTypeFuture:
            return self.futureConcerts;
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSearched) {
        return SEARCH_CELL_HEIGHT;
    } else {
        return CONCERT_CELL_HEIGHT;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent]; 
    [Flurry logEvent:@"Main_Selected_Row" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self currentSearchTypeString], @"Search_Type", [NSNumber numberWithInt:indexPath.row], @"row", self.hasSearched ? @"post_search" : @"not_post_search", @"is_post_search", nil]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.hasSearched) {
        if (indexPath.section == ECSearchLoadOtherSection) {
            [self.tableView reloadData];
            [self setBackgroundImage];
        }
        else {
            ECConcertDetailViewController* detailVC = [[ECConcertDetailViewController alloc] initWithConcert:[self.searchResultsEvents objectAtIndex:indexPath.row]];
            detailVC.tense = self.currentSearchType;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
    else {
        NSArray* events = [self currentEventArray];
        ECConcertDetailViewController* detailVC = [[ECConcertDetailViewController alloc] initWithConcert:[events objectAtIndex:indexPath.row]];
        detailVC.tense = self.currentSearchType;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Search Text Field

-(void) clearSearchBar {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    self.searchBar.text = @"";
    self.hasSearched = FALSE;
    
    [self.tableView reloadData];
    [self resetTableHeaderView];
    [self setBackgroundImage];
}

//not used because overrided with custom clear image
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.hasSearched = FALSE;
    
    [self.tableView reloadData];
    [self setBackgroundImage];
    [self resetTableHeaderView];
    return YES;
}
-(void) addArtistImageToHeader {
    if (self.searchResultsEvents.count > 0) {
        if(!self.searchHeaderView) {
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"SearchResultsSectionHeader" owner:nil options:nil];
            self.searchHeaderView = [subviewArray objectAtIndex:0];
        }
        UIImageView* artistImage = (UIImageView*)[self.searchHeaderView viewWithTag:10];
        if ([self.searchedArtistDic imageURL]) {
            [artistImage setImageWithURL:[self.searchedArtistDic imageURL] placeholderImage:[UIImage imageNamed: @"placeholder.jpg"]];
        }
        else {
            [artistImage setImageWithURL:[[self.searchResultsEvents objectAtIndex:0] imageURL] placeholderImage:[UIImage imageNamed: @"placeholder.jpg"]];
        }
        
        artistImage.layer.cornerRadius = 5.0;
        artistImage.layer.masksToBounds = YES;
        
        self.searchHeaderView.clipsToBounds =YES;
        CGRect headerFrame = self.tableView.tableHeaderView.frame;
        
        self.searchHeaderView.frame = CGRectMake(0,headerFrame.size.height,320,SEARCH_HEADER_HEIGHT);
        headerFrame.size.height = headerFrame.size.height + SEARCH_HEADER_HEIGHT;
        UIView* header = self.tableView.tableHeaderView;
        header.frame = headerFrame;
        [header addSubview:self.searchHeaderView];
        self.tableView.tableHeaderView = header;
    }
}

-(void) resetTableHeaderView {
    if ([self.searchHeaderView isDescendantOfView:self.tableView.tableHeaderView]) {
        UIView* header = self.tableView.tableHeaderView;
        CGRect frame = header.frame;
        frame.size.height = frame.size.height - SEARCH_HEADER_HEIGHT;
        header.frame = frame;
        [self.searchHeaderView removeFromSuperview];
        self.tableView.tableHeaderView = header;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    if ([textField.text length] > 0) { //don't search empty searches
        [ECJSONFetcher fetchArtistsForString:textField.text withSearchType:self.currentSearchType forLocation:self.currentSearchLocation radius: [NSNumber numberWithFloat:self.currentSearchRadius] completion:^(NSDictionary * comboDic) {
            [self fetchedConcertsForSearch:comboDic];
        }];

        self.hud.labelText = NSLocalizedString(@"Searching", nil);
        self.hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"hudSearchArtist", nil), [textField text]];
        [self.hud show:YES];
        
        [Flurry logEvent:@"Searched_Artist" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"search_text", [self currentSearchTypeString], @"Search_Type", [NSNumber numberWithDouble:self.currentSearchLocation.coordinate.latitude], @"latitude", [NSNumber numberWithDouble:self.currentSearchLocation.coordinate.longitude],@"longitude", [NSNumber numberWithFloat:self.currentSearchRadius], @"radius", self.currentSearchAreaString, @"area_string", nil]];
    }
    [self.view removeGestureRecognizer:self.tap];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:self.tap]; //for dismissing the keyboard if tap outside
}

- (void)fetchedConcertsForSearch:(NSDictionary *)comboDic {
    [self.hud hide:YES];
    [self resetTableHeaderView];
    self.tableView.tableFooterView = emptyView;
    if (comboDic) {
        self.hasSearched = TRUE;
        self.comboSearchResultsDic = comboDic;
        if (!self.searchResultsEvents.count > 0) {
            self.hasSearched = FALSE;
            self.comboSearchResultsDic = nil;
            MBProgressHUD* alert = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            alert.labelText = NSLocalizedString(@"No events found", nil);
            alert.mode = MBProgressHUDModeText;
            alert.removeFromSuperViewOnHide = YES;
            [alert hide:YES afterDelay:ALERT_HIDE_DELAY];
            alert.labelFont = [UIFont heroFontWithSize:18.0f];
            alert.color = [UIColor redHUDConfirmationColor];
            alert.userInteractionEnabled = NO;
        }
    }
    else { //failed to find anything
        self.hasSearched = FALSE;
        self.comboSearchResultsDic = nil;
        MBProgressHUD* alert = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        alert.labelText = NSLocalizedString(@"No artists found",nil);
        alert.mode = MBProgressHUDModeText;
        alert.removeFromSuperViewOnHide = YES;
        [alert hide:YES afterDelay:ALERT_HIDE_DELAY]; //TODO use #define for delay
        alert.labelFont = [UIFont heroFontWithSize:18.0f];
        alert.color = [UIColor redHUDConfirmationColor];
        alert.userInteractionEnabled = NO;
    }
    
    [self.tableView reloadData];
    [self setBackgroundImage];
    [self addArtistImageToHeader];
}

- (void)dismissKeyboard {
    if([self.searchBar isFirstResponder])
        [self.searchBar resignFirstResponder];
    [self.view removeGestureRecognizer:self.tap];
}

#pragma mark Getters on combo search results dic
-(NSArray*) searchResultsEvents {
    if (self.comboSearchResultsDic != nil) {
        return [self.comboSearchResultsDic objectForKey:@"events"];
    }
    return nil;
}

-(NSArray*) otherArtists {
    if (self.comboSearchResultsDic != nil) {
        return [self.comboSearchResultsDic objectForKey: @"others"];
    }
    return nil;
}

-(NSDictionary*) searchedArtistDic {
    if (self.comboSearchResultsDic != nil) {
        return [self.comboSearchResultsDic objectForKey:@"artist"];
    }
    return nil;
}
@end
