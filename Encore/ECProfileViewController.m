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
#import <FacebookSDK/FacebookSDK.h>

#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "TestFlight.h"
//#import "UIBarButtonItem+FlatUI.h"
#import "MBProgressHUD.h"

#define HEADER_HEIGHT 170.0
#define FLAG_HUD_DELAY 2.0

typedef enum {
    LogoutTag
}ECProfileAlertTags;

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
    [self setupLogoutButton];
    NSString *myIdentifier = @"ECConcertCellView";
    self.tableView.tableFooterView = [UIView new];
   // self.tableView.tableFooterView = [self footerView];
    
    ECProfileHeader * header = [[ECProfileHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, HEADER_HEIGHT) andOwner:self];
    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, HEADER_HEIGHT)];
    [myView addSubview:header];
    self.tableView.tableHeaderView = myView;
    [self.tableView registerNib:[UINib nibWithNibName:@"ECConcertCellView" bundle:nil]
         forCellReuseIdentifier:myIdentifier];
    [self setUpHeaderView];
    self.arrPastImages = [[NSMutableArray alloc] init];
    [self getArtistImages];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupTestflightFeedback];
}
- (void) setUpBackButton {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width*0.75, leftButImage.size.height*0.75);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;

//    [UIBarButtonItem configureFlatButtonsWithColor:[UIColor peterRiverColor]
//                                  highlightedColor:[UIColor belizeHoleColor]
//                                      cornerRadius:3
//                                   whenContainedIn:[UINavigationBar class]];
    
}

-(void) setupLogoutButton {
    UIButton* logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamed:@"logout.png"];
    [logoutButton setBackgroundImage:image forState:UIControlStateNormal];
    [logoutButton addTarget:self action:@selector(logoutTapped) forControlEvents:UIControlEventTouchUpInside];
    logoutButton.frame = CGRectMake(0,0,image.size.width*0.75, image.size.height*0.75);

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
}
- (UIView *) footerView {
    
    UIImage *footerImage = [UIImage imageNamed:@"songkick"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, footerImage.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, footerImage.size.width, footerImage.size.height)];
    imageView.center = footerView.center;
    imageView.image = footerImage;
    footerView.backgroundColor = [UIColor lightGrayHeaderColor];
    [footerView addSubview:imageView];
    return footerView;
    
}

- (void) setUpHeaderView {
    
    self.lblName.font = [UIFont heroFontWithSize: 18.0];
    self.lblLocation.font = [UIFont heroFontWithSize: 14.0];
    self.lblConcerts.font = [UIFont heroFontWithSize: 14.0];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* userIDKey = NSLocalizedString(@"user_id", nil);
    NSString* userID = [defaults stringForKey:userIDKey];
    self.imgProfile.profileID = userID;
    self.imgProfile.layer.cornerRadius = 30.0;
    self.imgProfile.layer.masksToBounds = YES;
    self.imgProfile.layer.borderWidth = 1.0;
    self.imgProfile.layer.borderColor = [UIColor profileImageBorderColor].CGColor;
    
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
        cell.contentView.backgroundColor = [UIColor lightGrayTableColor];
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
    
    NSDictionary* concert = [self.arrPastConcerts objectAtIndex:indexPath.row];
    ECConcertDetailViewController * concertDetail = [[ECConcertDetailViewController alloc] initWithConcert:concert];
    
    //[Flurry logEvent:@"Selected_Popular_Today_Concert" withParameters:concert];
    
    [self.navigationController pushViewController:concertDetail animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Logout
-(void) logoutTapped {
    FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_alert_title",nil) message:NSLocalizedString(@"logout_alert_message", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"logout", nil), nil];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
    alertView.messageLabel.textColor = [UIColor cloudsColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:14];
    alertView.backgroundOverlay.backgroundColor = [[UIColor cloudsColor] colorWithAlphaComponent:0.8];
    alertView.alertContainer.backgroundColor = [UIColor midnightBlueColor];
    alertView.defaultButtonColor = [UIColor cloudsColor];
    alertView.defaultButtonShadowColor = [UIColor asbestosColor];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor asbestosColor];
    alertView.tag = LogoutTag;
    [alertView show];
    
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"logout_alert_title", nil) message:NSLocalizedString(@"logout_alert_message",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"logout", nil), nil];
//    alert.tag = LogoutTag;
//    [alert show];
    [Flurry logEvent:@"Logout_Tapped_Profile"];
}

-(void) alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == LogoutTag && buttonIndex == 0) {
        [self logout];
    }
    else {
        [Flurry logEvent:@"Canceled_Logout"];
    }
}

-(void) logout {
    [Flurry logEvent: @"Logged_out_facebook"];
    [FBSession.activeSession closeAndClearTokenInformation];
}



#pragma mark - TestFlight Feedback solicitation
-(void) setupTestflightFeedback {
    //    UIButton* feedback = [[UIButton alloc] initWithFrame:self.navigationItem.titleView.frame];
    UIButton* feedback = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* image = [UIImage imageNamed:@"feedback.png"];
    [feedback setBackgroundImage:image forState:UIControlStateNormal];
    [feedback addTarget:self action:@selector(openFeedback) forControlEvents:UIControlEventTouchUpInside];
    feedback.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    self.navigationItem.titleView = feedback;
}

-(void) openFeedback {
    ECFeedbackViewController* feedbackVC = [ECFeedbackViewController new];
    feedbackVC.delegate = self;
    [self presentViewController:feedbackVC animated:YES completion:nil];
}

#pragma mark ECFeedbackViewControllerDelegate method
-(void) feedbackSent {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Feedback_Sent", nil);
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = YES;
    [hud hide:YES afterDelay:FLAG_HUD_DELAY];
}


@end


