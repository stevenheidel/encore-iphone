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
    
    selectionStage = ECSelectArtist; //TODO: Change to popular concerts once API is set up

}

- (void)viewWillDisappear:(BOOL)animated {
    [self.activityIndicator stopAnimating];
}

#pragma mark - ECJSONFetcherDelegate Methods

-(void)fetchedArtists:(NSArray *)artists {
    self.arrData = artists;
    [self.tableView reloadData];
}

- (void)fetchedArtistConcerts:(NSArray *)concerts {
    
    ECMyConcertViewController *concertsVC = [ECMyConcertViewController new];
    concertsVC.concertList = concerts;
    concertsVC.title = @"Concerts";
    [self.activityIndicator stopAnimating];
    [self.navigationController pushViewController:concertsVC animated:YES];
}

#pragma mark - UITableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier];
                             
    if (cell == nil)
    {
        //TODO: initilize cells from nib file, once we have the designs
        switch (selectionStage) {
            case ECSelectPopular: {

                break;
            }
            case ECSelectArtist: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ArtistCellIdentifier];
                NSDictionary *artistDic = (NSDictionary *)[self.arrData objectAtIndex:indexPath.row];
                cell.textLabel.text = [artistDic objectForKey:@"name"];
                break;
            }
            /*case ECSelectConcert: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ConcertCellIdentifier];
                NSDictionary *ConcertDic = (NSDictionary *)[self.arrData objectAtIndex:indexPath.row];
                cell.textLabel.text = [ConcertDic objectForKey:@"name"];
                break;
            }*/
            default:
                break;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* data = (NSDictionary*)[self.arrData objectAtIndex:indexPath.row];
    switch (selectionStage) {
        case ECSelectArtist: {
            //selectionStage = ECSelectConcert;  //set up next selection stage
            NSString *artistID = [data serverID];
            [self.JSONFetcher fetchConcertsForArtistID:artistID];
            [self.activityIndicator startAnimating];
            break;
        }
        case ECSelectConcert: {
            ECConcertDetailViewController * concertDetail = [ECConcertDetailViewController new];
            concertDetail.concert = data;
            NSLog(@"%@",[data description]);
            [self.navigationController pushViewController:concertDetail animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void) clearSearchResultsTable {
    self.arrData = nil;
    [self.tableView reloadData];
    selectionStage = ECSelectArtist;
}
#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self clearSearchResultsTable];
    [self.JSONFetcher fetchArtistsForString:[searchBar text]];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    
  //  [self.tableView]
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
