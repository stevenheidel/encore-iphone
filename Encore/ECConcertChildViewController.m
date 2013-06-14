//
//  ECConcertChildViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-14.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECConcertChildViewController.h"
#import "NSDictionary+ConcertList.h"
@interface ECConcertChildViewController ()

@end

@implementation ECConcertChildViewController

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
    // Do any additional setup after loading the view from its nib.
    }

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
        
}

-(void) updateView {
    self.artistLabel.text = [self.concert artistName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
