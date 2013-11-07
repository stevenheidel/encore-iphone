//
//  SPGooglePlacesAutocompleteViewController.h
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import <MapKit/MapKit.h>

@class SPGooglePlacesAutocompleteQuery;

@protocol SPGooglePlacesAutocompleteViewControllerDelegate <NSObject>

-(void) updatedSearchLocationToPlacemark: (CLPlacemark*) placemark;

@end

@interface SPGooglePlacesAutocompleteViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UISearchBarDelegate, MKMapViewDelegate> {
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    MKPointAnnotation *selectedPlaceAnnotation;
    
    BOOL shouldBeginEditing;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic,unsafe_unretained) id <SPGooglePlacesAutocompleteViewControllerDelegate> delegate;
@property (nonatomic,strong) CLLocation* initialLocation;


@end

