//
//  ECLoginPageView.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLoginPageView.h"

@interface ECLoginPageView ()

@end

@implementation ECLoginPageView

@synthesize image;
@synthesize lblHeader, lblText;

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
