//
//  ECCustomNavController.m
//  Encore
//
//  Created by Shimmy on 2013-07-21.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECCustomNavController.h"

@interface ECCustomNavController ()

@end

@implementation ECCustomNavController

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
    NSLog(@"%@: did load",NSStringFromClass(self.class));
	// Do any additional setup after loading the view.
}


-(NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(BOOL) shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
