//
//  ECViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
// Displays post in full view with caption etc underneath

#import "ECPostViewController.h"
#import "NSDictionary+Posts.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>
@interface ECPostViewController ()

@end

@implementation ECPostViewController

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
    self.userNameLabel.text = [self.post userName];
    self.captionLabel.text = [self.post caption];
    [self.postImage setImageWithURL:[self.post imageURL]];
    //[self.profilePicture setImageWithURL:[self.post profilePictureURL]];
    [self.profilePicture setImageWithURL:[self.post profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
    [self.profilePicture.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.profilePicture.layer setBorderWidth:1.0];
    self.title = self.userNameLabel.text;
    
    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
    self.navigationItem.rightBarButtonItem = shareButton;
}

-(void) shareTapped {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Share" message:@"NO SHARING FOR YOU!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
