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
#import "ATAppRatingFlow.h"

#import "MBProgressHUD.h"

#import "UIFont+Encore.h"
#import "ECJSONPoster.h"

#define FLAG_HUD_DELAY 1.0

typedef enum {
    FlagPhoto
}ActionSheetTags;
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
    self.captionLabel.font = [UIFont heroFontWithSize: 12.0f];
    self.userNameLabel.font = [UIFont lightHeroFontWithSize: 18.0f];

    [self setupNavBar];

    [self setupGestureRecgonizers];
    self.containerView.alpha = 0.0;
    self.flagPostButton.alpha = 0.0;
    self.flagPostButton.enabled = NO;
}

-(void) setupNavBar {
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"]; //stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [rightButton setBackgroundImage:rightButImage forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(shareTapped) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, rightButImage.size.width, rightButImage.size.height);
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = shareButton;
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
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    NSString* logKey = self.containerView.alpha == 1.0 ? @"Hide" : @"Show";
    [Flurry logEvent:[NSString stringWithFormat:@"Tapped_Post_To_%@_Details",logKey]];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.containerView.alpha = self.containerView.alpha == 0.0 ? 1.0 : 0.0;
                         self.flagPostButton.alpha = self.flagPostButton.alpha == 0.0 ? 1.0 : 0.0;
                     }
                     completion:^(BOOL finished){
                         self.flagPostButton.enabled = self.flagPostButton.alpha == 1.0;
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
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
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

-(IBAction) flagPhoto {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    NSString* flagPhotoTitle = NSLocalizedString(@"flag_post_title", nil);
    NSString* cancel = NSLocalizedString(@"cancel", nil);
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:flagPhotoTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancel
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"flag_1", nil),NSLocalizedString(@"flag_2", nil), NSLocalizedString(@"flag_other", nil), nil];
    
    actionSheet.tag = FlagPhoto;
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == FlagPhoto) {
        if(buttonIndex != actionSheet.cancelButtonIndex){
            NSString* flag = [actionSheet buttonTitleAtIndex:buttonIndex];
            
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:flag,@"flag",[NSNumber numberWithInt:buttonIndex], @"button_index",nil];
            [params addEntriesFromDictionary:self.post];
            
            [ECJSONPoster flagPost:self.postID withFlag:flag completion:^(BOOL success) {
                [params setObject:[NSNumber numberWithBool:success] forKey:@"success"];
                [Flurry logEvent:@"Flagged_Post" withParameters:params];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.labelText = success ? NSLocalizedString(@"flag_hud_text", nil) : NSLocalizedString(@"flag_hud_fail_text", nil);
                hud.mode = MBProgressHUDModeText;
                hud.removeFromSuperViewOnHide = YES;
                [hud hide:YES afterDelay:FLAG_HUD_DELAY];
            }];
        }
        else {
            [Flurry logEvent:@"Canceled_Flagging_Post" withParameters:self.post];
        }
    }
    
}

-(void) shareTapped {
    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
    
    //baseurl + /posts/:Id
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:SharePostURL,self.postID]];
    // if ([FBDialogs canPresentShareDialogWithParams:nil]) {
    FBShareDialogParams* params = [[FBShareDialogParams alloc] init];
    params.link = url;
     if ([FBDialogs canPresentShareDialogWithParams:params]) {
         [FBDialogs presentShareDialogWithLink:url
                                       handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                           if(error) {
                                               NSLog(@"Error posting to FB: %@", error.description);
                                               [Flurry logEvent:@"Post_Share_To_FB_Fail" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url",error.description,@"error",nil]];
                                           } else {
                                               [Flurry logEvent:@"Post_Share_To_FB_Success" withParameters:[NSDictionary dictionaryWithObject:url.absoluteString forKey:@"url"]];
                                           }
                                       }];
    //    }
     }
     else {
         NSArray* items = [NSArray arrayWithObjects:url,[NSString stringWithFormat:@"Check out this picture on Encore"],self.postImage.image, nil];
         UIActivityViewController* activityVC = [[UIActivityViewController alloc] initWithActivityItems: items applicationActivities:nil];
         activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypePostToWeibo, UIActivityTypeSaveToCameraRoll,UIActivityTypeAssignToContact];
         activityVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
         activityVC.completionHandler = ^(NSString* activityType, BOOL completed){
             [Flurry logEvent:@"Post_Share_With_ActivityVC" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:completed], @"completed", activityType, @"activity_type", url.absoluteString, @"url",nil]];
         };

         [self presentViewController:activityVC animated:YES completion:nil];

     }
}

#pragma mark - Getters
-(NSString*) postID {
    return [self.post postID];
}

@end
