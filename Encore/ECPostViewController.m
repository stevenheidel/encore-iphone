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
    [self setupPost];
    [self.profilePicture.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [self.profilePicture.layer setBorderWidth:1.0];
    self.title = @"Post";//self.userNameLabel.text;
    
    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [self setupGestureRecgonizers];
}

-(void) setupGestureRecgonizers {
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    recognizerLeft.numberOfTouchesRequired = 1;
    recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    recognizerRight.numberOfTouchesRequired = 1;
    recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizerRight];
    [self.view addGestureRecognizer:recognizerLeft];
}

//This function is called on first initial set up as well as later on if the user swipes left or right
-(void) setupPost {
    self.userNameLabel.text = [self.post userName];
    self.captionLabel.text = [self.post caption];
    [self.postImage setImageWithURL:[self.post imageURL]];
    [self.profilePicture setImageWithURL:[self.post profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
}

-(void) showGestureForSwipeRecognizer: (UISwipeGestureRecognizer*) recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self gesture:+1];
    }
    else {
        [self gesture: -1];
    }
}

-(void) gesture: (NSInteger) direction {
    
    NSDictionary* dic = [self.delegate requestPost: direction currentIndex: self.itemNumber];
    self.post = [dic objectForKey:@"dic"];
    self.itemNumber = [(NSNumber*)[dic objectForKey:@"index"] integerValue];
    [self setupPost];
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
