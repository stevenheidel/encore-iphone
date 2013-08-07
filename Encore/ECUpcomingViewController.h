//
//  ECUpcomingViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSearchType.h"
#import <MapKit/MapKit.h>


@interface ECUpcomingViewController : UITableViewController


@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueAndDate;

@property (nonatomic, assign) ECSearchType tense;
@property (nonatomic,strong) NSDictionary * concert;
@end

@interface GrabTicketsCell : UITableViewCell
@property (strong,nonatomic) NSURL* lastfmURL;
@property (weak, nonatomic) IBOutlet UIButton* grabTicketsButton;
-(IBAction) grabTickets;

@end

@interface LineupCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray* lineupImages;
@property (weak, nonatomic) IBOutlet UILabel *lineupLabel;
@property (weak,nonatomic) IBOutlet UICollectionView* lineupCollectionView;
@property (nonatomic,strong) NSArray* lineup;
@end

@interface LineupCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak,nonatomic) IBOutlet UIImageView* artistImage;
@property (weak,nonatomic) IBOutlet UILabel* artistLabel;

@end

@interface LocationCell : UITableViewCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (assign,nonatomic) CLLocationCoordinate2D location2D;
@property (copy,nonatomic) NSString* venueName;
@property (weak,nonatomic) IBOutlet UILabel* addressLabel;
@property (weak,nonatomic) IBOutlet UILabel* phoneLabel;
@property (weak,nonatomic) IBOutlet MKMapView* mapView;
-(IBAction)openBigMap;
@end