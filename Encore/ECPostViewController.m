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
    self.profilePicture.layer.cornerRadius = 35.0;
    self.profilePicture.layer.masksToBounds = YES;
    self.profilePicture.layer.borderColor = [UIColor grayColor].CGColor;
    self.profilePicture.layer.borderWidth = 3.0;
    self.captionLabel.font = [UIFont fontWithName:@"Hero" size:12.0f];
    self.userNameLabel.font = [UIFont fontWithName:@"Hero Light" size:18.0f];
    
    self.title = @"Post";//self.userNameLabel.text;
    
    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
    self.navigationItem.rightBarButtonItem = shareButton;
    [self setupGestureRecgonizers];
    self.containerView.alpha = 0.0;
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
    
    UITapGestureRecognizer* recognizerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPost)];
    recognizerTap.numberOfTapsRequired = 1;
    recognizerTap.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:recognizerTap];
}
-(void) tapPost {
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.containerView.alpha = self.containerView.alpha == 0.0 ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished){
                     }];
    
}
//This function is called on first initial set up as well as later on if the user swipes left or right
-(void) setupPost {
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            self.postImage.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            self.userNameLabel.text = [self.post userName];
                            self.captionLabel.text = [self.post caption];
                            [self.postImage setImageWithURL:[self.post imageURL]];
                            [self.profilePicture setImageWithURL:[self.post profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
                            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{self.postImage.alpha = 1.0; }completion:nil];
                        }
     ];

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
