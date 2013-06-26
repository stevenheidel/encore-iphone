//
//  ECAddConcertViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ECAddConcertViewController.h"
#import "ECConcertDetailViewController.h"
#import "ECMyConcertViewController.h"
#import "NSDictionary+ConcertList.h"
#import "MBProgressHUD.h"
#import "ECConcertCellView.h"

#pragma mark - Search bar animation constants

#define SEARCHBAR_REGULAR_WIDTH 130.0
#define SEARCHBAR_EXPANDED_WIDTH 265.0

#define ARTIST_SEARCH_X 25.0
#define ARTIST_SEARCH_HIDDEN_X (-ARTIST_SEARCH_X-SEARCHBAR_REGULAR_WIDTH)
#define SEARCH_ICON_X 5.0
#define SEARCH_ICON_HIDDEN_X 5.0

#define LOCATION_SEARCH_X 185.0
#define LOCATION_SEARCH_HIDDEN_X 320.0
#define LOCATION_SEARCH_EXPANDED_X 50.0
#define LOCATION_ICON_X 167.0
#define LOCATION_ICON_HIDDEN_X 300.0
#define LOCATION_ICON_EXPANDED_X 30.0

#define DIVISOR_MIDDLE 160.0
#define DIVISOR_LEFT 25.0
#define DIVISOR_RIGHT 295.0



static NSString *const ArtistCellIdentifier = @"artistCell";
static NSString *const ConcertCellIdentifier = @"concertCell";

@interface ECAddConcertViewController ()

@end

@implementation ECAddConcertViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.JSONFetcher = [[ECJSONFetcher alloc] init];
    self.JSONFetcher.delegate = self;
    hasSearched = FALSE;
    self.lastSelectedArtist = nil;
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor colorWithRed:8.0/255.0 green:56.0/255.0 blue:76.0/255.0 alpha:0.90];
    //Register cell nib file to the uitableview
    NSString *myIdentifier = @"ECConcertCellView";
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:myIdentifier];
    
    self.locationSearch.font = [UIFont fontWithName:@"Hero" size:15.0];
    self.artistSearch.font = [UIFont fontWithName:@"Hero" size:15.0];
    self.tableView.tableFooterView = [UIView new];
}

-(void)viewWillAppear:(BOOL)animated {
    if (!hasSearched && self.arrPopularData == nil) {
        if (self.searchType == ECSearchTypePast) {
            [self.JSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypePast];
        } else {
            [self.JSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeFuture];
        }
        [self.hud show:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.hud hide:NO];
}

#pragma mark - ECJSONFetcherDelegate Methods

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrPopularData = concerts;
    [self.tableView reloadData];
    [self.hud hide:YES];
}

-(void)fetchedArtists:(NSArray *)artists {
    self.arrArtistData = artists;
    hasSearched = TRUE;
    NSDictionary * matchedArtistDic = nil;
    for (NSDictionary *artistDic in artists) {
        if ([[artistDic artistName] isEqualToString:self.artistSearch.text]) {
            matchedArtistDic = artistDic;
            NSNumber *artistID = [artistDic songkickID];
            if (self.searchType == ECSearchTypePast) {
                [self.JSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypePast];
            } else {
                [self.JSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypeFuture];
            }
            self.lastSelectedArtist = [artistDic artistName];
            break;
        }
    }
    if (!matchedArtistDic) {
        matchedArtistDic = [artists objectAtIndex:0];
        NSNumber *artistID = [matchedArtistDic songkickID];
        if (self.searchType == ECSearchTypePast) {
            [self.JSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypePast];
        } else {
            [self.JSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypeFuture];
        }
        self.lastSelectedArtist = [matchedArtistDic artistName];
    }
    
//    [self.tableView reloadData];
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
//    [self.hud hide: YES];
}

- (void)fetchedArtistConcerts:(NSArray *)concerts {
    
    ECMyConcertViewController *concertsVC = [ECMyConcertViewController new];
    concertsVC.concertList = concerts;
    concertsVC.title = self.lastSelectedArtist;
    [self.hud hide:YES];
    [self.navigationController pushViewController:concertsVC animated:YES];
}

#pragma mark - UITableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (hasSearched) {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ArtistCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ArtistCellIdentifier];
        }
        NSDictionary *artistDic = (NSDictionary *)[self.arrArtistData objectAtIndex:indexPath.row];
        cell.textLabel.text = [artistDic artistName];
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    } else {
        static NSString *myIdentifier = @"ECConcertCellView";
        
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
        NSDictionary * concertDic = [self.arrPopularData objectAtIndex:indexPath.row];
        
        [(ECConcertCellView *)cell setUpCellForConcert:concertDic];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (hasSearched) {
        return 40;
    } else {
        return CONCERT_CELL_HEIGHT;
    }
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!hasSearched) {
        if (self.searchType == ECSearchTypePast) {
            return [NSString stringWithFormat:NSLocalizedString(@"PopularConcerts", nil), NSLocalizedString(@"Past", nil)];
        } else {
            return [NSString stringWithFormat:NSLocalizedString(@"PopularConcerts", nil), NSLocalizedString(@"Upcoming", nil)];
        }
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"ArtistSearch", nil), [self.searchBar text]];
    }
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (hasSearched) {
        return self.arrArtistData.count;
    } else {
        return self.arrPopularData.count;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.artistSearch isFirstResponder] || [self.locationSearch isFirstResponder]) {
        [self.artistSearch resignFirstResponder];
        [self.locationSearch resignFirstResponder];
    } else {
        if (hasSearched) {
            NSDictionary* data = (NSDictionary*)[self.arrArtistData objectAtIndex:indexPath.row];
            NSNumber *artistID = [data songkickID];
            
            if (self.searchType == ECSearchTypePast) {
                [self.JSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypePast];
            } else {
                [self.JSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypeFuture];
            }
            self.lastSelectedArtist = [data artistName];
            [self.hud show:YES];
        } else {
            //User clicked on a popular concert
            ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
            
            concertDetail.concert = [self.arrPopularData objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:concertDetail animated:YES];
        }

    }
}

-(void) clearSearchResultsTable {
    self.arrArtistData = nil;
    hasSearched = FALSE;
    [self.tableView reloadData];
}

-(IBAction)dismissKeyboard:(id)sender {
    if ([self.artistSearch isFirstResponder] || [self.locationSearch isFirstResponder]) {
        [self.artistSearch resignFirstResponder];
        [self.locationSearch resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [self expandArtistSearchBar];
    } else {
        [self expandLocationSearchBar];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == 0) {
        //[self clearSearchResultsTable];
        [self.JSONFetcher fetchArtistsForString:[textField text]];
        [self dismissKeyboard:nil];
        [self.hud show: YES];
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearSearchResultsTable];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField.tag == 0) {
        [self closeArtistSearchBar];
    } else {
        [self closeLocationSearchBar];
        if ([textField.text length] == 0) {
            textField.text = @"Toronto, ON";
        } else {
            //TODO: (low priority)set Location code
        }
    }
    return YES;
}

#pragma mark - Search bar animations

- (void)expandArtistSearchBar {
    
    CGRect artistSearchFrame = self.artistSearch.frame;
    CGRect locationSearchFrame = self.locationSearch.frame;
    CGRect divisorFrame = self.searchDivisor.frame;
    CGRect locationIconFrame = self.btnLocationIcon.frame;
    
    locationSearchFrame.origin.x = LOCATION_SEARCH_HIDDEN_X;
    locationIconFrame.origin.x = LOCATION_ICON_HIDDEN_X;
    divisorFrame.origin.x = DIVISOR_RIGHT;
    artistSearchFrame.size.width = SEARCHBAR_EXPANDED_WIDTH;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.locationSearch.frame = locationSearchFrame;
                         self.btnLocationIcon.frame = locationIconFrame;
                         self.searchDivisor.frame = divisorFrame;
                         self.artistSearch.frame = artistSearchFrame;
                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)expandLocationSearchBar {
    
    CGRect artistSearchFrame = self.artistSearch.frame;
    CGRect locationSearchFrame = self.locationSearch.frame;
    CGRect divisorFrame = self.searchDivisor.frame;
    CGRect locationIconFrame = self.btnLocationIcon.frame;
    CGRect artistIconFrame = self.btnSearchIcon.frame;
    
    
    //shift artist search bar
    artistIconFrame.origin.x = SEARCH_ICON_HIDDEN_X;
    artistSearchFrame.origin.x = ARTIST_SEARCH_HIDDEN_X;
    divisorFrame.origin.x = DIVISOR_LEFT;
    
    //expand Location search bar
    locationIconFrame.origin.x = LOCATION_ICON_EXPANDED_X;
    locationSearchFrame.origin.x = LOCATION_SEARCH_EXPANDED_X;
    locationSearchFrame.size.width = SEARCHBAR_EXPANDED_WIDTH;
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.btnSearchIcon.frame = artistIconFrame;
                         self.artistSearch.frame = artistSearchFrame;
                         self.searchDivisor.frame = divisorFrame;
                         self.btnLocationIcon.frame = locationIconFrame;
                         self.locationSearch.frame = locationSearchFrame;
                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)closeArtistSearchBar {
    CGRect artistSearchFrame = self.artistSearch.frame;
    CGRect locationSearchFrame = self.locationSearch.frame;
    CGRect divisorFrame = self.searchDivisor.frame;
    CGRect locationIconFrame = self.btnLocationIcon.frame;
    
    artistSearchFrame.size.width = SEARCHBAR_REGULAR_WIDTH;
    divisorFrame.origin.x = DIVISOR_MIDDLE;
    locationIconFrame.origin.x = LOCATION_ICON_X;
    locationSearchFrame.origin.x = LOCATION_SEARCH_X;

    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.artistSearch.frame = artistSearchFrame;
                         self.searchDivisor.frame = divisorFrame;
                         self.btnLocationIcon.frame = locationIconFrame;
                         self.locationSearch.frame = locationSearchFrame;
                     }
                     completion:^(BOOL finished){

                     }];
}

- (void)closeLocationSearchBar {
    
    CGRect artistSearchFrame = self.artistSearch.frame;
    CGRect locationSearchFrame = self.locationSearch.frame;
    CGRect divisorFrame = self.searchDivisor.frame;
    CGRect locationIconFrame = self.btnLocationIcon.frame;
    CGRect artistIconFrame = self.btnSearchIcon.frame;
    
    locationSearchFrame.origin.x = LOCATION_SEARCH_X;
    locationSearchFrame.size.width = SEARCHBAR_REGULAR_WIDTH;
    locationIconFrame.origin.x = LOCATION_ICON_X;
    divisorFrame.origin.x = DIVISOR_MIDDLE;
    artistSearchFrame.origin.x = ARTIST_SEARCH_X;
    artistIconFrame.origin.x = SEARCH_ICON_X;
    
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{                         
                         self.locationSearch.frame = locationSearchFrame;
                         self.btnLocationIcon.frame = locationIconFrame;
                         self.searchDivisor.frame = divisorFrame;
                         self.artistSearch.frame = artistSearchFrame;
                         self.btnSearchIcon.frame = artistIconFrame;
                     }
                     completion:^(BOOL finished){

                     }];
}

#pragma mark - Did Receive Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
