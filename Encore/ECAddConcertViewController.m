//
//  ECAddConcertViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECAddConcertViewController.h"
#import "ECConcertDetailViewController.h"

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


#pragma mark - ECJSONFetcherDelegate Methods

-(void)fetchedArtists:(NSArray *)artists {
    self.arrData = artists;
    [self.tableView reloadData];
}

- (void)fetchedArtistConcerts:(NSArray *)concerts {
    self.arrData = concerts;
    [self.tableView reloadData];
}

#pragma mark - UITableView methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier];
                             
    if (cell == nil)
    {
        //TODO: initilize cells from nib files, once we have the designs
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
            case ECSelectConcert: {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ConcertCellIdentifier];
                NSDictionary *ConcertDic = (NSDictionary *)[self.arrData objectAtIndex:indexPath.row];
                cell.textLabel.text = [ConcertDic objectForKey:@"name"];
                break;
            }
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
    switch (selectionStage) {
        case ECSelectArtist: {
            selectionStage = ECSelectConcert;
            NSString *artistId = [(NSDictionary *)[self.arrData objectAtIndex:[indexPath row]] objectForKey:@"server_id"];
            [self.JSONFetcher fetchConcertsForArtistId:artistId];
            break;
        }
        case ECSelectConcert: {
            ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
            concertDetail.concert = [self.arrData objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:concertDetail animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.JSONFetcher fetchArtistsForString:[searchBar text]];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
