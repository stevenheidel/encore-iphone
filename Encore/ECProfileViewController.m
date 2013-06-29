//
//  ECProfileViewController.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileViewController.h"
#import "ECProfileHeader.h"

#define HEADER_HEIGHT 200.0

@interface ECProfileViewController ()

@end

@implementation ECProfileViewController

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
    self.tableView.tableFooterView = [self footerView];
    self.tableView.tableHeaderView = [[ECProfileHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, HEADER_HEIGHT) andOwner:self];
    self.lblName.font = [UIFont fontWithName:@"Hero" size:18.0];
    self.lblLocation.font = [UIFont fontWithName:@"Hero" size:14.0];
    self.lblConcerts.font = [UIFont fontWithName:@"Hero" size:14.0];
}



- (UIView *) footerView {
    
    UIImage *footerImage = [UIImage imageNamed:@"songkick"];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, footerImage.size.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, footerImage.size.width, footerImage.size.height)];
    imageView.center = footerView.center;
    imageView.image = footerImage;
    footerView.backgroundColor = [UIColor colorWithRed:225.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0];
    [footerView addSubview:imageView];
    return footerView;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


