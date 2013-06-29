//
//  ECProfileViewController.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileViewController.h"
#import "ECProfileHeader.h"
#import "ECConcertCellView.h"
#import "ECConcertDetailViewController.h"
#import "NSDictionary+ConcertList.h"
#import <QuartzCore/QuartzCore.h>

#define HEADER_HEIGHT 200.0

@interface ECProfileViewController ()

@end

@implementation ECProfileViewController

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
    [self setUpBackButton];
    // Do any additional setup after loading the view from its nib.
    NSString *myIdentifier = @"ECConcertCellView";
    self.tableView.tableFooterView = [self footerView];
    self.tableView.tableHeaderView = [[ECProfileHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, HEADER_HEIGHT) andOwner:self];
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:myIdentifier];
    [self setUpHeaderView];
    self.arrPastImages = [[NSMutableArray alloc] init];
    [self getArtistImages];
    
}
- (void) setUpBackButton {
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width*0.75, leftButImage.size.height*0.75);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (UIView *) footerView {
    
    UIImage *footerImage = [UIImage imageNamed:@"songkick"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, footerImage.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, footerImage.size.width, footerImage.size.height)];
    imageView.center = footerView.center;
    imageView.image = footerImage;
    footerView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0];
    [footerView addSubview:imageView];
    return footerView;
    
}

- (void) setUpHeaderView {
    
    self.lblName.font = [UIFont fontWithName:@"Hero" size:18.0];
    self.lblLocation.font = [UIFont fontWithName:@"Hero" size:14.0];
    self.lblConcerts.font = [UIFont fontWithName:@"Hero" size:14.0];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userIDKey = NSLocalizedString(@"user_id", nil);
    NSString* userID = [defaults stringForKey:userIDKey];
    self.imgProfile.profileID = userID;
    self.imgProfile.layer.cornerRadius = 30.0;
    self.imgProfile.layer.masksToBounds = YES;
    self.imgProfile.layer.borderWidth = 1.0;
    self.imgProfile.layer.borderColor = [UIColor colorWithRed:160.0/255.0 green:165.0/255.0 blue:170.0/255.0 alpha:1.0].CGColor;
    
    NSString* userNameKey = NSLocalizedString(@"user_name", nil);
    NSString* userName = [defaults stringForKey:userNameKey];
    self.lblName.text = userName;
    
    NSString* userLocationKey = NSLocalizedString(@"user_location", nil);
    NSString* userLocation = [defaults stringForKey:userLocationKey];
    NSLog(@"userLocation:%@", userLocation);
    self.lblLocation.text = @"Toronto, ON";//userLocation;
    
    self.lblConcerts.text = [NSString stringWithFormat:@"%d Concerts", [self.arrPastConcerts count]];
}

-(void) getArtistImages {
    for (NSDictionary *concertDic in self.arrPastConcerts) {
        NSURL *imageURL = [concertDic imageURL];
        UIImage *regImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        if (regImage) {
            [self.arrPastImages addObject:regImage];
        } else {
            [self.arrPastImages addObject:[UIImage imageNamed:@"placeholder.jpg"]];
        }
    }
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *myIdentifier = @"ECConcertCellView";
    
    ECConcertCellView *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    NSDictionary * concertDic = [self.arrPastConcerts objectAtIndex:indexPath.row];
    UIImage *image = [self.arrPastImages objectAtIndex:indexPath.row];
    [cell setUpCellForConcert:concertDic];
    [cell setUpCellImageForConcert:image];
    if ([indexPath row] % 2) {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CONCERT_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrPastConcerts.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] init];
    NSDictionary* concert = [self.arrPastConcerts objectAtIndex:indexPath.row];
    concertDetail.concert = concert;
    
    //[Flurry logEvent:@"Selected_Popular_Today_Concert" withParameters:concert];
    
    [self.navigationController pushViewController:concertDetail animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


