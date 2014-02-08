//
//  ECNewMainViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
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
#import "ECAppDelegate.h"
#import "UIImage+GaussBlur.h"
#import <QuartzCore/QuartzCore.h>

#import "ECAlertTags.h"

#import "NSUserDefaults+Encore.h"
#import "ECCustomNavController.h"
#import "ECUpcomingViewController.h"
#import "ECPastViewController.h"

#import "SPGooglePlacesAutocompleteViewController.h"
#import "ECLoginViewController.h"

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
    UIView* lastFMView;
    NSDictionary* abbrvDic;
    
}
@property (assign) NSInteger page;
@property (assign) NSInteger totalUpcoming;
@property (assign) BOOL viewLoaded;
@property (assign) BOOL showLoadMore;
@property (assign) BOOL shouldReload;
@property (nonatomic,weak) UIActivityIndicatorView* loadMoreActivityIndicator;
@property (nonatomic,weak) UIButton* loadMoreButton;
@end

@implementation ECNewMainViewController

#pragma mark - View loading
- (void)viewDidLoad {
    [super viewDidLoad];

    //Initializations;
    abbrvDic = nil;
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
    [self setupLastFMView];
    self.shouldReload= NO;
    self.locationLabel.font = [UIFont heroFontWithSize:16.0f];

    self.tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self initializeSearchLocation];
    self.page = 1;
    self.showLoadMore = NO;
    self.currentSearchType = [NSUserDefaults lastSearchType];
    if (self.currentSearchType == 0) { //default if nothing saved is 0, which is invalid.
        self.currentSearchType = ECSearchTypeToday;
    }
    [self displayViewsAccordingToSearchType];
    
    [self.segmentedControl setSelectedSegmentIndex:[ECNewMainViewController segmentIndexForSearchType:self.currentSearchType]];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    self.view.clipsToBounds = YES;
    self.futureConcerts = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.viewLoaded)
    {
        self.viewLoaded= YES;
        //If walkthough finished animating
        if(![NSUserDefaults shouldShowWalkthrough])
        {
            //if user already set location using select location controller don't listen to location changes
            if([NSUserDefaults lastSearchLocation].coordinate.latitude == 0 && [NSUserDefaults lastSearchLocation].coordinate.longitude == 0)
            {
                [(ECAppDelegate*)[[UIApplication sharedApplication] delegate] setUpLocationManager];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationAcquired) name:ECLocationAcquiredNotification object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LocationFailed) name:ECLocationFailedNotification object:nil];
            }
            
            else {
                if (![ApplicationDelegate connected]) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No connection!" message:@"You must be connected to the internet to use Encore. Sorry pal." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Try again", nil];
                    alert.tag = ECNoNetworkAlertTag;
                    [alert show];
                }
                else {
                    [self fetchConcerts];
                }
                NSString* city = [NSUserDefaults lastSearchArea];
                if  (city == nil) {
                    CLLocation* location = [NSUserDefaults userCoordinate];
                    CLGeocoder* geocoder = [CLGeocoder new];
                    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (error) {
                            NSLog(@"Error reverse geocoding: %@", error.description);
                            self.locationLabel.text = @"";
                        }
                        
                        else {
                            CLPlacemark* placemark = [placemarks objectAtIndex:0];
                            self.locationLabel.text = placemark.locality != nil ? placemark.locality : placemark.subAdministrativeArea;
                            [NSUserDefaults setLastSearchArea:self.locationLabel.text];
                        }
                    }];

                }
                else self.locationLabel.text = city;
                
            }
        }else{
            self.viewLoaded= NO;
        }
    }
}

-(void) setupLastFMView {
    lastFMView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width,25.0f)];
    UIButton* lastFMBUtton = [[UIButton alloc] initWithFrame:CGRectMake(100.0f, 6.0f, 98.0f, 13.0f)];
    [lastFMBUtton addTarget:self action:@selector(openLastFM:) forControlEvents:UIControlEventTouchUpInside];
    [lastFMBUtton setBackgroundImage:[UIImage imageNamed:@"lastfmAttr"] forState:UIControlStateNormal];
    [lastFMBUtton setContentMode:UIViewContentModeScaleAspectFit];
    [lastFMView addSubview: lastFMBUtton];
    self.tableView.tableFooterView = lastFMView;
}

-(void)LocationAcquired
{
    NSLog(@"Location acquired");
    [self initializeSearchLocation];// automatically figures out if there's a saved one and if not returns the user coordinate
    [self fetchConcerts];
}
-(void)LocationFailed
{
    NSLog(@"Location failed");
    // Failed to get location using location services and there is no location saved
    if ([NSUserDefaults lastSearchLocation].coordinate.latitude == 0 && [NSUserDefaults lastSearchLocation].coordinate.longitude == 0)
    {
        //Show alert
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location Needed", nil) message:NSLocalizedString(@"To re-enable, please go to Settings and turn on Location Service for this app or set location manually", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Manually", nil),NSLocalizedString(@"OK", nil), nil];
        alert.tag = NoLocationAlert;
        [alert show];
        
    }
    else { //there is a saved location
        [self initializeSearchLocation];
        [self fetchConcerts];
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
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
    
    NSString* city = [NSUserDefaults lastSearchArea];
    NSString* city2 = [NSUserDefaults searchCity];
    self.locationLabel.text = city == nil ? city2 : city;
}

-(void) setEventArray: (NSArray*) concerts forType: (ECSearchType) searchType {
    switch (searchType) {
        case ECSearchTypeToday:
            self.todaysConcerts = concerts;
            break;
        case ECSearchTypeFuture:
            self.showLoadMore = concerts.count == 0 ? NO:YES;
          //  self.showLoadMore = NO;
            if(self.shouldReload){
                self.shouldReload = NO;
                [self.futureConcerts removeAllObjects];
            }
            [self.futureConcerts addObjectsFromArray:concerts];
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
        _noConcertsFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        _noConcertsFooterView.backgroundColor = [UIColor clearColor];
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20,30,280,150)];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 0;
        label.tag = 213;
        
        [_noConcertsFooterView addSubview:label];
    }
    
    UILabel* label = (UILabel*)[_noConcertsFooterView viewWithTag:213];
    NSString* message = nil;
    switch (self.currentSearchType) {
        case ECSearchTypePast:
            message = @"No one has added a show in your area recently.\n\nSearch for a show above or try changing your location";
            break;
        case ECSearchTypeToday:
            message = @"We couldn't find any shows in %@ today\n\nRoadtrip? Try changing your location to a city nearby";
            break;
        case ECSearchTypeFuture:
            message = @"We couldn't find any upcoming shows in %@.\n\nTry changing your location or check back later.";
            break;
        default:
            break;
    }
    
    label.text = [NSString stringWithFormat:message,[NSUserDefaults lastSearchArea]];
    
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
        if( !(self.currentSearchType == ECSearchTypeFuture && self.showLoadMore))
            [self showLoadingHUD];
    }
    [ECJSONFetcher fetchPopularConcertsWithSearchType:type location:self.currentSearchLocation radius:[NSNumber numberWithFloat:self.currentSearchRadius] page:self.page completion:^(NSArray *concerts, NSInteger total) {
        if(type == ECSearchTypeFuture && concerts.count > 0) {
            self.page++;
            self.totalUpcoming = total;
        }
        [self fetchedPopularConcerts:concerts forType:type];
        if (type == self.currentSearchType) {
            [self.hud hide:YES];
        }
    }];
}

-(void) fetchedPopularConcerts: (NSArray*) concerts forType: (ECSearchType) searchType {
    [self setEventArray: concerts forType: searchType];
    
    if(searchType == self.currentSearchType){
        if ([self currentEventArray].count == 0) {
            self.tableView.tableFooterView = self.noConcertsFooterView;
        }
        else {
            self.tableView.tableFooterView = lastFMView;
        }
        [self.hud hide:YES];
        [self updateLoadMoreCell];
    }
    if (self.segmentedControl.selectedSegmentIndex == [ECNewMainViewController segmentIndexForSearchType:searchType]) {
        [self.tableView reloadData];
        [self setBackgroundImage];
    }
}

-(void) updateLoadMoreCell {
    if (self.currentSearchType == ECSearchTypeFuture) {
        [self.loadMoreActivityIndicator stopAnimating];
        [self.loadMoreButton setEnabled:self.totalUpcoming > self.futureConcerts.count];
        [self.loadMoreButton setHidden:self.totalUpcoming <= self.futureConcerts.count];
        self.showLoadMore = self.totalUpcoming > self.futureConcerts.count;
        if (self.futureConcerts.count == 0 || self.futureConcerts.count == self.totalUpcoming) { //no more pages to load
            self.showLoadMore = NO;
            [self.loadMoreActivityIndicator stopAnimating];
            [self.loadMoreButton setEnabled:NO];
            [self.loadMoreButton setHidden:YES];
        }
        else if (self.totalUpcoming > self.futureConcerts.count) {
            [self.loadMoreButton setTitle:@"Load More" forState:UIControlStateNormal];
        }
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
    self.page = 1;
    [ECJSONFetcher fetchPopularConcertsWithSearchType:self.currentSearchType location: self.currentSearchLocation radius: [NSNumber numberWithFloat:self.currentSearchRadius] page:self.page completion:^(NSArray *concerts,NSInteger total) {
        if(self.currentSearchType == ECSearchTypeFuture){
            [self.futureConcerts removeAllObjects];
            self.totalUpcoming = total;
        }
        [self setEventArray:concerts forType:self.currentSearchType];
        
        [self.tableView reloadData];
        
        [self updateLoadMoreCell];

        
        if ([self currentEventArray].count == 0) {
            self.tableView.tableFooterView = self.noConcertsFooterView;
        }
        else {
            self.tableView.tableFooterView = lastFMView;
        }
        
        [self.hud hide:YES];
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

//Set up left bar button for going to profile and right bar button for location
-(void) setupBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"profileButton"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(profileTapped) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = profileButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *rightButImage = [UIImage imageNamed:@"locationmarkerbutton"];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(modifySearchLocation) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    
    UIBarButtonItem* locationButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = locationButton;
}

-(void) feedbackTapped {
    [Flurry logEvent:@"Opened_Feedback" withParameters:[NSDictionary dictionaryWithObject:@"MainView" forKey:@"source"]];
    ATConnect *connection = [ATConnect sharedConnection];
    [connection presentMessageCenterFromViewController: self];
}

-(void) setNavBarAppearance {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")){
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar"] forBarMetrics:UIBarMetricsDefault];
        if( IS_IPHONE_5 )
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarlandscape-568h"] forBarMetrics:UIBarMetricsLandscapePhone];
        else
            [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbarlandscape"] forBarMetrics:UIBarMetricsLandscapePhone];
            [[UINavigationBar appearance] setTintColor:[UIColor clearColor]];
            [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
//                [self.navigationController.navigationBar setBackgroundColor:[UIColor blueArtistTextColor]];
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor blueArtistTextColor]];
        [self.navigationController.navigationBar setTranslucent:IS_IPHONE_5];
    }
    
    //Use default navbar in youtube player
    [[UINavigationBar appearanceWhenContainedIn:[MPMoviePlayerViewController class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
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
    UIImage* dividerLeftActiveRightDisabled = [UIImage imageNamed:@"disabledright"];
    UIImage* dividerRightActiveLeftDisabled = [UIImage imageNamed:@"disabledleft"];
    UIImage* dividerBothDisabled = [UIImage imageNamed:@"disabledboth"];
    
    [[UISegmentedControl appearance] setBackgroundImage:unselected forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setBackgroundImage:selected forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UISegmentedControl appearance] setTintColor:[UIColor whiteColor]];
    }else{
    [[UISegmentedControl appearance] setDividerImage:dividerLeftActive
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:dividerLeftActiveRightDisabled
                                 forLeftSegmentState:UIControlStateSelected
                                   rightSegmentState:UIControlStateDisabled
                                          barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:dividerRightActive
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:dividerRightActiveLeftDisabled
                                 forLeftSegmentState:UIControlStateDisabled
                                   rightSegmentState:UIControlStateSelected
                                          barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:bothInactive
                                 forLeftSegmentState:UIControlStateNormal
                                   rightSegmentState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setDividerImage:dividerBothDisabled
                                 forLeftSegmentState:UIControlStateDisabled
                                   rightSegmentState:UIControlStateDisabled
                                          barMetrics:UIBarMetricsDefault];
    }

    
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowColor = nil;
    shadow.shadowOffset = CGSizeMake(0, 0);
    
    NSDictionary* selectedTextAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor], NSForegroundColorAttributeName,
                                      shadow, NSShadowAttributeName,
                                      [UIFont heroFontWithSize:17.0f], NSFontAttributeName,
                                       nil];
    NSDictionary* unselectedTextAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor unselectedSegmentedControlColor], NSForegroundColorAttributeName,
                                        shadow, NSShadowAttributeName,
                                        [UIFont heroFontWithSize:17.0f], NSFontAttributeName,
                                        nil];

    [[UISegmentedControl appearance] setTitleTextAttributes:selectedTextAttr forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setTitleTextAttributes:unselectedTextAttr forState:UIControlStateNormal];

    //The following code screwed up the sharing from UIActivityViewController
    //Guess and check to get right offset. May not be perfect, seems to be good though
//    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(4, 0) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(0, 0) forSegmentType:UISegmentedControlSegmentCenter barMetrics:UIBarMetricsDefault];
//    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(-4, 0) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];
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
    NSArray* currentEventArray = [self currentEventArray];
    if ([currentEventArray count] > 0) {
        if(self.hasSearched) {
            NSURL* imageURL = [self.searchedArtistDic imageURL];
            if(!imageURL)
                imageURL = [[self.searchResultsEvents objectAtIndex:0] imageURL];
            UIImage *background = [[UIImage imageWithData: [NSData dataWithContentsOfURL:imageURL]] imageWithGaussianBlur];
            [self.imgBackground setImage: background];
            return;
        }

        int i = 0;
        NSURL* url = nil;
        while (url == nil) {
            url = [[currentEventArray objectAtIndex:i++] imageURL];
        }
        UIImage *background = [[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] imageWithGaussianBlur];
        [self.imgBackground setImage:background];
    }
    else [self.imgBackground setImage:nil];
}

#pragma mark - Buttons
-(void)profileTapped {
    [self showLoadingHUD];
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    [Flurry logEvent:@"Profile_Button_Pressed" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.isLoggedIn ? @"Logged_In" : @"Not_Logged_In",@"Logged_In_State",[self currentSearchTypeString],@"Search_Type", nil]];
    if (self.isLoggedIn){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
        if (self.profileViewController == nil) {
            ECProfileViewController* profileViewController = [ECProfileViewController new];
            self.profileViewController = [[ECCustomNavController alloc] initWithRootViewController:profileViewController];
        }else{
            [[self.profileViewController.viewControllers objectAtIndex:0] performSelector:@selector(profileUpdated)]; // Update profile
        }
        self.profileViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:self.profileViewController animated:YES completion:^{
            [self.hud hide:YES];
        }];
    }
    
    else {
        ECLoginViewController* login = [[ECLoginViewController alloc] init];
//        ECCustomNavController* navCtrl = [[ECCustomNavController alloc] initWithRootViewController:login];
//        navCtrl.navigationBarHidden = YES;
        [self.navigationController presentViewController:login animated:YES completion:^{
            [self.hud hide:YES];
        }];
        
    }
}

- (IBAction)openLastFM:(id)sender {
    [Flurry logEvent:@"Opened_Last_FM" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self currentSearchTypeString], @"Search_Type",nil]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.last.fm"]];
}


-(IBAction) modifySearchLocation {
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"GooglePlacesAutocompleteView" bundle:nil];
    SPGooglePlacesAutocompleteViewController * viewController = [sb instantiateInitialViewController];
    viewController.delegate = self;
    viewController.initialLocation = self.currentSearchLocation;
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void) updatedSearchLocationToPlacemark:(CLPlacemark *)placemark{
    [self showLoadingHUD];
    float radius = 1.0f;
    NSString* adminArea = placemark.administrativeArea;
    if(SYSTEM_VERSION_LESS_THAN(@"7.0")){
        if([placemark.ISOcountryCode isEqualToString:@"CA"] || [placemark.ISOcountryCode isEqualToString:@"US"]){ //use standard abbreviations for US and Canada.
        if (!abbrvDic) {
            NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"ProvinceStateAbbrv" ofType:@"plist"];
            abbrvDic = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        }
         adminArea = [[abbrvDic objectForKey:[adminArea lowercaseString]] uppercaseString]; //search by lowercase for consistency, display as uppercase
        }
    }
    NSString* area = [NSString stringWithFormat:@"%@, %@",placemark.locality ? placemark.locality : placemark.subAdministrativeArea,adminArea];
    
    CLLocation* location = placemark.location;
    NSString* locality = placemark.locality ? placemark.locality : placemark.subAdministrativeArea;
    
    NSLog(@"new radius %f",radius);
    self.currentSearchLocation = location;
    self.currentSearchRadius = radius;
    self.currentSearchAreaString = area;
    self.shouldReload = YES;
    self.page = 1;
    self.locationLabel.text = area;
    
    [NSUserDefaults setLastSearchLocation:location];
//    [NSUserDefaults setLastSearchRadius:radius];
    [NSUserDefaults setLastSearchArea: area];
    [NSUserDefaults setSearchCity:locality];
    [NSUserDefaults synchronize];
    [self fetchConcerts];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    if (self.hasSearched) {
        //redo search with new location
        [ECJSONFetcher fetchArtistsForString:self.searchBar.text withSearchType:self.currentSearchType forLocation:self.currentSearchLocation radius:[NSNumber numberWithFloat:self.currentSearchRadius] completion:^(NSDictionary *artists) {
            [self fetchedConcertsForSearch:artists];
            [self.hud hide:YES];
        }];
    }

}

#pragma mark Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profileTapped) name:ECLoginCompletedNotification object:nil];

        }
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Main_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
    }else if (alertView.tag == NoLocationAlert)
    {
        if(buttonIndex == alertView.firstOtherButtonIndex)
        {
            [self modifySearchLocation];

        }
    }
    else if (alertView.tag == ECNoNetworkAlertTag) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            if ([ApplicationDelegate connected]) {
                [self fetchConcerts];
            }
            else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No Internet" message:@"Still not getting an internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Try again", nil];
                alert.tag = ECNoNetworkAlertTag;
                [alert show];
            }
        }
    }
}

-(void) showLogin {
    [ApplicationDelegate showLoginView: YES];
}
-(MBProgressHUD*) switchingHUD {
    if (!_switchingHUD) {
        _switchingHUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:_switchingHUD];
    }
    return _switchingHUD;
}
#pragma mark Segmented Control

-(IBAction) switchedSelection: (id) sender {
    [self.switchingHUD show:YES];
    [self performSelector:@selector(reloadTableViewForSwitchedSelection) withObject:nil afterDelay:0.1];
}

-(void) reloadTableViewForSwitchedSelection {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    [self.searchBar resignFirstResponder]; //hide keyboard in case it was visible
    
    UISegmentedControl* control = self.segmentedControl;
    self.currentSearchType = [ECNewMainViewController searchTypeForSegmentIndex:control.selectedSegmentIndex];
    self.hasSearched = FALSE; //TODO this flagging system is prone to human error, clean it up.
    
    [self resetTableHeaderView]; //remove artist image that appears during search results
    
    //reload data/images
    [self.tableView reloadData];
    
    [self setBackgroundImage];
    [self displayViewsAccordingToSearchType];
    
    if ([self currentEventArray].count != 0) {
        self.tableView.tableFooterView = lastFMView;
    }
    else /*if (self.currentSearchType != ECSearchTypePast)*/ {
        self.tableView.tableFooterView = self.noConcertsFooterView;
    }
    
    [Flurry logEvent:@"Switched_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[self currentSearchTypeString], @"Search_Type",nil]];
    [self.switchingHUD hide:YES];
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
        if(self.currentSearchType == ECSearchTypeFuture && self.showLoadMore)
            return [[self currentEventArray] count]+1;// 1 for loading more cell
        else
            return [[self currentEventArray] count];
    }
    return 0;
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
        NSArray* concerts = [self currentEventArray];
        if(concerts.count == indexPath.row){
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMore"];
            UIActivityIndicatorView* load = (UIActivityIndicatorView*)[cell viewWithTag:55];
            UIButton* loadMoreButton = (UIButton*) [cell viewWithTag:56];
            [loadMoreButton addTarget:self action:@selector(loadMoreTapped) forControlEvents:UIControlEventTouchUpInside];
            self.loadMoreActivityIndicator = load;
            self.loadMoreButton = loadMoreButton;
            return cell;
        }
        
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier forIndexPath:indexPath];
        NSDictionary * concertDic = [concerts objectAtIndex:indexPath.row];

        [cell setUpCellForConcert:concertDic];
        
        //Using UIImageView+AFNetworking, automatically set the cell's image view based on the URL
        __block ECConcertCellView* cellBlock = cell;
        [cell.imageArtist setImageWithURLRequest:[NSURLRequest requestWithURL:[concertDic imageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            cellBlock.imageArtist.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            cellBlock.imageArtist.image = [UIImage imageNamed:@"placeholder"];
        }];
//        [cell.imageArtist setImageWithURL:[concertDic imageURL] placeholderImage:nil];
        return cell;
    }
    
    return nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self dismissKeyboard];
}

-(void) loadMoreTapped {
    [self.loadMoreButton setEnabled:NO];
    [self.loadMoreButton setTitle:@"Loading..." forState:UIControlStateNormal];
    NSLog(@"%@: Load More tapped. Currently showing %d concerts. Total remaining: %d Page: %d",NSStringFromClass(self.class),self.futureConcerts.count,self.totalUpcoming,self.page-1);
    if (self.totalUpcoming > self.futureConcerts.count) {
        [self.loadMoreActivityIndicator startAnimating];
        [self fetchPopularConcertsWithSearchType:ECSearchTypeFuture];
    }
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
            if (self.currentSearchType == ECSearchTypePast) {       
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
                ECPastViewController * vc = [sb instantiateInitialViewController];
                vc.tense = self.currentSearchType;
                vc.backButtonShouldGlow =  NO;
                vc.concert = [self.searchResultsEvents objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECUpcomingStoryboard" bundle:nil];
                ECUpcomingViewController * vc = [sb instantiateInitialViewController];
                vc.tense = self.currentSearchType;
                vc.backButtonShouldGlow = NO;
                vc.concert = [self.searchResultsEvents objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    }
    else {
        NSArray* events = [self currentEventArray];
        if (events.count <= indexPath.row) return; // selected the load more cell
        NSDictionary* concert = [events objectAtIndex:indexPath.row];
        if (self.currentSearchType == ECSearchTypePast) {
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
            ECPastViewController * vc = [sb instantiateInitialViewController];
            vc.backButtonShouldGlow = NO;
            vc.tense = self.currentSearchType;
            vc.concert = concert;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else {
            UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECUpcomingStoryboard" bundle:nil];
            ECUpcomingViewController * vc = [sb instantiateInitialViewController];
            vc.tense = self.currentSearchType;
            vc.backButtonShouldGlow = NO;
            vc.concert = concert;
            [self.navigationController pushViewController:vc animated:YES];
        }
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
            [artistImage setImageWithURL:[self.searchedArtistDic imageURL] placeholderImage:[UIImage imageNamed: @"placeholder"]];
        }
        else {
            [artistImage setImageWithURL:[[self.searchResultsEvents objectAtIndex:0] imageURL] placeholderImage:[UIImage imageNamed: @"placeholder"]];
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
    self.tableView.tableFooterView = lastFMView;
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
