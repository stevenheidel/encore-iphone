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
#import <QuartzCore/QuartzCore.h>
#import "ECConcertCellView.h"
#import "UIImage+GaussBlur.h"
#import "NSMutableDictionary+ConcertImages.h"

@interface ECMyConcertViewController ()

@end

@implementation ECMyConcertViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.tableView.tableFooterView = [UIView new];
    
    NSString *myIdentifier = @"ECConcertCellView";
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:myIdentifier];
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self concertList] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *myIdentifier = @"ECConcertCellView";
    
    ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [self.concertList objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    
    return cell;

//    if ([concertDic beforeToday]) {
//        cell.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:1.0 blue:1.0 alpha:1.0];
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
//    }
//    else cell.contentView.backgroundColor = [UIColor clearColor];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CONCERT_CELL_HEIGHT;
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
