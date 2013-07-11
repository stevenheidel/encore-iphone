//
//  ECNewMainViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

#import "ECNewMainViewController.h"
#import "ECJSONFetcher.h"

#import "ECConcertCellView.h"
#import "ECSearchResultCell.h"
#import "NSDictionary+ConcertList.h"
#import "UIImageView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "ECConcertDetailViewController.h"
#import "ECAppDelegate.h"

#import "ECAlertTags.h"
#define SearchCellIdentifier @"ECSearchResultCell"
#define ConcertCellIdentifier @"ECConcertCellView"

typedef enum {
    ECSearchResultSection,
    ECSearchLoadOtherSection,
    ECNumberOfSearchSections //always have this one last
}ECSearchSection;

@interface ECNewMainViewController ()

@end

@implementation ECNewMainViewController

#pragma mark - View loading
- (void)viewDidLoad {
    [super viewDidLoad];
    self.hasSearched = FALSE;
    self.loadOther = FALSE;
    self.comboSearchResultsDic = nil;
    [self.tableView registerNib:[UINib nibWithNibName:@"ECSearchResultCell" bundle:nil]
         forCellReuseIdentifier:SearchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:ConcertCellIdentifier];
    
    [self setupBarButtons];
    [self setNavBarAppearance];
    [self setSegmentedControlAppearance];
    [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday completion:^(NSArray *concerts) {
//            [self fetchedPopularConcerts:concerts];
        self.todaysConcerts = concerts;
        [self.tableView reloadData];
        }];
        //        [self.hud show:YES];
    [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypePast completion:^(NSArray *concerts) {
        self.pastConcerts = concerts;
//        [self.tableView reloadData];
    }];
    self.currentSearchType = [ECNewMainViewController searchTypeForSegmentIndex:self.segmentedControl.selectedSegmentIndex];
    
    
    //add hud progress indicator
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor lightBlueHUDConfirmationColor];
    self.hud.labelFont = [UIFont heroFontWithSize:self.hud.labelFont.pointSize];
    self.hud.detailsLabelFont = [UIFont heroFontWithSize:self.hud.detailsLabelFont.pointSize];
    
    //Add padding for search bar
    UIView* paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.SearchBar.leftView = paddingView;
    self.SearchBar.leftViewMode = UITextFieldViewModeAlways;
    self.SearchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.SearchBar.font = [UIFont heroFontWithSize:14.0f];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];

    [button setImage:[UIImage imageNamed:@"xbutton"] forState:UIControlStateNormal];
    button.frame = CGRectMake(0,0,26,30);
    [button addTarget:self action:@selector(clearSearchBar) forControlEvents:UIControlEventTouchUpInside];
    self.SearchBar.rightView = button;
    self.SearchBar.rightViewMode = UITextFieldViewModeAlways;
    
    self.view.backgroundColor = [UIColor blackColor];
}
-(void) clearSearchBar {
    self.SearchBar.text = @"";
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

//Set up left bar button for going to profile and right bar button for sharing
-(void) setupBarButtons {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"profileButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(profileTapped) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *profileButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = profileButton;
    
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
//    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
//    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
//    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
//    self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    self.shareButton.enabled = NO;
//    self.navigationItem.rightBarButtonItem = self.shareButton;
}

-(void) setNavBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
    
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
                                      [UIFont heroFontWithSize:16.0f], UITextAttributeFont,
                                       nil];
    NSDictionary* unselectedTextAttr = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor], UITextAttributeTextColor,
                                        [UIColor clearColor], UITextAttributeTextShadowColor,
                                        [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowOffset,
                                        [UIFont heroFontWithSize:16.0f], UITextAttributeFont,
                                        nil];
//    UIOffsetMake(CGFloat horizontal, CGFloat vertical)
    [[UISegmentedControl appearance] setTitleTextAttributes:selectedTextAttr forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setTitleTextAttributes:unselectedTextAttr forState:UIControlStateNormal];
    
    //Guess and check to get right offset. May not be perfect, seems to be good though
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(4, 2) forSegmentType:UISegmentedControlSegmentLeft barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(-4, 2) forSegmentType:UISegmentedControlSegmentRight barMetrics:UIBarMetricsDefault];

}
-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.todaysConcerts = concerts;
    NSLog(@"%@: %@", NSStringFromClass([self class]), self.todaysConcerts.description);
//    for (NSDictionary *concertDic in concerts) {
//        NSURL *imageURL = [concertDic imageURL];
//        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
//        if (regImage) {
//            [self.arrTodaysImages addObject:regImage];
//        } else {
//            [self.arrTodaysImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
//        }
//    }
    [self.tableView reloadData];
//    [self.hud hide:YES];
//    [self setupAttribution];
//    [self.delegate doneLoadingTodayConcerts];
}

//-(void) getArtistImages {
//    for (NSDictionary *concertDic in self.todaysConcerts) {
//        NSURL *imageURL = [concertDic imageURL];
//        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
//        if (regImage) {
//            [self.arrTodaysImages addObject:regImage];
//        } else {
//            [self.arrTodaysImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
//        }
//    }
//}

-(ECAppDelegate*) appDelegate  {
    return (ECAppDelegate*)[UIApplication sharedApplication].delegate;
}

-(BOOL) isLoggedIn {
    return [[self appDelegate] isLoggedIn];
}

#pragma mark - Buttons
-(void)profileTapped {
    [Flurry logEvent:@"Profile_Button_Pressed"];
    if (self.isLoggedIn){
        if (self.profileViewController == nil) {
            ECProfileViewController* profileViewController = [ECProfileViewController new];
            self.profileViewController = [[UINavigationController alloc] initWithRootViewController:profileViewController];
            
            //        self.profileViewController.arrPastConcerts = [self.concerts objectForKey:@"past"];
        }
        self.profileViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:self.profileViewController animated:YES completion:nil];
    }
    
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To view your profile, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECNotLoggedInAlert;
        [alert show];
    }
}

#pragma mark Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [self showLogin];
        }
        else {
            [Flurry logEvent:@"Canceled_Login_From_Alert"];//This is not the only place this log is made
        }
    }
}
-(void) showLogin {
    [[self appDelegate] showLoginView: YES];
}
#pragma mark Segmented Control
-(IBAction) switchedSelection: (id) sender {
    self.hasSearched = FALSE;
    self.loadOther = FALSE;
    self.SearchBar.text = @"";
    [self.SearchBar resignFirstResponder];
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    self.currentSearchType = [ECNewMainViewController searchTypeForSegmentIndex:control.selectedSegmentIndex];
    [self.tableView reloadData];
}

+(ECSearchType) searchTypeForSegmentIndex: (NSInteger) index {
    //TODO change when adding future
    switch (index) {
        case 0:
            return ECSearchTypePast;
        case 1:
            return ECSearchTypeToday;
        default:
            return ECSearchTypeToday;
    }
    return ECSearchTypeToday;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source + Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hasSearched) {
        return ECNumberOfSearchSections;
    }
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.hasSearched) {
        if (section == ECSearchResultSection) {
            return [self.searchResultsEvents count];
        }
        if (section == ECSearchLoadOtherSection) {
            return self.loadOther ? self.otherArtists.count : 1;
        }
        
    } else if (self.currentSearchType == ECSearchTypeToday) {
        return [self.todaysConcerts count];
    }
    else if (self.currentSearchType == ECSearchTypePast) {
        return [self.pastConcerts count];
    }
    return 0;
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSearched) {
    }
    else {
    //TODO: remove when background set up properly
        cell.backgroundColor = [UIColor blackColor];
        cell.accessoryView.backgroundColor = [UIColor blackColor];
//        cell.contentView.superview.backgroundColor = [UIColor blackColor];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasSearched) {
        if (indexPath.section == ECSearchResultSection) {
            ECSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchCellIdentifier forIndexPath:indexPath];
            NSDictionary * eventDic = [self.searchResultsEvents objectAtIndex:indexPath.row];
            [cell setupCellForEvent:eventDic];
            return cell;
        }
        else if (indexPath.section == ECSearchLoadOtherSection) {
            if(!self.loadOther) {
                //TODO: customize cell
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.textLabel.text = @"Wrong artist?";
                cell.textLabel.textColor = [UIColor whiteColor];
                return cell;
            }
            else {
                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.textLabel.text = [[self.otherArtists objectAtIndex:indexPath.row] objectForKey:@"name"];
                cell.textLabel.textColor = [UIColor whiteColor];
                return cell;
            }
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

-(NSArray*) currentEventArray {
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.hasSearched) {
        if (indexPath.section == ECSearchLoadOtherSection) {
            self.loadOther = TRUE;
            [self.tableView reloadData];
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
    if (self.hasSearched && self.searchResultsEvents.count>0) {
        if (section == ECSearchResultSection) {
            NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"SearchResultsSectionHeader" owner:nil options:nil];
            UIView *mainView = [subviewArray objectAtIndex:0];
//            [(UILabel*)[mainView viewWithTag:20] setText:[[self.searchResultsEvents objectAtIndex:0] artistName]];
            [(UIImageView*)[mainView viewWithTag:10] setImageWithURL:[[self.searchResultsEvents objectAtIndex:0] imageURL] placeholderImage:nil];
            mainView.clipsToBounds =YES;
            return mainView;
        }
    }
    return nil;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.hasSearched && section == ECSearchResultSection && self.searchResultsEvents.count>0) {
        return 117.0;
    }
    return 0.0;
}

#pragma mark - Search Text Field
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.hasSearched = FALSE;
    
    [self.tableView reloadData];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField.text length] > 0) {
        [ECJSONFetcher fetchArtistsForString:textField.text withSearchType:self.currentSearchType forLocation:self.userCity completion:^(NSDictionary * comboDic) { //TODO load actual location
            [self fetchedConcertsForSearch:comboDic];
        }];
        
        self.hud.labelText = NSLocalizedString(@"Searching", nil);
        self.hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"hudSearchArtist", nil), [textField text]];
        [self.hud show:YES];
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)fetchedConcertsForSearch:(NSDictionary *)comboDic {
    [self.hud hide:YES];
    if (comboDic) {
        self.hasSearched = TRUE;
        self.loadOther = FALSE;
        self.comboSearchResultsDic = comboDic;
    }
    else {
        self.hasSearched = FALSE;
        self.loadOther = FALSE;
        self.comboSearchResultsDic = nil;
        MBProgressHUD* alert = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        alert.labelText = @"No artists found";
        alert.mode = MBProgressHUDModeText;
        alert.removeFromSuperViewOnHide = YES;
        [alert hide:YES afterDelay:2.0]; //TODO use #define for delay
        alert.labelFont = [UIFont heroFontWithSize:18.0f];
        alert.color = [UIColor redHUDConfirmationColor];
    }
    [self.tableView reloadData];
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
