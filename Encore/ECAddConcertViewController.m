//
//  ECAddConcertViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECAddConcertViewController.h"
#import "ECConcertDetailViewController.h"
#import "ECMyConcertViewController.h"
#import "NSDictionary+ConcertList.h"
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
}

-(void)viewWillAppear:(BOOL)animated {
    if (!hasSearched && self.arrPopularData == nil) {
        if (self.searchType == ECSearchTypePast) {
            [self.JSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypePast];
        } else {
            [self.JSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeFuture];
        }
        [self.activityIndicator startAnimating];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.activityIndicator stopAnimating];
}

#pragma mark - ECJSONFetcherDelegate Methods

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrPopularData = concerts;
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
}

-(void)fetchedArtists:(NSArray *)artists {
    self.arrArtistData = artists;
    hasSearched = TRUE;
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
}

- (void)fetchedArtistConcerts:(NSArray *)concerts {
    
    ECMyConcertViewController *concertsVC = [ECMyConcertViewController new];
    concertsVC.concertList = concerts;
    concertsVC.title = self.lastSelectedArtist;
    [self.activityIndicator stopAnimating];
    [self.navigationController pushViewController:concertsVC animated:YES];
}

#pragma mark - UITableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;

    //TODO: initilize cells from nib file, once we have the designs
    if (hasSearched) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:ArtistCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ArtistCellIdentifier];
        }
        NSDictionary *artistDic = (NSDictionary *)[self.arrArtistData objectAtIndex:indexPath.row];
        cell.textLabel.text = [artistDic artistName];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ConcertCellIdentifier];
        }
        NSDictionary * concertDic = [self.arrPopularData objectAtIndex:indexPath.row];
        cell.textLabel.text = [concertDic artistName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [concertDic venueName] ,[concertDic niceDate]];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!hasSearched) {
        if (self.searchType == ECSearchTypePast) {
            return [NSString stringWithFormat:NSLocalizedString(@"PopularConcerts", nil), NSLocalizedString(@"Past", nil)];
        } else {
            return [NSString stringWithFormat:NSLocalizedString(@"PopularConcerts", nil), NSLocalizedString(@"Upcoming", nil)];
        }
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"ArtistSearch", nil), [self.searchBar text]];
    }
}

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
        [self.activityIndicator startAnimating];
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
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.activityIndicator startAnimating];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
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
    [searchBar setShowsCancelButton:YES animated:YES];
}

#pragma mark - Did Receive Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
