//
//  ECTodayViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-17.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECTodayViewController.h"
#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"

static NSString *const ConcertCellIdentifier = @"concertCell";

@interface ECTodayViewController ()

@end

@implementation ECTodayViewController

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
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.arrTodaysConcerts == nil) {
        ECJSONFetcher *JSONFetcher = [[ECJSONFetcher alloc] init];
        JSONFetcher.delegate = self;
        [JSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday];
    }
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ConcertCellIdentifier];
    }
    NSDictionary * concertDic = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    cell.textLabel.text = [concertDic artistName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [concertDic venueName]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrTodaysConcerts.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
    
    concertDetail.concert = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:concertDetail animated:YES];
}

#pragma mark - ECJSONFetcher methods
-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrTodaysConcerts = concerts;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
