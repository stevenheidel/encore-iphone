//
//  ECUpcomingViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECUpcomingViewController.h"
#import "NSDictionary+ConcertList.h"

@interface ECUpcomingViewController ()<ECEventProfileStatusManagerDelegate>

@end

@implementation ECUpcomingViewController

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
    [self setRows];
    [super viewDidLoad];
}

-(void) setRows {
    int NumberOfRows = sizeof(upcomingRows)/sizeof(upcomingRows[0]);
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:NumberOfRows];
    for (int i = 0; i < NumberOfRows; i++) {
        array[i] = [NSNumber numberWithInt:upcomingRows[i]];
    }
    self.rowOrder = [NSArray arrayWithArray:array];
}


-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*) shareText {
    return [NSString stringWithFormat: @"Want to come to %@%@ show at %@, %@?",[self shareTextPrefix],[self.concert eventName],[self.concert venueName],[self.concert niceDateNotUppercase]];
}

//-(void) shareWithTaggedFriends: (NSArray*) taggedFriends {
//    NSLog(@"Sharing with Facebook from Concert detail view controller");
//    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
//    
//    FBShareDialogParams* params = [[FBShareDialogParams alloc] init];
//    params.link = url;
//    if(taggedFriends)
//        [params setFriends:[taggedFriends valueForKey:@"id"]];
//    
//    //    params.description =  [NSString stringWithFormat:@"Check out photos and videos from %@'s %@ show in %@ at the %@ on Encore.",[self.concert artistName], [self.concert niceDate], [self.concert city], [self.concert venueName]];
//    if ([FBDialogs canPresentShareDialogWithParams:params]) {
//        [FBDialogs presentShareDialogWithParams:params clientState:nil handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
//            if(error) {
//                NSLog(@"Error sharing concert: %@", error.description);
//                [Flurry logEvent:@"Concert_Share_To_FB_Fail" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", error.description, @"error", nil]];
//            } else {
//                NSLog(@"Success sharing concert!");
//                [Flurry logEvent:@"Concert_Share_To_FB_Success" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:url.absoluteString, @"url", nil]];
//            }
//            
//        }];
//    }
//    else {
//        NSMutableDictionary *params2 =
//        [NSMutableDictionary dictionaryWithObjectsAndKeys:
//         [NSString stringWithFormat:@"%@ on Encore",[self.concert eventName]], @"name",
//         [NSString stringWithFormat:@"Check out photos and videos from %@'s %@ show on Encore.",[self.concert eventName], [self.concert niceDate]], @"caption",
//         @"Encore is a free iPhone concert app that collects photos and videos from live shows and helps you keep track of upcoming shows in your area.",@"description",
//         [NSString stringWithFormat:ShareConcertURL,self.concert.eventID], @"link",
//         [NSString stringWithFormat:@"%@",[self.concert imageURL].absoluteString], @"picture",
//         nil];
//        [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
//                                               parameters:params2
//                                                  handler:
//         ^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//             if (error) {
//                 // Error launching the dialog or publishing a story.
//                 NSLog(@"Error publishing story.");
//             } else {
//                 if (result == FBWebDialogResultDialogNotCompleted) {
//                     // User clicked the "x" icon
//                     NSLog(@"User canceled story publishing.");
//                 } else {
//                     // Handle the publish feed callback
//                     NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
//                     if (![urlParams valueForKey:@"post_id"]) {
//                         // User clicked the Cancel button
//                         NSLog(@"User canceled story publishing.");
//                     } else {
//                         // User clicked the Share button
//                         NSString *msg = @"Posted to facebook";
//                         NSLog(@"%@", msg);
//                         [Flurry logEvent:@"Successfully_Posted_To_Facebook_With_Feed_Dialog" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:@"Concert",@"type", nil]];
//                         // Show the result in an alert
//                         [[[UIAlertView alloc] initWithTitle:@"Result"  //TODO: replace with HUD
//                                                     message:msg
//                                                    delegate:nil
//                                           cancelButtonTitle:@"OK!"
//                                           otherButtonTitles:nil]
//                          show];
//                     }
//                 }
//             }
//         }];
//    }
//}


@end

