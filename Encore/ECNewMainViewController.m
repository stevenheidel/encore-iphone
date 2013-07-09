//
//  ECNewMainViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECNewMainViewController.h"
#import "ECJSONFetcher.h"
#import "ECSearchType.h"
#import "ECConcertCellView.h"
#import "ECSearchResultCell.h"
#import "NSDictionary+ConcertList.h"

#define searchCellIdentifier @"ECSearchResultCell"
#define concertCellIdentifier @"ECConcertCellView"


@interface ECNewMainViewController ()

@end

@implementation ECNewMainViewController

#pragma mark - View loading
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hasSearched = FALSE;
    [self.tableView registerNib:[UINib nibWithNibName:@"ECSearchResultCell" bundle:nil]
         forCellReuseIdentifier:searchCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:concertCellIdentifier];
    
    [self setupBarButtons];
    [self setNavBarAppearance];
    
    if (self.arrTodaysConcerts == nil) {
        [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday completion:^(NSArray *concerts) {
            [self fetchedPopularConcerts:concerts];
        }];
        //        [self.hud show:YES];
    }
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
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    self.shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.shareButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.shareButton;
}

-(void) setNavBarAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navbar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
}

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrTodaysConcerts = concerts;
    NSLog(@"%@: %@", NSStringFromClass([self class]), self.arrTodaysConcerts.description);
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

- (void)fetchedConcertsForSearch:(NSDictionary *)comboDic {
    if (comboDic) {
        self.hasSearched = TRUE;
        self.searchedArtistDic = [comboDic objectForKey:@"artist"];
        self.arrSearchConcerts = [comboDic objectForKey:@"concerts"];
        self.arrAltArtists = [comboDic objectForKey:@"others"];
        [self.tableView reloadData];
    }
}

-(void) getArtistImages {
    for (NSDictionary *concertDic in self.arrTodaysConcerts) {
        NSURL *imageURL = [concertDic imageURL];
        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        if (regImage) {
            [self.arrTodaysImages addObject:regImage];
        } else {
            [self.arrTodaysImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
        }
    }
}

#pragma mark - Buttons
-(void)profileTapped {
    if (self.profileViewController == nil) {
        self.profileViewController = [[ECProfileViewController alloc] init];
//        self.profileViewController.arrPastConcerts = [self.concerts objectForKey:@"past"];
    }
    
    [self.navigationController pushViewController:self.profileViewController animated:YES];
    [Flurry logEvent:@"Profile_Button_Pressed"];
}


-(IBAction) switchedSelection: (id) sender {
    
    UISegmentedControl* control = (UISegmentedControl*)sender;
    
    NSLog(@"thanks for switching me! %d",control.selectedSegmentIndex);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.hasSearched) {
        return [self.arrSearchConcerts count];
    } else {
        return [self.arrTodaysConcerts count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasSearched) {
        ECSearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier forIndexPath:indexPath];
        NSDictionary * concertDic = [self.arrSearchConcerts objectAtIndex:indexPath.row];
        [cell setUpCellForConcert:concertDic];
        return cell;
    } else {
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:concertCellIdentifier forIndexPath:indexPath];
        NSDictionary * concertDic = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
        UIImage *image = [self.arrTodaysImages objectAtIndex:indexPath.row];
        [cell setUpCellForConcert:concertDic];
        [cell setUpCellImageForConcert:image];
        return cell;
    }
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SEARCH_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.hasSearched = FALSE;
    [self.tableView reloadData];
    return YES;
}

#pragma mark - Text Field delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField.text length] > 0) {
        [ECJSONFetcher fetchArtistsForString:textField.text withSearchType:self.segmentedControl.selectedSegmentIndex forLocation:@"Toronto" completion:^(NSDictionary * comboDic) {
            NSLog(@"%@: %@", NSStringFromClass([self class]), comboDic);
            [self fetchedConcertsForSearch:comboDic];
        }];
    }
    [textField resignFirstResponder];
    return YES;
}
@end
