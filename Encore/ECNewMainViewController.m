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

typedef enum {
    ECSearchResultSection,
    ECSearchLoadOtherSection,
    ECNumberOfSearchSections //always have this one last
}ECSearchSection;

@interface ECNewMainViewController () {
    BOOL showingSearchBar;
}

@end

@implementation ECNewMainViewController

#pragma mark - View loading
- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchHeaderView = nil;
    self.hasSearched = FALSE;
    self.comboSearchResultsDic = nil;
    [self.tableView registerNib:[UINib nibWithNibName:@"ECSearchResultCell" bundle:nil]
         forCellReuseIdentifier:SearchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:ConcertCellIdentifier];
    
    [self setupBarButtons];
    [self setNavBarAppearance];
    [self setSegmentedControlAppearance];
    [self setDateLabel];
    
    self.tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    if(self.currentSearchLocation)
        [self fetchConcerts];
    
    self.currentSearchType = [NSUserDefaults lastSearchType];//[ECNewMainViewController searchTypeForSegmentIndex:self.segmentedControl.selectedSegmentIndex]; //TODO load from user defaults
    if (self.currentSearchType == 0) { //default if nothing saved is 0, which is invalid.
        self.currentSearchType = ECSearchTypeToday;
    }
    
    [self.segmentedControl setSelectedSegmentIndex:[ECNewMainViewController segmentIndexForSearchType:self.currentSearchType]];
    showingSearchBar = NO; //by default hidden (see storyboard)
    
    [self setupHUD];
    [self setupSearchBar];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    self.view.clipsToBounds = YES;
    
    [self setupRefreshControl];
    [self displayViewsAccordingToSearchType];
    
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

-(void) initializeSearchLocation: (CLLocation*) currentSearchLocation {
    self.currentSearchLocation = currentSearchLocation;
    [self fetchConcerts];
}

-(void) fetchConcerts {
    //TODO add radius
    [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday location: self.currentSearchLocation completion:^(NSArray *concerts) {
        self.todaysConcerts = concerts;
        if (self.segmentedControl.selectedSegmentIndex == [ECNewMainViewController segmentIndexForSearchType:self.currentSearchType]) {
            [self.tableView reloadData];
            [self setBackgroundImage];
        }
        
    }];
    [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypePast location: self.currentSearchLocation completion:^(NSArray *concerts) {
        self.pastConcerts = concerts;
        if (self.segmentedControl.selectedSegmentIndex == [ECNewMainViewController segmentIndexForSearchType:self.currentSearchType]) {
            [self.tableView reloadData];
            [self setBackgroundImage];
        }
    }];
    
    [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeFuture location: self.currentSearchLocation completion:^(NSArray *concerts) {
        self.futureConcerts = concerts;
        if (self.segmentedControl.selectedSegmentIndex == [ECNewMainViewController segmentIndexForSearchType:self.currentSearchType]) {
            [self.tableView reloadData];
            [self setBackgroundImage];
        }
    }];
}

-(void) setupHUD {
    //add hud progress indicator
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor lightBlueHUDConfirmationColor];
    self.hud.labelFont = [UIFont heroFontWithSize:self.hud.labelFont.pointSize];
    self.hud.detailsLabelFont = [UIFont heroFontWithSize:self.hud.detailsLabelFont.pointSize];
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
    
    [ECJSONFetcher fetchPopularConcertsWithSearchType:self.currentSearchType location: self.currentSearchLocation completion:^(NSArray *concerts) {
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
    UIImage *rightButImage = [UIImage imageNamed:@"feedback"];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(feedbackTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    UIBarButtonItem *feedbackButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = feedbackButton;
}

-(void) feedbackTapped {
        [Flurry logEvent:@"Opened_Feedback" withParameters:[NSDictionary dictionaryWithObject:@"MainView" forKey:@"source"]];
    ATConnect *connection = [ATConnect sharedConnection];
    [connection presentMessageCenterFromViewController: self];
}

-(void) setNavBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarlandscape"] forBarMetrics:UIBarMetricsLandscapePhone];  //TODO: figure out what this isn't loading in on rotate.
    
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
    
    [[UISegmentedControl appearance] setBackgroundImage:unselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:selected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:dividerLeftActive forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:dividerRightActive forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setDividerImage:bothInactive forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
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

    [[UISegmentedControl appearance] setTitleTextAttributes:selectedTextAttr forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setTitleTextAttributes:unselectedTextAttr forState:UIControlStateNormal];

    //Guess and check to get right offset. May not be perfect, seems to be good though
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(4, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(0, 0) forSegmentType:UISegmentedControlSegmentCenter barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(-4, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
}

-(void)setDateLabel {
    self.lblTodaysDate.font = [UIFont heroFontWithSize:self.lblTodaysDate.font.pointSize];
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy"];
    
     self.lblTodaysDate.text = [[formatter stringFromDate:[NSDate date]] uppercaseString];
}

-(ECAppDelegate*) appDelegate  {
    return (ECAppDelegate*)[UIApplication sharedApplication].delegate;
}

-(BOOL) isLoggedIn {
    return [[self appDelegate] isLoggedIn];
}

- (void) setBackgroundImage {
    if ([[self currentEventArray] count] > 0) {
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
-(void) updateSearchLocation:(CLLocation *)location radius: (float) radius {
    self.currentSearchLocation = location;
    self.currentSearchRadius = [NSNumber numberWithFloat:radius];
    [NSUserDefaults setLastSearchLocation:location];
    [NSUserDefaults setLastSearchRadius:radius];
    [NSUserDefaults synchronize];
    [self hideLocationSetter];
    
    //TODO update all the popular concerts according to the new location
    [self fetchConcerts];
}

#pragma mark Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [[self appDelegate] openSession];
        }
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Main_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
    }
}

-(void) showLogin {
    [[self appDelegate] showLoginView: YES];
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
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
    else {
        NSArray* events = [self currentEventArray];
        ECConcertDetailViewController* detailVC = [[ECConcertDetailViewController alloc] initWithConcert:[events objectAtIndex:indexPath.row]];
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
        
        [artistImage setImageWithURL:[[self.searchResultsEvents objectAtIndex:0] imageURL] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
        
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

-(ECSearchType) tenseForSearchType {
    return self.currentSearchType == ECSearchTypeToday ? ECSearchTypeFuture : ECSearchTypePast;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    if ([textField.text length] > 0) { //don't search empty searches
        [ECJSONFetcher fetchArtistsForString:textField.text withSearchType:[self tenseForSearchType] forLocation:self.currentSearchLocation completion:^(NSDictionary * comboDic) { //TODO load actual location
            [self fetchedConcertsForSearch:comboDic];
        }];

        self.hud.labelText = NSLocalizedString(@"Searching", nil);
        self.hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"hudSearchArtist", nil), [textField text]];
        [self.hud show:YES];
        
        [Flurry logEvent:@"Searched_Artist" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"search_text", [self currentSearchTypeString], @"Search_Type", nil]];
    }
    [self.view removeGestureRecognizer:self.tap];
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.view addGestureRecognizer:self.tap];
}

- (void)fetchedConcertsForSearch:(NSDictionary *)comboDic {
    [self.hud hide:YES];
    [self resetTableHeaderView];
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
            [alert hide:YES afterDelay:ALERT_HIDE_DELAY]; //TODO use #define for delay
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
