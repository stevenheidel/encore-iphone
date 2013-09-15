//
//  ECRowCells.h
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ECChangeConcertStateButton.h"

@interface GetPhotosCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton* grabPhotosButton;
@property (weak,nonatomic) IBOutlet UIButton* shareButton;
@end

@interface GrabTicketsCell : UITableViewCell
@property (strong,nonatomic) NSURL* lastfmURL;
@property (weak, nonatomic) IBOutlet UIButton* grabTicketsButton;
@property (weak,nonatomic) IBOutlet UIButton* shareButton;
-(IBAction) grabTickets;

@end

@interface LineupCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray* lineupImages;
@property (weak, nonatomic) IBOutlet UILabel *lineupLabel;
@property (weak,nonatomic) IBOutlet UICollectionView* lineupCollectionView;
@property (nonatomic,strong) NSArray* lineup;
@property (nonatomic,weak) UINavigationController* navController;
@property (nonatomic, strong) NSString* previousArtist; // if you got to the current page from a previous page, will jus pop
@end

@interface LineupCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak,nonatomic) IBOutlet UIImageView* artistImage;
@property (weak,nonatomic) IBOutlet UILabel* artistLabel;

@end

@interface DetailsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ECChangeConcertStateButton *changeStateButton;
@end

@interface LocationCell : UITableViewCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (assign,nonatomic) CLLocationCoordinate2D location2D;
@property (copy,nonatomic) NSString* venueName;
@property (weak,nonatomic) IBOutlet UILabel* addressLabel;
@property (weak,nonatomic) IBOutlet UILabel* phoneLabel;
@property (weak,nonatomic) IBOutlet MKMapView* mapView;
-(IBAction)openBigMap;
@end