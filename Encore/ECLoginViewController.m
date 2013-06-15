//
//  ECLoginViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLoginViewController.h"
#import "ECAppDelegate.h"
#import "ECProfileViewController.h"
#import "ECJSONPoster.h"
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
        
        UIView *subview = [self subviewForItem:currPageItem withFrame:frame];
        
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
    NSLog(@"%@",arrPages);
    
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
    // Upon login, transition to the main UI by pushing it onto the navigation stack.
    ECAppDelegate *appDelegate = (ECAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate loginCompleted];
    //[self.navigationController pushViewController:((UIViewController *)appDelegate.profileViewController) animated:YES];
   //[self.navigationController.navigationBar.bac]
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

#pragma mark - UIScrollView and UIPageControl methods

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = descScrollView.frame.size.width;
    int page = floor((descScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.descScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.descScrollView.frame.size;
    [self.descScrollView scrollRectToVisible:frame animated:YES];
}

- (UIView *)subviewForItem:(NSDictionary *)currPageItem withFrame:(CGRect)frame {
    UIView *subview = [[UIView alloc] initWithFrame:frame];
    subview.backgroundColor = [UIColor blackColor];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[currPageItem objectForKey:@"image"]]];
    CGFloat imageX = subview.frame.size.width/2 - image.frame.size.width/2;
    CGFloat imageY = subview.frame.size.height/2 - image.frame.size.height;
    [image setFrame:CGRectMake(imageX, imageY, image.frame.size.width, image.frame.size.height)];
    //image.center = subview.center;
    [subview addSubview:image];
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, (image.frame.origin.y + image.frame.size.height + 20.0f), 260.0f, 20.0f)];
    lblHeader.backgroundColor = subview.backgroundColor;
    lblHeader.textColor = [UIColor whiteColor];
    lblHeader.text = [currPageItem objectForKey:@"header"];
    lblHeader.textAlignment = NSTextAlignmentCenter;
    [subview addSubview:lblHeader];
    
    UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(40.0f, (lblHeader.frame.origin.y + lblHeader.frame.size.height + 25.0f), 260.0f, 50.0f)];
    lblText.backgroundColor = subview.backgroundColor;
    lblText.textColor = [UIColor whiteColor];
    
    UIFont *font = lblText.font;
    for(int i = 14; i > 10; i--)
    {
        // Set the new font size.
        font = [lblText.font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(260.0f, MAXFLOAT);
        CGSize labelSize = [[currPageItem objectForKey:@"text"] sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        if(labelSize.height <= 50.0f)
            break;
    }
    lblText.text = [currPageItem objectForKey:@"text"];
    lblText.textAlignment = NSTextAlignmentCenter;
    lblText.numberOfLines = 0;
    lblText.font = font;
    //lblText.minimumScaleFactor = 0.1f;
    lblText.adjustsFontSizeToFitWidth = YES;
    [subview addSubview:lblText];
    
    return subview;
}

@end
