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
#import "UIColor+EncoreUI.h"

#import "ECJSONPoster.h"
#import "NSUserDefaults+Encore.h"
#import "ECAppDelegate.h"
#define FLAG_HUD_DELAY 1.0
#import "ECFacebookManger.h"

typedef enum {
    FlagPhoto
}ActionSheetTags;

@interface ECPostViewController ()
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *venueAndDateLabel;
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

-(id) initWithPost:(NSDictionary *)post {
    self = [super init];
    if (self) {
        self.post = post;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%@: did load",NSStringFromClass(self.class));
    // Do any additional setup after loading the view from its nib.
    [self setupPost];
    self.profilePicture.layer.cornerRadius = 30.0;
    self.profilePicture.layer.masksToBounds = YES;
    self.profilePicture.layer.borderColor = [UIColor grayColor].CGColor;
    self.profilePicture.layer.borderWidth = 3.0;
    self.captionLabel.font = [UIFont heroFontWithSize: 12.0f];
    self.userNameLabel.font = [UIFont lightHeroFontWithSize: 18.0f];

    [self setupNavBar];
    [self setupHeaderLabels];
    [self setupGestureRecgonizers];
    self.containerView.alpha = 0.0;
    self.flagPostButton.alpha = 0.0;
    self.artistLabel.alpha = 0.0;
    self.venueAndDateLabel.alpha = 0.0;
    self.flagPostButton.enabled = NO;
    self.youtubeShowing = NO;
    
}

-(BOOL)shouldAutorotate{
//    if ([self presentedViewController] != nil) {
//        return YES;
//    }
//    else return self.interfaceOrientation == UIInterfaceOrientationMaskPortrait;
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
//    if ([self presentedViewController] != nil) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    }
//    else return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
//    if([self presentedViewController] != nil){
//        return UIInterfaceOrientationLandscapeLeft;
//    }
//    return UIInterfaceOrientationPortrait;
    return UIInterfaceOrientationPortrait;
}

//-(IBAction) tapPlayButton {
//    [Flurry logEvent:@"Tapped_Play_Button" withParameters:self.post];
//    [[ATAppRatingFlow sharedRatingFlow] logSignificantEvent];
//    
////    [self openYouTube];
//}

//-(void) openYouTube {
//    ECYouTubeViewController* youtubeVC = [[ECYouTubeViewController alloc] initWithLink:[self.post youtubeLink]];
//    [self presentViewController:youtubeVC animated:YES completion:nil];
//    
//}

-(void) setViewForCurrentType {
    ECPostType postType = [self.post postType];
    self.youtubeWebView.hidden = postType == ECPhotoPost;
    self.postImage.hidden = postType == ECVideoPost;
    
    if (postType == ECVideoPost) {
        [self setupWebView];
    }
}

-(void) setupWebView {
    NSString* link =  [[self.post youtubeLink] absoluteString];
    // Do any additional setup after loading the view from its nib.
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><meta name = \"viewport\" content = \"initial-scale = 1.0, user-scalable = no, width = 320\"/></head><body style=\"background:#000;margin-top:0px;margin-left:0px\"><div><object width=\"320\" height=\"320\"><param name=\"movie\" value=\"%@\"></param><param name=\"wmode\"value=\"transparent\"></param><embed src=\"%@\"type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"320\" height=\"320\"></embed></object></div></body></html>",link,link];
    
    self.youtubeWebView.scrollView.scrollEnabled = FALSE;
    self.youtubeWebView.contentMode = UIViewContentModeScaleAspectFit;
    self.youtubeWebView.scalesPageToFit = YES;
    self.youtubeWebView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    [self.youtubeWebView loadHTMLString:htmlString baseURL:nil];

}

-(void) setupHeaderLabels {
    [self.artistLabel setFont:[UIFont heroFontWithSize:18.0f]];
    [self.artistLabel setTextColor:[UIColor blueArtistTextColor]];
     
    [self.venueAndDateLabel setFont:[UIFont heroFontWithSize:11.0f]];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.artistLabel.text = [self.artist uppercaseString];
    self.venueAndDateLabel.text = [self.venueAndDate uppercaseString];
}

-(void) setupNavBar {
    UIImageView* encoreLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    self.navigationItem.titleView = encoreLogo;
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *leftButImage = [UIImage imageNamed:@"backButton.png"];
    [leftButton setBackgroundImage:leftButImage forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backButtonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButImage.size.width, leftButImage.size.height);
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *rightButImage = [UIImage imageNamed:@"shareButton.png"];
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
                         self.artistLabel.alpha = self.artistLabel.alpha == 0.0 ? 1.0 : 0.0;
                         self.venueAndDateLabel.alpha = self.venueAndDateLabel.alpha == 0.0 ? 1.0 : 0.0;
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
//                            self.playButton.alpha = 0.0;
                            self.youtubeWebView.alpha = 0.0;
                        } completion:^(BOOL finished) {
                            [self setViewForCurrentType];
                            self.userNameLabel.text = [self.post userName];
                            self.captionLabel.text = [self.post caption];
                            [self.postImage setImageWithURL:[self.post imageURL]];
                            [self.profilePicture setImageWithURL:[self.post profilePictureURL] placeholderImage:[UIImage imageNamed:@"placeholder.jpg"]];
                            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                self.postImage.alpha = 1.0;
//                                self.playButton.alpha = 1.0;
                                self.youtubeWebView.alpha = 1.0;
                            }completion: ^(BOOL finished){

                            }];
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
-(NSString*) userID {
    return [NSUserDefaults userID];
}
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == FlagPhoto) {
        if(buttonIndex != actionSheet.cancelButtonIndex){
            NSString* flag = [actionSheet buttonTitleAtIndex:buttonIndex];
            
            NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:flag,@"flag",[NSNumber numberWithInt:buttonIndex], @"button_index",nil];
            [params addEntriesFromDictionary:self.post];
            
            [ECJSONPoster flagPost:self.postID withFlag:flag fromUser: [self userID] completion:^(BOOL success) {
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
         NSMutableDictionary *params2 =
         [NSMutableDictionary dictionaryWithObjectsAndKeys:
          [NSString stringWithFormat:@"%@ on Encore",self.artist], @"name",
           [NSString stringWithFormat:@"Check out this %@ from %@'s show (%@) on Encore.",[self.post postType] == ECPhotoPost ? @"photo" : @"video", self.artist, self.venueAndDate], @"caption",
          @"Encore is a free iPhone concert app that collects photos and videos from live shows and helps you keep track of upcoming shows in your area.",@"description",
          [NSString stringWithFormat:SharePostURL,self.postID], @"link",
          [NSString stringWithFormat:@"%@",[self.post imageURL].absoluteString], @"picture",
          nil];
         [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                                parameters:params2
                                                   handler:
          ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
              if (error) {
                  // Error launching the dialog or publishing a story.
                  NSLog(@"Error publishing story.");
              } else {
                  if (result == FBWebDialogResultDialogNotCompleted) {
                      // User clicked the "x" icon
                      NSLog(@"User canceled story publishing.");
                  } else {
                      // Handle the publish feed callback
                      NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                      if (![urlParams valueForKey:@"post_id"]) {
                          // User clicked the Cancel button
                          NSLog(@"User canceled story publishing.");
                      } else {
                          // User clicked the Share button
                          NSString *msg = @"Posted to facebook";
                          NSLog(@"%@", msg);
                          [Flurry logEvent:@"Successfully_Posted_To_Facebook_With_Feed_Dialog" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"post",@"type", nil]]; //TODO update so merges flurry events together
                          
                          // Show the result in an alert
                          [[[UIAlertView alloc] initWithTitle:@"Result"  //TODO: replace with HUD
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK!"
                                            otherButtonTitles:nil]
                           show];
                      }
                  }
              }
          }];

     }
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark - Getters
-(NSString*) postID {
    return [self.post postID];
}

@end
