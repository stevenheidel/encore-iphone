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
    
    NSString *myIdentifier = @"ECConcertCellView";
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
                  forCellReuseIdentifier:myIdentifier];
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
    static NSString *myIdentifier = @"ECConcertCellView";
    
    ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [self.arrTodaysConcerts objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    
    cell.imageBackground.image = [UIImage imageNamed:@"Default.png"];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [concertDic venueName]];
    
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

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return NSLocalizedString(@"TodayTableTitle",nil);
    return nil;
}*/

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
