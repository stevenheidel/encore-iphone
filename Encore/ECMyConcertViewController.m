//
//  ECMyConcertViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-11.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECMyConcertViewController.h"
#import "NSDictionary+ConcertList.h"
#import "ECConcertDetailViewController.h"

@interface ECMyConcertViewController ()

@end

@implementation ECMyConcertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.title = @"My Concerts";
    [self.navigationController setNavigationBarHidden:NO];
    self.tableView.tableFooterView = [UIView new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self concertList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    NSDictionary * concertDic = [self.concertList objectAtIndex:indexPath.row];
    if (!concertDic) {
        return nil;
    }
    cell.textLabel.text = [concertDic artistName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", [concertDic venueName] ,[concertDic niceDate]];
//    if ([concertDic beforeToday]) {
//        cell.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:1.0 blue:1.0 alpha:1.0];
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//    }
//    else cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
    
    concertDetail.concert = [self.concertList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:concertDetail animated:YES];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStyleBordered
                                target:nil
                                action:nil];
    self.navigationItem.backBarButtonItem = btnBack;
    
}

#pragma mark - json fetcher delegate
-(void) fetchedConcerts: (NSDictionary *) concerts {
    NSArray * newArray = [concerts past];
    self.concertList =  [newArray arrayByAddingObjectsFromArray:[concerts future]];
    [self.tableView reloadData];
}


@end
