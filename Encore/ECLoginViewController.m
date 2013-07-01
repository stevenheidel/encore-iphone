//
//  ECLoginViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLoginViewController.h"
#import "ECAppDelegate.h"
#import "ECMainViewController.h"
#import "ECJSONPoster.h"
#import "ECLoginPageView.h"
@interface ECLoginViewController ()

@end

@implementation ECLoginViewController

@synthesize descScrollView;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

    for (int i = 0; i < arrPages.count; i++) {
        
        NSDictionary *currPageItem = [arrPages objectAtIndex:i];
        
        //Create frame for each page
        CGRect frame;
        frame.origin.x = descScrollView.frame.size.width * i;
        frame.origin.y = 0.0f;
        frame.size = descScrollView.frame.size;
        
        ECLoginPageView *subview = [[ECLoginPageView alloc] initWithFrame:frame];
        [subview SetUpPageforItem:currPageItem];
        
        [descScrollView addSubview:subview];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString *myListPath = [[NSBundle mainBundle] pathForResource:@"LoginInfoPages" ofType:@"plist"];
    arrPages = [[NSArray alloc]initWithContentsOfFile:myListPath];
    
    descScrollView.contentSize = CGSizeMake(descScrollView.frame.size.width * arrPages.count, descScrollView.frame.size.height);
}

- (void)viewDidUnload {
    [self setFBLoginView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLoginView delegate

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    NSLog(@"Completed login successfully");
}


- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error{
    NSString *alertMessage, *alertTitle;
    
    // Facebook SDK * error handling *
    // Error handling is an important part of providing a good user experience.
    // Since this sample uses the FBLoginView, this delegate will respond to
    // login failures, or other failures that have closed the session (such
    // as a token becoming invalid). Please see the [- postOpenGraphAction:]
    // and [- requestPermissionAndPost] on `SCViewController` for further
    // error handling on other operations.
    
    if (error.fberrorShouldNotifyUser) {
        // If the SDK has a message for the user, surface it. This conveniently
        // handles cases like password change or iOS6 app slider state.
        alertTitle = @"Something Went Wrong";
        alertMessage = error.fberrorUserMessage;
    } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
        // It is important to handle session closures as mentioned. You can inspect
        // the error for more context but this sample generically notifies the user.
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
    } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
        // The user has cancelled a login. You can inspect the error
        // for more context. For this sample, we will simply ignore it.
        NSLog(@"user cancelled login");
    } else {
        // For simplicity, this sample treats other errors blindly, but you should
        // refer to https://developers.facebook.com/docs/technical-guides/iossdk/errors/ for more information.
        alertTitle  = @"Unknown Error";
        alertMessage = @"Error. Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    // Facebook SDK * login flow *
    // It is important to always handle session closure because it can happen
    // externally; for example, if the current session's access token becomes
    // invalid. For this sample, we simply pop back to the landing page.
    ECAppDelegate *appDelegate = (ECAppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate.isNavigating) {
        // The delay is for the edge case where a session is immediately closed after
        // logging in and our navigation controller is still animating a push.
        [self performSelector:@selector(logOut) withObject:nil afterDelay:.5];
    } else {
        [self logOut];
    }
}

- (void)logOut {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(IBAction)performLogin:(id)sender{
   // [self.spinner startAnimating];  //TODO: Spinner
    [Flurry logEvent:@"Perform_Login"];
    ECAppDelegate* appDelegate = (ECAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}

- (void)loginFailed {
    // User switched back to the app without authorizing. Stay here, but
    // stop the spinner.
   // [self.spinner stopAnimating];  //TODO: Add spinner?
    [Flurry logEvent:@"Login_Failed"];
}

#pragma mark - UIScrollView and UIPageControl methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = descScrollView.frame.size.width;
    int page = floor((descScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    [Flurry logEvent:@"Scrolled_Login_Page"];
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.descScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.descScrollView.frame.size;
    [self.descScrollView scrollRectToVisible:frame animated:YES];
}


@end
