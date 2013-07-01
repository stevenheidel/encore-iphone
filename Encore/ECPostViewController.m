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
#import "EncoreURL.h"
#import <FacebookSDK/FacebookSDK.h>

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
    self.profilePicture.layer.cornerRadius = 30.0;
    self.profilePicture.layer.masksToBounds = YES;
    self.profilePicture.layer.borderColor = [UIColor grayColor].CGColor;
    self.profilePicture.layer.borderWidth = 3.0;
    self.captionLabel.font = [UIFont fontWithName:@"Hero" size:12.0f];
    self.userNameLabel.font = [UIFont fontWithName:@"Hero Light" size:18.0f];
    
    //self.title = @"Post";//self.userNameLabel.text;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width*0.75, leftButImage.size.height*0.75);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width*0.75, rightButImage.size.height*0.75);
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = shareButton;
    
//    UIBarButtonItem * shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped)];
//    self.navigationItem.rightBarButtonItem = shareButton;
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
    [Flurry logEvent:@"Tapped_Post_To_Show_Post_Details"];
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
    int direction = 0;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        direction = +1;
    }
    else {
        direction = -1;
    }
    [Flurry logEvent:@"Swiped_On_Post" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:direction], @"direction", nil]];
    [self gesture:direction];
    
}

-(void) gesture: (NSInteger) direction {
    
    NSDictionary* dic = [self.delegate requestPost: direction currentIndex: self.itemNumber];
    if(dic) {
        self.post = [dic objectForKey:@"dic"];
        self.itemNumber = [(NSNumber*)[dic objectForKey:@"index"] integerValue];
        [self setupPost];
    }
}

-(void) backButtonWasPressed {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) shareTapped {
    //TODO: Check if user can present share dialogs and if not switch to using web to share
    
    //baseurl + /posts/:Id
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:SharePostURL,self.postID]];
    // if ([FBDialogs canPresentShareDialogWithParams:nil]) {
    
    [FBDialogs presentShareDialogWithLink:url
                                  handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                      if(error) {
                                          NSLog(@"Error posting to FB: %@", error.description);
                                          [Flurry logEvent:@"Post_Share_To_FB_Fail"];
                                      } else {
                                          [Flurry logEvent:@"Post_Share_To_FB_Success" withParameters:[NSDictionary dictionaryWithObject:url.absoluteString forKey:@"url"]];
                                      }
                                  }];
    //    }
}

#pragma mark - Getters
-(NSNumber*) postID {
    return [self.post postID];
}

@end
