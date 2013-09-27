//
//  ECArtistViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECArtistViewController.h"
#import "ECJSONFetcher.h"
#import <QuartzCore/QuartzCore.h>
#import "UIFont+Encore.h"
#import "UIColor+EncoreUI.h"
#import "MBProgressHUD.h"
#import "ECUpcomingViewController.h"
#import "ECPastViewController.h"

typedef enum {
    ArtistInfoPastSection,
    ArtistInfoUpcomingSection,
    ArtistInfoNumSections
}ArtistInfoSections;
@interface ECArtistViewController ()

@end

@implementation ECArtistViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;


    MBProgressHUD* hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
	[self.tableView addSubview:hud];
    hud.color = [UIColor lightBlueHUDConfirmationColor];
	[hud show:YES];
    hud.labelText = [NSString stringWithFormat:@"Loading recent events"];
    [ECJSONFetcher fetchInfoForArtist:self.artist completion:^(NSDictionary *artistInfo) {
        self.events = [artistInfo objectForKey:@"events"];
        [self.tableView reloadData];
        [hud hide:YES];
    }];
    if (self.artistImage != (id)[NSNull null]) {
        self.artistImageView.image = self.artistImage;
        self.artistImageView.layer.cornerRadius = 5.0;
        self.artistImageView.layer.masksToBounds = YES;
        self.artistImageView.layer.borderColor = [UIColor grayColor].CGColor;
        self.artistImageView.layer.borderWidth = 0.1;
    }
        self.artistNameLabel.text = [self.artist uppercaseString];
    self.artistNameLabel.font = [UIFont heroFontWithSize:16.f];
    self.artistNameLabel.textColor = [UIColor blueArtistTextColor];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    if (section == ArtistInfoPastSection) {
        UIStoryboard* pastBoard = [UIStoryboard storyboardWithName:@"ECPastStoryboard" bundle:nil];
        ECPastViewController* pastVC =  (ECPastViewController*)[pastBoard instantiateInitialViewController];
        pastVC.concert = [self.pastEvents objectAtIndex:indexPath.row];
        pastVC.tense = ECSearchTypePast;
        pastVC.previousArtist = self.artist;
        [self.navigationController pushViewController:pastVC animated:YES];
    }
    else if (section == ArtistInfoUpcomingSection){
        UIStoryboard* upcomingBoard = [UIStoryboard storyboardWithName:@"ECUpcomingStoryboard" bundle:nil];
        ECUpcomingViewController* upcomingVC = (ECUpcomingViewController*) [upcomingBoard instantiateInitialViewController];
        upcomingVC.concert = [self.upcomingEvents objectAtIndex:indexPath.row];
        upcomingVC.tense = ECSearchTypeFuture;
        upcomingVC.previousArtist = self.artist;
        [self.navigationController pushViewController:upcomingVC animated:YES];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return ArtistInfoNumSections;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == ArtistInfoPastSection) {
        return [self.pastEvents count];
    }
    else if (section == ArtistInfoUpcomingSection) {
        return [self.upcomingEvents count];
    }
    return 0;
}

-(NSArray*) pastEvents {
    return [self.events objectForKey:@"past"];
}
-(NSArray*) upcomingEvents {
    return [self.events objectForKey:@"upcoming"];
}

-(NSArray*) arrayForSection:(NSInteger) section {
    switch (section) {
        case ArtistInfoUpcomingSection:
            return self.upcomingEvents;
        case ArtistInfoPastSection:
            return self.pastEvents;
        default:
            return nil;
    }
}

-(NSString*) titleForSection: (NSInteger) section {
    switch (section) {
        case ArtistInfoPastSection:
            return @"PAST";
        case ArtistInfoUpcomingSection:
            return @"UPCOMING";
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self tableView: tableView numberOfRowsInSection:section]==0){
        return 0;
    }
    return 16.0;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if([[self arrayForSection:section] count]==0){
        return nil;//[UIView new];
    }
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECProfileSectionHeaderView" owner:nil options:nil];
    UIView* headerView = [subviewArray objectAtIndex:0];
    UILabel* label = (UILabel*)[headerView viewWithTag:87];
    [label setFont:[UIFont heroFontWithSize:14.0f]];
    [label setText:[self titleForSection:section]];
    
    return headerView;
}
-(NSDictionary*) eventForIndexPath: (NSIndexPath*) indexPath {
    NSUInteger section = indexPath.section;
    if (section == ArtistInfoPastSection) {
        return [[self.events objectForKey:@"past"] objectAtIndex:indexPath.row];
    }
    else if (section == ArtistInfoUpcomingSection) {
        return [[self.events objectForKey:@"upcoming"] objectAtIndex:indexPath.row];
    }
    return nil;
}
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"eventcell"];
    NSDictionary* event = [self eventForIndexPath: indexPath];
    NSDateFormatter* formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSDate* date = [formatter dateFromString:[event objectForKey: @"date"]];
    
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.dateFormat = nil;
    cell.detailTextLabel.text = [formatter stringFromDate:date];
    NSString* city = [[event objectForKey:@"venue"] objectForKey:@"city"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@",[event objectForKey:@"venue_name"], city];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    return cell;
}
@end
