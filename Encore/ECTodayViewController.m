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
#import "ECConcertCellView.h"
#import "MBProgressHUD.h"
#import "UIImage+GaussBlur.h"
#import "NSMutableDictionary+ConcertImages.h"
#import "ECJSONFetcher.h"

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
    UIView * headerSpace = [[UIView alloc] initWithFrame: CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 3.0)]; //Added so shadow of horizontal bar doesn't overlap with view. Remove/change once designs in
    self.tableView.tableHeaderView = headerSpace;
    self.tableView.tableFooterView = [UIView new];
    NSString *myIdentifier = @"ECConcertCellView";
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
                  forCellReuseIdentifier:myIdentifier];
    
    self.arrTodaysImages = [[NSMutableArray alloc] init];
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor colorWithRed:8.0/255.0 green:56.0/255.0 blue:76.0/255.0 alpha:0.90];
    self.hud.labelFont = [UIFont fontWithName:@"Hero" size:self.hud.labelFont.pointSize];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.arrTodaysConcerts == nil) {
        [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday completion:^(NSArray *concerts) {
            [self fetchedPopularConcerts:concerts];
        }];
        [self.hud show:YES];
    }
}

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrTodaysConcerts = concerts;
    
    for (NSDictionary *concertDic in concerts) {
        NSURL *imageURL = [concertDic imageURL];
        NSURL *backgroundURL = [concertDic backgroundURL];
        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        UIImage *gaussImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:backgroundURL]] imageWithGaussianBlur];
        
        NSMutableDictionary *imageDic = [[NSMutableDictionary alloc] init];
        [imageDic addImages:regImage :gaussImage];
        [self.arrTodaysImages addObject:imageDic];
    }
    [self.tableView reloadData];
    [self.hud hide:YES];
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"ECConcertCellView";
    
    ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    NSMutableDictionary *imageDic = [self.arrTodaysImages objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    [cell setUpCellImagesForConcert:imageDic];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CONCERT_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrTodaysConcerts.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
    
    concertDetail.concert = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:concertDetail animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
