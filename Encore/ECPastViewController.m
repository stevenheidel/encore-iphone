//
//  ECPastViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECPastViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIimageView+AFNetworking.h"
#import "NSDictionary+ConcertList.h"
#import "UIImage+GaussBlur.h"
#import "UIImage+Merge.h"
#import "UIFont+Encore.h"

#import <FacebookSDK/FacebookSDK.h>
#import "ATAppRatingFlow.h"

#import "ECAppDelegate.h"
#import "EncoreURL.h"
#import "ECAlertTags.h"
#import "UIColor+EncoreUI.h"

#import "ECJSONFetcher.h"
#import "NSUserDefaults+Encore.h"
#import "ECRowCells.h"
#import "ECGridViewController.h"
typedef enum {
    Photos,
    Lineup,
    Details,
    NumberOfRows
} ECPastRow;

@implementation ECPastViewController

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
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    UIBarButtonItem* shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = shareButton;
    
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
        case Details:
            return 146.0f;
        case Lineup:
            return 142.0f;
        case Photos:
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
        case Details:
            return @"details";
        case Lineup:
            return @"lineup";
        case Photos:
            return @"photos";
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
    NSString* identifier = [ECPastViewController identifierForRow:indexPath.row];
    
    switch (indexPath.row) {
        case Details: {
            DetailsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[DetailsCell alloc] init];
            }
            [cell.detailsLabel setFont:[UIFont lightHeroFontWithSize:12]];
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

//            UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:cell action:@selector(openBigMap)];
//            tapRecognizer.numberOfTapsRequired = 1;
//            tapRecognizer.numberOfTouchesRequired = 1;
//            [cell.mapView addGestureRecognizer:tapRecognizer];
//            cell.addressLabel.text = [NSString stringWithFormat:@"%@\n%@",[self.concert venueName],[self.concert address]];
//            cell.startTimeLabel.text = [self.concert startTime];
//            
//            cell.locationLabel.font = [UIFont lightHeroFontWithSize:12];
//            //            cell.phoneLabel.font = [UIFont lightHeroFontWithSize:12];
//            cell.addressLabel.font = [UIFont lightHeroFontWithSize:12];
//            
//            CLLocation* location = [self.concert coordinates];
//            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
//            cell.location2D = coord2D;
//            cell.venueName = self.concert.venueName;
//            
//            cell.startTimeLabel.text = self.concert.startTime;
            
//            MapViewAnnotation* annotation = [[MapViewAnnotation alloc] initWithTitle:[self.concert venueName] andCoordinate:coord2D];
//            [cell.mapView setCenterCoordinate:coord2D];
//            [cell.mapView addAnnotation:annotation];
//            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord2D, 9000, 9000);
//            [cell.mapView setRegion:region animated:YES];
//            [cell.mapView regionThatFits:region];
//            
//            cell.mapView.layer.borderColor = [UIColor blackColor].CGColor;
//            cell.mapView.layer.borderWidth = 1;
            
            //            [cell.mapView selectAnnotation:annotation animated:YES];
            
            return cell;
        }
        case Lineup: {
            LineupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[LineupCell alloc] init];
            }
            cell.lineupLabel.font = [UIFont lightHeroFontWithSize:12];
            cell.lineup = self.concert.lineup;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

            
            return cell;
        }
        case Photos: {
            GetPhotosCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[GetPhotosCell alloc] init];
                
            }
            
            cell.grabPhotosButton.titleLabel.font = [UIFont heroFontWithSize:20];
            cell.grabPhotosButton.layer.cornerRadius = 5.0;
            cell.grabPhotosButton.layer.masksToBounds = YES;
            cell.contentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

            return cell;
        }
        default:
            return nil;
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PastViewControllerToGridViewController"]) {
        ECGridViewController* vc = [segue destinationViewController];
        vc.concert = self.concert;
    }
}
#pragma mark FB Sharing
-(void) shareTapped {
    if([ApplicationDelegate isLoggedIn]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ECLoginCompletedNotification object:nil];
        [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
        [Flurry logEvent:@"Share_Tapped_Concert"];
        [self share];
    }
    else {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Login", nil) message:NSLocalizedString(@"To share this concert, you must first login", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Login", nil), nil];
        alert.tag = ECShareNotLoggedInAlert;
        [alert show];
    }
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

#pragma mark AlertView delegate

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == ECNotLoggedInAlert) {
        
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
        }
        
        [Flurry logEvent:@"Login_Alert_Selection" withParameters:[NSDictionary dictionaryWithObjectsAndKeys: @"Detail_View", @"Current_View", buttonIndex == alertView.firstOtherButtonIndex ? @"Login":@"Cancel",@"Selection", nil]];
        return; //don't process other alerts
    }else if (alertView.tag == ECShareNotLoggedInAlert)
    {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            [ApplicationDelegate beginFacebookAuthorization];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shareTapped) name:ECLoginCompletedNotification object:nil];
            
        }
    }
    
}

@end
