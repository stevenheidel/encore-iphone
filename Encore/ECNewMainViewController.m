//
//  ECNewMainViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECNewMainViewController.h"
#import "ECJSONFetcher.h"

#import "ECConcertCellView.h"
#import "ECSearchResultCell.h"
#import "NSDictionary+ConcertList.h"
#import "UIImageView+AFNetworking.h"

#import "ECConcertDetailViewController.h"

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
    [[UINavigationBar appearance] setBackgroundColor:[UIColor blackColor]];
    
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
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

#pragma mark - Buttons
-(void)profileTapped {
    if (self.profileViewController == nil) {
        self.profileViewController = [[ECProfileViewController alloc] init];
//        self.profileViewController.arrPastConcerts = [self.concerts objectForKey:@"past"];
    }
    
    [self.navigationController pushViewController:self.profileViewController animated:YES];
    [Flurry logEvent:@"Profile_Button_Pressed"];
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
                return cell;
            }
            else {
                UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
                cell.textLabel.text = [[self.otherArtists objectAtIndex:indexPath.row] objectForKey:@"name"];
                return cell;
            }
        }
    }
    else {
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier forIndexPath:indexPath];
        NSArray* concerts = [self currentEventArray];
        NSDictionary * concertDic = [concerts objectAtIndex:indexPath.row];
//        UIImage *image = [self.arrTodaysImages objectAtIndex:indexPath.row];
        [cell setUpCellForConcert:concertDic];
//        [cell setUpCellImageForConcert:image];
        
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
    return SEARCH_CELL_HEIGHT;
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
        
    }
    [textField resignFirstResponder];
    return YES;
}

- (void)fetchedConcertsForSearch:(NSDictionary *)comboDic {
    if (comboDic) {
        self.hasSearched = TRUE;
        self.loadOther = FALSE;
        self.comboSearchResultsDic = comboDic;
        [self.tableView reloadData];
    }
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
