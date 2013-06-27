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
#import "NSDictionary+ConcertList.h"
#import "MBProgressHUD.h"
#import "ECConcertCellView.h"
#import "UIImage+GaussBlur.h"
#import "NSMutableDictionary+ConcertImages.h"
#import "UIImageView+AFNetworking.h"
#import "ECJSONFetcher.h"

#define ARTIST_HEADER_HEIGHT 30.0
#define ARTIST_CELL_HEIGHT 50.0

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
    
    hasSearched = FALSE;
    self.lastSelectedArtist = nil;
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor colorWithRed:8.0/255.0 green:56.0/255.0 blue:76.0/255.0 alpha:0.90];
    self.hud.labelFont = [UIFont fontWithName:@"Hero" size:self.hud.labelFont.pointSize];
    self.hud.detailsLabelFont = [UIFont fontWithName:@"Hero" size:self.hud.detailsLabelFont.pointSize];
    //Register cell nib file to the uitableview
    NSString *myIdentifier = @"ECConcertCellView";
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:myIdentifier];
    
    self.arrArtistImages = [[NSMutableArray alloc] init];
    self.arrPopularImages = [[NSMutableArray alloc] init];
    self.locationSearch.font = [UIFont fontWithName:@"Hero" size:15.0];
    self.artistSearch.font = [UIFont fontWithName:@"Hero" size:15.0];
    self.lblNoresults.font = [UIFont fontWithName:@"Hero" size:22.0];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [self headerView];
}

- (UIView *) headerView {
    UIImage *headerImage = [UIImage imageNamed:@"songkicktest"];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerImage.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerImage.size.width, headerImage.size.height)];
    imageView.image = headerImage;
    headerView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0];
    [headerView addSubview:imageView];
    return headerView;
}

-(void)viewWillAppear:(BOOL)animated {
    void (^fetchedBlock)(NSArray*) = ^(NSArray* concerts){
        [self fetchedPopularConcerts:concerts];
    };
    if (!hasSearched && self.arrPopularData == nil) {
        if (self.searchType == ECSearchTypePast) {
            [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypePast completion:fetchedBlock];
        } else {
            [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeFuture completion:fetchedBlock];
        }
        [self.hud show:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.hud hide:NO];
}

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    
    if (concerts.count) {
        self.arrPopularData = concerts;
        [self.arrPopularImages removeAllObjects];
        for (NSDictionary *concertDic in concerts) {
            NSURL *imageURL = [concertDic imageURL];
            UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
 
            if (regImage) {
                [self.arrPopularImages addObject:regImage];
            } else {
                [self.arrPopularImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
            }
        }
        [self.tableView reloadData];
        [self hideNoResults];
        [self.hud hide:YES];
    } else {
        self.lblNoresults.text = [NSString stringWithFormat:NSLocalizedString(@"NoPopularResults", nil), self.searchType ? NSLocalizedString(@"Upcoming", nil) : NSLocalizedString(@"Past", nil)];
        [self showNoResults];
        [self.hud hide:YES];
    }
}

- (void)fetchedArtistConcerts:(NSArray *)concerts {
    hasSearched = TRUE;
    if (concerts.count) {
        self.foundArtistConcerts = TRUE;
        self.arrArtistConcerts = concerts;
        for (NSDictionary *concertDic in concerts) {
            NSURL *imageURL = [concertDic imageURL];
            UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
            if (regImage) {
                [self.arrArtistImages addObject:regImage];
            } else {
                [self.arrArtistImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
            }
        }
    } else {
        self.foundArtistConcerts = FALSE;
    }
    [self hideNoResults];
    [self.tableView reloadData];
    [self.hud hide:YES];
}

#pragma mark - UITableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (hasSearched) {
        if (self.foundArtistConcerts) {
            static NSString *myIdentifier = @"ECConcertCellView";
            ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
            NSDictionary *concertDic = [self.arrArtistConcerts objectAtIndex:indexPath.row];
            UIImage *image = [self.arrArtistImages objectAtIndex:indexPath.row];
            [(ECConcertCellView *)cell setUpCellForConcert:concertDic];
            [(ECConcertCellView *)cell setUpCellImageForConcert:image];
            cell.contentView.backgroundColor = [self getCellColourForRow:[indexPath row]];
            return cell;
        } else {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ArtistCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ArtistCellIdentifier];
            }
            NSDictionary *artistDic = (NSDictionary *)[self.arrArtistData objectAtIndex:indexPath.row];
            cell.textLabel.text = [artistDic artistName];
            cell.textLabel.textColor = [UIColor colorWithRed:28.0/255.0 green:29.0/255.0 blue:31.0/255.0 alpha:0.8];
            //cell.contentView.backgroundColor = [self getCellColourForRow:[indexPath row]];
            cell.backgroundView.backgroundColor = [self getCellColourForRow:[indexPath row]];
            return cell;
        }
    } else {
        static NSString *myIdentifier = @"ECConcertCellView";
        
        ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
        NSDictionary * concertDic = [self.arrPopularData objectAtIndex:indexPath.row];
        UIImage *image = [self.arrPopularImages objectAtIndex:indexPath.row];
        [(ECConcertCellView *)cell setUpCellForConcert:concertDic];
        [(ECConcertCellView *)cell setUpCellImageForConcert:image];
        cell.contentView.backgroundColor = [self getCellColourForRow:[indexPath row]];
        return cell;
    }
}

- (UIColor *)getCellColourForRow:(int)row {
    if (row % 2) {
        return [UIColor whiteColor];
    } else {
        return [UIColor colorWithRed:246.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (hasSearched) {
        if (self.foundArtistConcerts) {
            return CONCERT_CELL_HEIGHT;
        } else {
            return ARTIST_CELL_HEIGHT;
        }
    } else {
        return CONCERT_CELL_HEIGHT;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (hasSearched) {
        NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle == nil) {
            return nil;
        }
        
        // Create label with section title
        UILabel *label = [[UILabel alloc] init] ;
        label.frame = CGRectMake(0, 0, self.view.frame.size.width, ARTIST_HEADER_HEIGHT);
        label.backgroundColor = [self getCellColourForRow:1];
        label.textColor = [UIColor colorWithRed:28.0/255.0 green:29.0/255.0 blue:31.0/255.0 alpha:0.8];
        [label setAdjustsFontSizeToFitWidth:YES];
        label.font = [UIFont fontWithName:@"Hero" size:16.0];
        label.text = sectionTitle;
        
        // Create header view and add label as a subview
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, ARTIST_HEADER_HEIGHT)];
        [headerView addSubview:label];
        return headerView;
    } else {
//        UIImage *headerImage = [UIImage imageNamed:@"songkick"];
//        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerImage.size.height)];
//        headerView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0];
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerImage.size.width, headerImage.size.height)];
//        imageView.image = headerImage;
//        [headerView addSubview:imageView];
//        return headerView;
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (hasSearched) {
        return ARTIST_HEADER_HEIGHT;
    } else {
        return 0;//[UIImage imageNamed:@"songkick"].size.height;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (hasSearched) {
        if (self.foundArtistConcerts) {
            return [NSString stringWithFormat:NSLocalizedString(@"Header", nil), self.searchType ? NSLocalizedString(@"Upcoming", nil) : NSLocalizedString(@"Past", nil), [self.lastSelectedArtist artistName], @"Toronto, ON"]; //TODO: set location dynamically
        } else {
            return NSLocalizedString(@"NoConcertResults", nil);
        }
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (hasSearched) {
        if (self.foundArtistConcerts) {
            return self.arrArtistConcerts.count;
        } else {
            return self.arrArtistData.count;
        }
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
            if (self.foundArtistConcerts) {
                ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
                
                concertDetail.concert = [self.arrArtistConcerts objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:concertDetail animated:YES];
            } else {
                NSDictionary* artistDic = (NSDictionary*)[self.arrArtistData objectAtIndex:indexPath.row];
                NSNumber *artistID = [artistDic songkickID];
                void (^fetchedConcertsBlock)(NSArray*) = ^(NSArray* concerts){
                    [self fetchedArtistConcerts:concerts];
                };
                if (self.searchType == ECSearchTypePast) {
                    [ECJSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypePast completion:fetchedConcertsBlock];
                } else {
                    [ECJSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypeFuture completion:fetchedConcertsBlock];
                }
                self.lastSelectedArtist = artistDic;
                [self.hud show:YES];
            }  
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

-(void) showNoResults {
    self.tableView.hidden = YES;
    self.lblNoresults.hidden = NO;
}

-(void) hideNoResults {
    self.tableView.hidden = NO;
    self.lblNoresults.hidden = YES;
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
        if (textField.text.length > 0) {
            [ECJSONFetcher fetchArtistsForString:[textField text] completion:^(NSArray *artists) {
                [self fetchedArtists:artists];
            }];
            [self dismissKeyboard:nil];
            self.hud.labelText = NSLocalizedString(@"Searching", nil);
            self.hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"hudSearchArtist", nil), [textField text]];
            [self.hud show:YES];
        } else {
            [textField resignFirstResponder];
        }
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)fetchedArtists:(NSArray *)artists {
    
    if (artists.count) {
        self.arrArtistData = artists;
        hasSearched = TRUE;
        NSDictionary * matchedArtistDic = nil;
        /* This kickass piece of code will find if an artist was returned with the exact name that was searched for and if not use the first artist returned
         for (NSDictionary *artistDic in artists) {
         if ([[artistDic artistName] isEqualToString:self.artistSearch.text]) {
         matchedArtistDic = artistDic;
         break;
         }
         }
         if (!matchedArtistDic) {
         matchedArtistDic = [artists objectAtIndex:0];
         }
         */
        //NSLog(@"%@",artists);
        matchedArtistDic = [artists objectAtIndex:0]; //If using kickass piece of code above, please remove this line
        NSNumber *artistID = [matchedArtistDic songkickID];
        void (^fetchedConcertsBlock)(NSArray*) = ^(NSArray* concerts){
            [self fetchedArtistConcerts:concerts];
        };
        if (self.searchType == ECSearchTypePast) {
            [ECJSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypePast completion:fetchedConcertsBlock];
        } else {
            [ECJSONFetcher fetchConcertsForArtistID:artistID withSearchType:ECSearchTypeFuture completion:fetchedConcertsBlock];
        }
        
        self.hud.labelText = NSLocalizedString(@"Searching", nil);
        
        //self.hud.minSize = CGSizeMake(260.f, 260.f);
        self.hud.detailsLabelText = [NSString stringWithFormat:NSLocalizedString(@"hudSearchConcert", nil), self.searchType ? NSLocalizedString(@"Upcoming", nil) : NSLocalizedString(@"Past", nil), [matchedArtistDic artistName]];

        self.lastSelectedArtist = matchedArtistDic;
        
        //    [self.tableView reloadData];
        //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        //    [self.hud hide: YES];
    } else {
        self.lblNoresults.text = [NSString stringWithFormat:NSLocalizedString(@"NoArtistResults", nil), self.artistSearch.text];
        [self showNoResults];
        [self.hud hide:YES];
    }
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
