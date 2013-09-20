//
//  ECLoginViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLoginViewController.h"
#import "ECAppDelegate.h"
#import "ECJSONPoster.h"
@interface ECLoginViewController ()

@end

@implementation ECLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@: did load",NSStringFromClass(self.class));
}

- (void)viewDidUnload {
    [super viewDidUnload];
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

-(IBAction)performLogin:(id)sender{
    [Flurry logEvent:@"Perform_Login"];
    [ApplicationDelegate showLoginHUD];
    [ApplicationDelegate beginFacebookAuthorization];
}

-(IBAction)loginLater {
    [Flurry logEvent:@"Login_Later"];
    ECAppDelegate* appDelegate = (ECAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate loginLater];
}
- (void)loginFailed {
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
   // [self.spinner stopAnimating];  //TODO: Add spinner?
    [Flurry logEvent:@"Login_Failed"];
}


@end
