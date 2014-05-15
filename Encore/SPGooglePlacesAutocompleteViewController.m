//
//  SPGooglePlacesAutocompleteViewController.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//  Modified for Encore by Simon Bromberg

#import "SPGooglePlacesAutocompleteViewController.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import <CoreLocation/CoreLocation.h>
#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

@interface SPGooglePlacesAutocompleteViewController ()
-(IBAction)cancel;
-(IBAction)save;
@property (nonatomic,weak) IBOutlet UIButton* saveButton;
@property (nonatomic,weak) IBOutlet UIButton* cancelButton;
@property (nonatomic,strong) CLPlacemark* savedPlacemark;
@end

@implementation SPGooglePlacesAutocompleteViewController
@synthesize mapView;

-(IBAction) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction) save {
    if (!self.savedPlacemark.locality && !self.savedPlacemark.subAdministrativeArea) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Location error" message:@"Please enter a valid city or locality and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    
        [self.delegate updatedSearchLocationToPlacemark:self.savedPlacemark];
    }
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
        searchQuery.radius = 100.0;
        shouldBeginEditing = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
    searchQuery.radius = 100.0;
    shouldBeginEditing = YES;
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"Search for city or drop a pin on the map", @"placeholder text for search bar on top of map");
    [self hideSaveButton];
    
    [self.cancelButton.titleLabel setFont:[UIFont heroFontWithSize:17.0]];
    [self.saveButton.titleLabel setFont:[UIFont heroFontWithSize:17.0]];
//
    self.searchDisplayController.searchBar.backgroundImage = [UIImage imageNamed:@"navbar"];
    
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMap:)];
    [self.mapView addGestureRecognizer:longPress];
    
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    UIImageView* pbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"powered-by-google-on-white"]];
    pbg.contentMode = UIViewContentModeCenter;
    pbg.center = view.center;
    [view addSubview:pbg];
    self.searchDisplayController.searchResultsTableView.tableFooterView = view;
    
}

-(void) longPressMap: (UIGestureRecognizer*) sender {
    if (sender.state == UIGestureRecognizerStateChanged || sender.state == UIGestureRecognizerStateEnded) {
        return;
    }
    else {
        [self.mapView removeAnnotation:selectedPlaceAnnotation];
        CGPoint point = [sender locationInView:self.mapView];
        CLLocationCoordinate2D locCoord = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];
        // Then all you have to do is create the annotation and add it to the map
        selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
        selectedPlaceAnnotation.title = @"Dropped pin";
        selectedPlaceAnnotation.coordinate = locCoord;
        [self.mapView addAnnotation:selectedPlaceAnnotation];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self centerMapToCoordinate:locCoord];
            [self showSaveButton];
        });
        
        CLGeocoder* geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:locCoord.latitude longitude:locCoord.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Error reverse geocoding for dropped pin: %@", error.description);
            }
            
            else {
                CLPlacemark* placemark = [placemarks objectAtIndex:0];
                selectedPlaceAnnotation.title = placemark.locality;
                self.savedPlacemark = placemark;
            }
        }];
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self centerMapToLocation:self.initialLocation];
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.cancelButton.titleLabel.textColor = [UIColor blackColor];
        self.saveButton.titleLabel.textColor = [UIColor blackColor];
    }
}
-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)viewDidUnload {
    [self setMapView:nil];
    [super viewDidUnload];
}

-(void) hideSaveButton {
    self.saveButton.hidden = YES;
    self.saveButton.enabled = NO;
}

-(void) showSaveButton {
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        self.saveButton.titleLabel.textColor = [UIColor blackColor];
    }

    self.saveButton.hidden = NO;
    self.saveButton.enabled = YES;
}


-(void) centerMapToCoordinate: (CLLocationCoordinate2D) coord {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    
    region.center = coord;
    [self.mapView setRegion:region];
}

- (void) centerMapToLocation: (CLLocation*) location {
    CLLocationCoordinate2D location2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
    [self centerMapToCoordinate:location2D];
}

- (IBAction)recenterMapToUserLocation:(id)sender {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    CLLocationCoordinate2D location = self.mapView.userLocation.coordinate;
    
    region.center = location;
    
    [self.mapView setRegion:region animated:YES];
    
    //TODO Save the current location
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error reverse geocoding: %@", error.description);
        }
        
        else {
            CLPlacemark* placemark = [placemarks objectAtIndex:0];
            self.searchDisplayController.searchBar.text = placemark.locality;
            self.savedPlacemark = placemark;
            [self showSaveButton];
        }
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searchResultPlaces count];
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [searchResultPlaces objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SPGooglePlacesAutocompleteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"GillSans" size:16.0];
    cell.textLabel.text = [self placeAtIndexPath:indexPath].name;
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)recenterMapToPlacemark:(CLPlacemark *)placemark {
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    
    region.span = span;
    region.center = placemark.location.coordinate;
    
    [self.mapView setRegion:region];
}

- (void)addPlacemarkAnnotationToMap:(CLPlacemark *)placemark addressString:(NSString *)address {
    [self.mapView removeAnnotation:selectedPlaceAnnotation];
    
    selectedPlaceAnnotation = [[MKPointAnnotation alloc] init];
    selectedPlaceAnnotation.coordinate = placemark.location.coordinate;
    selectedPlaceAnnotation.title = address;
    [self.mapView addAnnotation:selectedPlaceAnnotation];
}

- (void)dismissSearchControllerWhileStayingActive {
    // Animate out the table view.
    NSTimeInterval animationDuration = 0.3;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.searchDisplayController.searchResultsTableView.alpha = 0.0;
    [UIView commitAnimations];
    
    [self.searchDisplayController.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchDisplayController.searchBar resignFirstResponder];
    [self.searchDisplayController setActive:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not map selected Place");
        } else if (placemark) {
            [self addPlacemarkAnnotationToMap:placemark addressString:addressString];
            [self recenterMapToPlacemark:placemark];
            self.searchDisplayController.searchBar.text = place.name;
            [self dismissSearchControllerWhileStayingActive];
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
            self.savedPlacemark = placemark;
            
            [self showSaveButton];
        }
    }];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate

- (void)handleSearchForSearchString:(NSString *)searchString {
    searchQuery.location = self.mapView.userLocation.coordinate;
    searchQuery.input = searchString;
    
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            NSLog(@"%@: could not fetch places: %@",NSStringFromClass(self.class),error.description);
//            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            searchResultPlaces = places;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self handleSearchForSearchString:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

#pragma mark -
#pragma mark UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (![searchBar isFirstResponder]) {
        // User tapped the 'clear' button.
        shouldBeginEditing = NO;
        [self.searchDisplayController setActive:NO];
        [self.mapView removeAnnotation:selectedPlaceAnnotation];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 1.0;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
    return boolToReturn;
}

#pragma mark -
#pragma mark MKMapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id <MKAnnotation>)annotation {
    if (mapViewIn != self.mapView || [annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    static NSString *annotationIdentifier = @"SPGooglePlacesAutocompleteAnnotation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
    }
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    // Whenever we've dropped a pin on the map, immediately select it to present its callout bubble.
    [self.mapView selectAnnotation:selectedPlaceAnnotation animated:YES];
}



@end
