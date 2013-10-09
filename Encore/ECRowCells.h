//
//  ECRowCells.h
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "ECChangeConcertStateButton.h"
#define ROW_TITLE_SIZE 16.0f

@interface GetPhotosCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton* grabPhotosButton;
@property (weak,nonatomic) IBOutlet UIButton* shareButton;
@end

@interface GrabTicketsCell : UITableViewCell
@property (strong,nonatomic) NSURL* ticketsURL;
@property (weak, nonatomic) IBOutlet UIButton* grabTicketsButton;
@property (weak,nonatomic) IBOutlet UIButton* shareButton;

@end

@interface LineupCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray* lineupImages;
@property (weak, nonatomic) IBOutlet UILabel *lineupLabel;
@property (weak,nonatomic) IBOutlet UICollectionView* lineupCollectionView;
@property (nonatomic,strong) NSArray* lineup;
@property (nonatomic,weak) UINavigationController* navController; //needs reference to nav controller to push view controller on click
@property (nonatomic, strong) NSString* previousArtist; // if you got to the current page from a previous page, will just pop
@end

@interface LineupCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak,nonatomic) IBOutlet UIImageView* artistImage;
@property (weak,nonatomic) IBOutlet UILabel* artistLabel;

@end

@interface DetailsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet ECChangeConcertStateButton *changeStateButton;
@end

@interface SongPreviewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblMusicTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) IBOutlet UIButton *btnItunes;
@property (weak, nonatomic) IBOutlet UILabel *lblSongName;
@end

@interface LocationCell : UITableViewCell <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (assign,nonatomic) CLLocationCoordinate2D location2D;
@property (copy,nonatomic) NSString* venueName;
@property (weak,nonatomic) IBOutlet UILabel* addressLabel;
@property (weak,nonatomic) IBOutlet UILabel* phoneLabel;
@property (weak,nonatomic) IBOutlet MKMapView* mapView;
-(IBAction)openBigMap;
@end

@interface FriendsCell: UITableViewCell  <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray* friendImages;
@property (weak,nonatomic) IBOutlet UILabel *friendsTitleLabel;
@property (weak,nonatomic) IBOutlet UILabel *noFriendsLabel;
@property (weak,nonatomic) IBOutlet UICollectionView* friendsCollectionView;
@property (nonatomic,strong) IBOutlet UIButton* addFriendsButton;
@property (nonatomic,strong) NSArray* friends;
@end

@interface FriendCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak,nonatomic) IBOutlet UIImageView* friendImage;
@property (weak,nonatomic) IBOutlet UILabel* friendNameLabel;
@end