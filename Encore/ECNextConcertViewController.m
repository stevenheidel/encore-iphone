//
//  ECNextConcertViewController.m
//  Encore
//
//  Created by Mohamed Fouad on 9/19/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECNextConcertViewController.h"
#import "UIFont+Encore.h"
#import "NSUserDefaults+Encore.h"

@interface ECNextConcertViewController ()

@end

@implementation ECNextConcertViewController

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
    [self setApperance];

	// Do any additional setup after loading the view.
}
- (void) setApperance
{
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]]];
    [self.lblNextConcert setFont:[UIFont heroFontWithSize:15]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipButtonTapped:(id)sender {
    [[NSUserDefaults standardUserDefaults] setWalkthoughFinished];
    [self dismissViewControllerAnimated:YES completion:nil];
    [Flurry logEvent:@"Walkthrough_Finished" withParameters:nil];
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
@end
