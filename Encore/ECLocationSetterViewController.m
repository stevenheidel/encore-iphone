//
//  ECLocationSetterView.m
//  Encore
//
//  Created by Shimmy on 2013-07-14.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLocationSetterViewController.h"
#import "NSUserDefaults+Encore.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ECAlertTags.h"
#import "ATAppRatingFlow.h"
#import "Flurry.h"


@implementation ECLocationSetterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

NSString* locationStringForPlacemark(MKPlacemark* placemark) {
    return [NSString stringWithFormat:@"%@, %@, %@",placemark.locality,placemark.administrativeArea,placemark.country];
}
-(void) getDefaults {
    float lastSearchRadius = [NSUserDefaults lastSearchRadius];
    if (lastSearchRadius == 0) {// nsuserdefaults will return 0 if the key doesn't already exist.
        self.radius = 0.5f;
        [NSUserDefaults setLastSearchRadius:lastSearchRadius];
        [NSUserDefaults synchronize];
    }
    
    CLLocation* lastSearchLocation = [NSUserDefaults lastSearchLocation];
    
    if (lastSearchLocation) {
        self.location = lastSearchLocation;
    }
    
    else self.location = [NSUserDefaults userCoordinate];
    
    if (self.location != nil) { //userCoordinate method returns nil if lat or long are 0. In theory should never happen though
        CLGeocoder* geocoder = [CLGeocoder new];
        [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Error reverse geocoding: %@", error.description);
            }
            
            NSLog(@"%@", [[placemarks objectAtIndex:0] locality]);
            self.locationSearchBar.text = locationStringForPlacemark([placemarks objectAtIndex:0]);
        }];
    }

}
-(void) viewDidLoad {
    [super viewDidLoad];
    [self.locationSlider setThumbImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
    [self.locationSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum"] forState:UIControlStateNormal];
    [self.locationSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum"] forState:UIControlStateNormal];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getDefaults];
}

-(void) setRadius:(float)radius {
    _radius = radius;
    self.locationSlider.value = radius;
}

-(IBAction) touchedOutsideTextField: (id) sender {
    [self.view endEditing:YES];
}

- (IBAction)infoButtonTapped {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Search Location" message:@"Set the search location by typing in a city in the search bar. Be more specific by including the state or province and/or country." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [Flurry logEvent:@"Info_Button_Tapped"];
}
#define kOFFSET_FOR_KEYBOARD 200.0


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [self resignFirstResponder];
    if ([textField isEqual:self.locationSearchBar])
    {
        //move the main view, so that the keyboard does not hide it.
        [self moveBack];
    }

    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

    if ([textField isEqual:self.locationSearchBar])
    {
        [self moveUp];
    }
    return YES;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];

    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];

    [geocoder geocodeAddressString:textField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        MKPlacemark *placemark = [placemarks objectAtIndex:0];
        
        [Flurry logEvent:@"Set_Search_Location" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:textField.text,@"search_string",[NSNumber numberWithFloat:self.locationSlider.value],@"search_radius",error ? @"error":@"no_error", @"wasError", nil]];
        if (error || placemark.locality == nil || placemark.country == nil) {\
            //eg if you search "Canada" you'll get a nil locality, and the coordinate is in the middle of nowhere.
            NSLog(@"%@: Geocode failed with error: %@", NSStringFromClass(self.class),error);
            [self alertForFailedGeocode];
            return;
        }
        
        NSLog(@"%d places found",placemarks.count);
        [self alertForConfirmGeocode:locationStringForPlacemark(placemark)];
        self.location = placemark.location;
        NSLog(@"%f %f",self.location.coordinate.latitude,self.location.coordinate.longitude);
        
    }];
    return YES;
}

-(void) alertForFailedGeocode {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"That location doesn't cut it. Please try again.", @"The location entered was invalid or caused an unexpected error, so prompt the user to try again") delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    alert.tag = FailedGeocodeAlert;
    [alert show];
}

-(void) alertForConfirmGeocode: (NSString*) locationString {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Location", @"Title for an alert asking the user if the geocoded location is correct")
                                                    message: [NSString stringWithFormat:NSLocalizedString(@"Did you mean %@? If that's not correct, please try again with more details, such as the state, province, or country", @"Prompt user to ask whether the geocoded location is correct"),locationString]
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Redo", nil)
                                          otherButtonTitles:NSLocalizedString(@"Set", nil),nil];
    alert.tag = LocationSetterRightAlert;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == LocationSetterRightAlert) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            
        }
        else if (buttonIndex == alertView.firstOtherButtonIndex) {
            if ([self.locationSearchBar isFirstResponder]) {
                [self.locationSearchBar resignFirstResponder];
            }
            [self.delegate updateSearchLocation:self.location radius:self.radius]; //this will dismiss the view
        }
    }
}

-(void) moveUp {
    [self setViewMovedUp:YES];
}

-(void) moveBack {
    [self setViewMovedUp:NO];
}
//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([self.locationSearchBar isFirstResponder]){
        [self.locationSearchBar resignFirstResponder];
    }
}

@end
