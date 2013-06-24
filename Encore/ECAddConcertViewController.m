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
    
    self.lblLocation.font = [UIFont fontWithName:@"Hero" size:15.0];
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
    //Get rid of the border in the searchbar textfield
    UITextField* searchField = nil;
    for(int i = 0; i < self.searchBar.subviews.count; i++) {
        if([[self.searchBar.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
            searchField = [self.searchBar.subviews objectAtIndex:i];
        }
    }
    if(searchField) {
        searchField.borderStyle = UITextBorderStyleNone;
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
    [self.tableView reloadData];
    //[self.activityIndicator stopAnimating];
    [self.hud hide: YES];
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

-(void) clearSearchResultsTable {
    self.arrArtistData = nil;
    hasSearched = FALSE;
    [self.tableView reloadData];
}
#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self clearSearchResultsTable];
    [self.JSONFetcher fetchArtistsForString:[searchBar text]];
    [searchBar resignFirstResponder];
    //[searchBar setShowsCancelButton:NO animated:YES];
    //[self.activityIndicator startAnimating];
	
	[self.hud show: YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    //[searchBar setShowsCancelButton:NO animated:YES];
    searchBar.text = @"";
    [self clearSearchResultsTable];
}

-(void)searchBar:(UISearchBar *) searchBar textDidChange: (NSString*) searchText {
//can automatically send a search each time a character is typed / group of characters
    
    if ([searchText length] == 0) { //if user clicks clear button, clear the table
        [self clearSearchResultsTable];
    }
}

-(void)searchBarTextDidEndEditing:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //[searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - Did Receive Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
