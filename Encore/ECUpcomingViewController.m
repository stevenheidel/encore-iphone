//
//  ECUpcomingViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECUpcomingViewController.h"

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

#import "UIimageView+AFNetworking.h"
#import "NSDictionary+ConcertList.h"
#import "UIImage+GaussBlur.h"
#import "UIImage+Merge.h"
#import "UIFont+Encore.h"

#import <FacebookSDK/FacebookSDK.h>
#import "ATAppRatingFlow.h"
#import <MBProgressHUD.h>

#import "ECAppDelegate.h"
#import "EncoreURL.h"
#import "ECAlertTags.h"
#import "UIColor+EncoreUI.h"

#import "ECJSONFetcher.h"
#import "NSUserDefaults+Encore.h"
#import "ECRowCells.h"
#define HUD_DELAY 1.0

typedef enum {
    Tickets,
    Lineup,
    Details,
    Location,
    NumberOfRows
} ECUpcomingRow;


@interface MapViewAnnotation : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;
@end

@implementation MapViewAnnotation

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	if (self = [super init]) {
        self.title = ttl;
        self.coordinate = c2d;
    }
	return self;
}
@end

@interface ECUpcomingViewController ()<ECEventProfileStatusManagerDelegate>

@end

@implementation ECUpcomingViewController

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
    // Do any additional setup after loading the view from its nib.''
    self.eventName.text = [[self.concert eventName] uppercaseString];
    self.eventVenueAndDate.text = [self.concert venueAndDate];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = encoreLogo;
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self setAppearance];
}
-(void) viewWillAppear:(BOOL)animated {
    if(!self.statusManager) {
        self.statusManager = [[ECEventProfileStatusManager alloc] init];
    }
    self.statusManager.eventID = self.concert.eventID;
    [self.statusManager setDelegate:self];
    [self.statusManager checkProfileState];
}
-(void) setAppearance {
    //Background
    [self.eventImage setImageWithURLRequest:[NSURLRequest requestWithURL:self.concert.imageURL]
                           placeholderImage:nil
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.eventImage.image = image;
        UIImage* backgroundImage = [UIImage mergeImage:[image imageWithGaussianBlur]
                                             withImage:[UIImage imageNamed:@"fullgradient"]];
                                        
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [tempImageView setFrame:self.tableView.frame];
        tempImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.tableView.backgroundView = tempImageView;

                                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                        
        self.eventImage.image = [UIImage imageNamed:@"placeholder.jpg"];
        UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"Black"] imageWithGaussianBlur] ];
        [tempImageView setFrame:self.tableView.frame];
         self.tableView.backgroundView = tempImageView;

    }];
    
    //Event image
    self.eventImage.layer.cornerRadius = 5.0;
    self.eventImage.layer.masksToBounds = YES;
    self.eventImage.layer.borderColor = [UIColor grayColor].CGColor;
    self.eventImage.layer.borderWidth = 0.1;
    
    //Fonts
    [self.eventName setFont:[UIFont heroFontWithSize:16]];
    [self.eventVenueAndDate setFont:[UIFont heroFontWithSize:12]];

    //Navigation bar
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
//    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *rightButImage = [UIImage imageNamed:@"shareButton"];
//    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
//    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
//    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
//    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    self.navigationItem.rightBarButtonItem = shareButton;    

    self.tableView.separatorColor = [UIColor separatorColor];
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case Location:
            return 198.0f;
        case Lineup:
            return 142.0f;
        case Details:
            return 60.0f;
        case Tickets:
            return 60.0f;
        default:
            return 0.0f;
    }
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return NumberOfRows;
}

+(NSString*) identifierForRow: (NSUInteger) row {
    switch (row) {
        case Location:
            return @"location";
        case Lineup:
            return @"lineup";
        case Details:
            return @"details";
        case Tickets:
            return @"tickets";
        default:
            return nil;
    }
}

// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
	MKAnnotationView *annotationView = [views objectAtIndex:0];
	id <MKAnnotation> mp = [annotationView annotation];
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate], 1500, 1500);
	[mv setRegion:region animated:YES];
	[mv selectAnnotation:mp animated:YES];
    NSLog(@"This went");
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* identifier = [ECUpcomingViewController identifierForRow:indexPath.row];
    
    switch (indexPath.row) {
        case Location: {
            LocationCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[LocationCell alloc] init];
            }
            UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(openBigMap)];
            tapRecognizer.numberOfTapsRequired = 1;
            tapRecognizer.numberOfTouchesRequired = 1;
            [cell.mapView addGestureRecognizer:tapRecognizer];
            cell.addressLabel.text = [NSString stringWithFormat:@"%@",[self.concert address]];
            cell.startTimeLabel.text = [self.concert startTime];
            
            cell.locationLabel.font = [UIFont lightHeroFontWithSize:16];
//            cell.addressLabel.font = [UIFont lightHeroFontWithSize:16];

            CLLocation* location = [self.concert coordinates];
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            cell.location2D = coord2D;
            cell.venueName = self.concert.venueName;
            
          //  cell.startTimeLabel.text = self.concert.startTime;
            
            MapViewAnnotation* annotation = [[MapViewAnnotation alloc] initWithTitle:[self.concert venueName] andCoordinate:coord2D];
            [cell.mapView setCenterCoordinate:coord2D];
            [cell.mapView addAnnotation:annotation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord2D, 1000, 1000);
            [cell.mapView setRegion:region animated:YES];
            [cell.mapView regionThatFits:region];
            
            cell.mapView.layer.borderColor = [UIColor blackColor].CGColor;
            cell.mapView.layer.borderWidth = 1;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
//            [cell.mapView selectAnnotation:annotation animated:YES];
            
            return cell;
        }
        case Lineup: {
            LineupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[LineupCell alloc] init];
            }
            cell.lineupLabel.font = [UIFont lightHeroFontWithSize:16];
            cell.lineup = self.concert.lineup;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            cell.navController = self.navigationController;
            
            return cell;
        }
        case Details: {
            DetailsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[DetailsCell alloc] init];
            }
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            cell.changeStateButton.titleLabel.font = [UIFont heroFontWithSize:20];
            cell.changeStateButton.layer.cornerRadius = 5.0;
            cell.changeStateButton.layer.masksToBounds = YES;
            [cell.changeStateButton addTarget:self action:@selector(addToProfile) forControlEvents:UIControlEventTouchUpInside];
            self.iamgoingButton = cell.changeStateButton;
            [self.iamgoingButton setButtonIsOnProfile:self.statusManager.isOnProfile];
            
            return cell;
        }
        case Tickets: {
            GrabTicketsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[GrabTicketsCell alloc] init];

            }
            cell.lastfmURL = [self.concert lastfmURL];
            cell.grabTicketsButton.titleLabel.font = [UIFont heroFontWithSize:20];
            cell.grabTicketsButton.layer.cornerRadius = 5.0;
            cell.grabTicketsButton.layer.masksToBounds = YES;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
            [cell.shareButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        default:
            return nil;
    }
}

#pragma mark FB Sharing
-(void) shareTapped {
    NSString* eventName = [self.concert eventName];
    NSString* the = @"the ";
    NSString* substring = [[eventName substringToIndex:3]lowercaseString];
    if ([substring isEqualToString:@"the"]) {
        the = @"";
    }
    NSString* shareText = [NSString stringWithFormat: @"Encore: Who wants to come to %@%@ show at %@, %@?",the,[self.concert eventName],[self.concert venueName],[self.concert niceDate]];
    NSURL* url = [self.concert lastfmURL];
    NSArray *activityItems = [NSArray arrayWithObjects:shareText,url, self.eventImage.image, nil];
    
    UIActivityViewController* shareDrawer = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    shareDrawer.excludedActivityTypes = @[UIActivityTypePostToWeibo,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypePrint];
    
    //TODO: do something with this completion handler, ie. analytics.
    shareDrawer.completionHandler = ^(NSString *activityType, BOOL completed){
        if (completed) {
            NSLog(@"Selected activity was performed.");
        } else {
            if (activityType == NULL) {
                NSLog(@"User dismissed the view controller without making a selection.");
            } else {
                NSLog(@"Activity was not performed.");
            }
        }
    };
    [self presentViewController:shareDrawer animated:YES completion:nil];
    //    if([ApplicationDelegate isLoggedIn]) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
//        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
//        [Flurry logEvent:@"Share_Tapped_Concert" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"upcomingvc",@"source", self.concert.eventID,@"eventID", self.concert.eventName, @"eventName", nil]];
//        [self share];
//    }
//    else {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To share this concert, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
//        alert.tag = ECShareNotLoggedInAlert;
//        [alert show];
//    }
}

-(void) share {
    [self shareWithTaggedFriends:nil];
}

-(void) shareWithTaggedFriends: (NSArray*) taggedFriends {
    NSLog(@"Sharing with Facebook from Concert detail view controller");
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
    
    FBShareDialogParams* params = [[FBShareDialogParams alloc] init];
    params.link = url;
    if(taggedFriends)
        [params setFriends:[taggedFriends valueForKey:@"id"]];
    
    //    params.description =  [NSString stringWithFormat:@"Check out photos and videos from %@'s %@ show in %@ at the %@ on Encore.",[self.concert artistName], [self.concert niceDate], [self.concert city], [self.concert venueName]];
    if ([FBDialogs canPresentShareDialogWithParams:params]) {
        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
            if(error) {
                NSLog(@"Error sharing concert: %@", error.description);
                [Flurry logEvent:@"Concert_Share_To_FB_Fail" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", error.description, @"error", nil]];
            } else {
                NSLog(@"Success sharing concert!");
                [Flurry logEvent:@"Concert_Share_To_FB_Success" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", nil]];
            }
            
        }];
    }
    else {
        NSMutableDictionary *params2 =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%@ on Encore",[self.concert eventName]], @"name",
         [NSString stringWithFormat:@"Check out photos and videos from %@'s %@ show on Encore.",[self.concert eventName], [self.concert niceDate]], @"caption",
         @"Encore is a free iPhone concert app that collects photos and videos from live shows and helps you keep track of upcoming shows in your area.",@"description",
         [NSString stringWithFormat:ShareConcertURL,self.concert.eventID], @"link",
         [NSString stringWithFormat:@"%@",[self.concert imageURL].absoluteString], @"picture",
         nil];
        [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                               parameters:params2
                                                  handler:
         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
             if (error) {
                 // Error launching the dialog or publishing a story.
                 NSLog(@"Error publishing story.");
             } else {
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // User clicked the "x" icon
                     NSLog(@"User canceled story publishing.");
                 } else {
                     // Handle the publish feed callback
                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                     if (![urlParams valueForKey:@"post_id"]) {
                         // User clicked the Cancel button
                         NSLog(@"User canceled story publishing.");
                     } else {
                         // User clicked the Share button
                         NSString *msg = @"Posted to facebook";
                         NSLog(@"%@", msg);
                         [Flurry logEvent:@"Successfully_Posted_To_Facebook_With_Feed_Dialog" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Concert",@"type", nil]];
                         // Show the result in an alert
                         [[[UIAlertView alloc] initWithTitle:@"Result"  //TODO: replace with HUD
                                                     message:msg
                                                    delegate:nil
                                           cancelButtonTitle:@"OK!"
                                           otherButtonTitles:nil]
                          show];
                     }
                 }
             }
         }];
    }
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}


#pragma mark Autorotation
-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
        }
        
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Past_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
        return; //don't process other alerts
    }
    else if (alertView.tag == ECShareNotLoggedInAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareTapped) name:ECLoginCompletedNotification object:nil];
            
        }
    }else if (alertView.tag == ECChangeStateNotLoggedInAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self.statusManager selector:@selector(checkProfileState) name:ECLoginCompletedNotification object:nil];

        }
    }
    
}

#pragma mark - Adding/Removing Concerts

-(void) addToProfile{
    if (ApplicationDelegate.isLoggedIn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.statusManager name:ECLoginCompletedNotification object:nil];
        
        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
        [self.statusManager toggleProfileState];
    }else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To Add this concert to your profile, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECChangeStateNotLoggedInAlert;
        [alert show];
    }
}

-(void) profileState:(BOOL)isOnProfile {
    [self.iamgoingButton setButtonIsOnProfile:isOnProfile];
}

-(void)successChangingState:(BOOL)isOnProfile
{
    [self.iamgoingButton setButtonIsOnProfile:isOnProfile];
    [self concertStateChangedHUD];
    
    if([self.eventStateDelegate respondsToSelector:@selector(profileUpdated)])
        [self.eventStateDelegate profileUpdated];
    
    [Flurry logEvent:@"Completed_Adding_Concert" withParameters:[self flurryParam]];
    
    
}
-(void) failedToChangeState: (BOOL) isOnProfile;
{
    [self alertError];
    [self.iamgoingButton setButtonIsOnProfile:isOnProfile];
    [Flurry logEvent:@"Failed_Adding_Concert" withParameters:[self flurryParam]];
    
}

-(NSString*) userID {
    return [NSUserDefaults userID];
}

-(void) alertError {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Sorry, an error occured and your request was not processed.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


-(NSDictionary*) flurryParam {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.concert.eventID,@"eventID",self.concert.eventName,@"eventName", nil];
}
-(void) concertStateChangedHUD{
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
    HUD.mode = MBProgressHUDModeCustomView;
    
    if(self.statusManager.isOnProfile){
        HUD.labelText = NSLocalizedString(@"concert_added",nil);
        HUD.color = [UIColor lightBlueHUDConfirmationColor];
    }else{
        HUD.labelText = NSLocalizedString(@"concert_removed", nil);
        HUD.color = [UIColor redHUDConfirmationColor];
    }
    
    [HUD show:YES];
    [HUD hide:YES afterDelay:HUD_DELAY];
    
}




@end

