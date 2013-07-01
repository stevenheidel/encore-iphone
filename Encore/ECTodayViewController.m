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

#import "UIColor+EncoreUI.h"
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
//    UIView * headerSpace = [[UIView alloc] initWithFrame: CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 3.0)]; //Added so shadow of horizontal bar doesn't overlap with view. Remove/change once designs in
    
    //self.tableView.tableHeaderView = [self headerView];
    self.tableView.tableFooterView = [self headerView];
    NSString *myIdentifier = @"ECConcertCellView";
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
                  forCellReuseIdentifier:myIdentifier];
    
    self.arrTodaysImages = [[NSMutableArray alloc] init];
    
    //Progress HUD to indicate loading of images
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.userInteractionEnabled = YES;
    
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"loading", nil);
    self.hud.color = [UIColor encoreDarkGreenColorWithAlpha:0.90];
    self.hud.labelFont = [UIFont fontWithName:@"Hero" size:self.hud.labelFont.pointSize];
    [self.tableView setScrollsToTop:YES];
}

- (UIView *) headerView {
    UIImage *headerImage = [UIImage imageNamed:@"songkick"];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerImage.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerImage.size.width, headerImage.size.height)];
    imageView.center = headerView.center;
    imageView.image = headerImage;
    headerView.backgroundColor = [UIColor lightGrayHeaderColor];
    [headerView addSubview:imageView];
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.arrTodaysConcerts == nil) {
        [ECJSONFetcher fetchPopularConcertsWithSearchType:ECSearchTypeToday completion:^(NSArray *concerts) {
            [self fetchedPopularConcerts:concerts];
        }];
        [self.hud show:YES];
    }
    [Flurry logEvent:@"TodayVC_Appeared"];
}

-(void) fetchedPopularConcerts:(NSArray *)concerts {
    self.arrTodaysConcerts = concerts;
    
    for (NSDictionary *concertDic in concerts) {
        NSURL *imageURL = [concertDic imageURL];
        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        if (regImage) {
            [self.arrTodaysImages addObject:regImage];
        } else {
            [self.arrTodaysImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
        }
    }
    [self.tableView reloadData];
    [self.hud hide:YES];
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"ECConcertCellView";
    
    ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    UIImage *image = [self.arrTodaysImages objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    [cell setUpCellImageForConcert:image];
    if ([indexPath row] % 2) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.contentView.backgroundColor = [UIColor lightGrayTableColor];
    }
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIImage *headerImage = [UIImage imageNamed:@"songkicktest"];
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, headerImage.size.height)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, headerImage.size.width, headerImage.size.height)];
//    imageView.image = headerImage;
//    headerView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0];
//    [headerView addSubview:imageView];
//    return headerView;
//                            
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return [UIImage imageNamed:@"songkicktest"].size.height;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CONCERT_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrTodaysConcerts.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
    NSDictionary* concert = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    concertDetail.concert = concert;
    
    [Flurry logEvent:@"Selected_Popular_Today_Concert" withParameters:concert];
    
    [self.navigationController pushViewController:concertDetail animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
