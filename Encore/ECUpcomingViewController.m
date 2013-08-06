//
//  ECUpcomingViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECUpcomingViewController.h"
#import "UIimageView+AFNetworking.h"
#import "NSDictionary+ConcertList.h"
#import <MapKit/MapKit.h>
typedef enum {
    Tickets,
    Lineup,
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

@implementation LocationCell
-(IBAction) openBigMap {
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.location2D addressDictionary:nil];
    MKMapItem* mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:self.venueName];
    [mapItem openInMapsWithLaunchOptions:nil];
}
@end

@implementation LineupCell
-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //    NSInteger itemNumber = indexPath.row;
    //    NSDictionary* artist = [self.lineup objectAtIndex:itemNumber];
    
    __weak LineupCollectionCell *cell = (LineupCollectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"LineupCell" forIndexPath:indexPath];
    //    [cell.artistImage setImageWithURL:[artist imageURL] placeholderImage:nil];
    cell.artistLabel.text = @"TEST";//[artist objectForKey:@"name"];
    return cell;
}
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.lineup.count;
}
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
@end

@implementation LineupCollectionCell

@end

@implementation GrabTicketsCell

-(IBAction) grabTickets {
    NSLog(@"Grab_Tickets!");
}
@end


@interface ECUpcomingViewController ()

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
    [self.eventImage setImageWithURL:self.concert.imageURL placeholderImage:nil];
    self.eventName.text = [self.concert eventName];
    self.eventVenueAndDate.text = [self.concert venueAndDate];
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case Location:
            return 143.0f;
        case Lineup:
            return 122.0f;
        case Tickets:
            return 55.0f;
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
        case Tickets:
            return @"tickets";
        default:
            return nil;
    }
}

+(UITableViewCell*) initCellForRow: (NSUInteger) row {
    switch (row) {
        case Location:
            return [[LocationCell alloc] init];
        case Lineup:
            return [[LineupCell alloc] init];
        case Tickets:
            return [[GrabTicketsCell alloc] init];
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
            cell.addressLabel.text = @"address";
            cell.phoneLabel.text = @"phone";
            
            CLLocation* location = [self.concert coordinates];
            CLLocationCoordinate2D coord2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            cell.location2D = coord2D;
            cell.venueName = self.concert.venueName;
            
            MapViewAnnotation* annotation = [[MapViewAnnotation alloc] initWithTitle:[self.concert venueName] andCoordinate:coord2D];
            [cell.mapView setCenterCoordinate:coord2D];
            [cell.mapView addAnnotation:annotation];
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord2D, 9000, 9000);
            [cell.mapView setRegion:region animated:YES];
            [cell.mapView regionThatFits:region];
//            [cell.mapView selectAnnotation:annotation animated:YES];
            
            
            return cell;
        }
        case Lineup: {
            LineupCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[LineupCell alloc] init];

            }
            cell.lineup = nil; //TODO: set this to something
            
            return cell;
        }
        case Tickets: {
            GrabTicketsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[GrabTicketsCell alloc] init];
            }
//            cell.ticketURL = nil;
            return cell;
        }
        default:
            return nil;
    }
}

@end

