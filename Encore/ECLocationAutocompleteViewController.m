//
//  ECLocationAutocompleteViewController.m
//  Encore
//
//  Created by Simon Bromberg on 2013-09-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLocationAutocompleteViewController.h"
#import "SPGooglePlacesAutocompletePlace.h"
@interface ECLocationAutocompleteViewController () {
    IBOutlet UITextField *_textField;
}

@end

@implementation ECLocationAutocompleteViewController

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
	// Do any additional setup after loading the view
//    SPGooglePlacesAutocomplete
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) textFieldDidBeginEditing:(UITextField *)textField {
    
}


@end
