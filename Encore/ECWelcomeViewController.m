//
//  ECWelcomeViewController.m
//  Encore
//
//  Created by Mohamed Fouad on 9/17/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECWelcomeViewController.h"
#import "UIFont+Encore.h"
#define ConcertCellIdentifier @"ECConcertCellView"
#import "ECConcertCellView.h"
#import "ECGridViewController.h"
#import "NSDictionary+ConcertList.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UIColor+EncoreUI.h"
@interface ECWelcomeViewController ()
{
    UIView* lastFMView;
}
@property (strong,nonatomic) NSArray* featuredEvents;
@property (assign) BOOL tappedOnConcert;
@end

@implementation ECWelcomeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setApperance];
    [self readFeaturedEvents];
    [self setupLastFMView];
    self.tappedOnConcert = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationController.navigationBar.barTintColor = [UIColor blueArtistTextColor];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (self.tappedOnConcert) {
        [self.btnNext setEnabled:YES];
    }
}
- (void)setApperance
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    NSInteger size = 15;
    UIFont* font = [UIFont heroFontWithSize:size];
    [self.lblPickConcert setFont:font];
    [self.lblWelcomeTo setFont:font];
}

-(void)readFeaturedEvents
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"featured" ofType:@"json"];
    NSDictionary *featuredEventsDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:filePath] options:0 error:Nil];
    self.featuredEvents = [[NSArray alloc] initWithArray:featuredEventsDictionary[@"events"]];
    [self.featuredTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
-(void) setupLastFMView {
    lastFMView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.featuredTableView.frame.size.width,113.0f)];
    UIButton* lastFMBUtton = [[UIButton alloc] initWithFrame:CGRectMake(100.0f, 6.0f, 98.0f, 13.0f)];
    [lastFMBUtton addTarget:self action:@selector(openLastFM:) forControlEvents:UIControlEventTouchUpInside];
    [lastFMBUtton setBackgroundImage:[UIImage imageNamed:@"lastfmAttr"] forState:UIControlStateNormal];
    [lastFMBUtton setContentMode:UIViewContentModeScaleAspectFit];
    [lastFMView addSubview: lastFMBUtton];
    self.featuredTableView.tableFooterView = lastFMView;
}
- (IBAction)openLastFM:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://www.last.fm"]];
}

#pragma mark - Table view data source
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.featuredEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:ConcertCellIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [self.featuredEvents objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    cell.lblLocation.text = [[concertDic address] uppercaseString];
    [cell.imageArtist setImageWithURL:[concertDic imageURL] placeholderImage:nil]; //TODO add placeholder
    cell.lblName.textColor = [UIColor darkGrayColor];

    return cell;
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.tappedOnConcert = YES;

    NSDictionary* concert = [self.featuredEvents objectAtIndex:indexPath.row];
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
    ECGridViewController * vc = [sb instantiateViewControllerWithIdentifier:@"ECGridViewController"];
    vc.concert = concert;
    vc.hideShareButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    [Flurry logEvent:@"Walkthrough_Concert_Tap" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:concert.headliner,@"Headliner",nil]];
}

- (IBAction)nextButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
