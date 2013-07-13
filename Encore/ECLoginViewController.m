//
//  ECLoginViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLoginViewController.h"
#import "ECAppDelegate.h"
//#import "ECMainViewController.h"
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
        frame.origin.x = self.descScrollView.frame.size.width * i;
        frame.origin.y = 0.0f;
        frame.size = self.descScrollView.frame.size;
        
        ECLoginPageView *subview = [[ECLoginPageView alloc] initWithFrame:frame];
        [subview SetUpPageforItem:currPageItem];
        
        [self.descScrollView addSubview:subview];
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
    
    self.descScrollView.contentSize = CGSizeMake(descScrollView.frame.size.width * arrPages.count, descScrollView.frame.size.height);
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)performLogin:(id)sender{
   // [self.spinner startAnimating];  //TODO: Spinner
    [Flurry logEvent:@"Perform_Login"];
    ECAppDelegate* appDelegate = (ECAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate openSession];
}

-(IBAction)loginLater {
    [Flurry logEvent:@"Login_Later"];
    ECAppDelegate* appDelegate = (ECAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate loginLater];
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
    CGFloat pageWidth = self.descScrollView.frame.size.width;
    int page = floor((self.descScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (IBAction)changePage: (id) sender {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.descScrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.descScrollView.frame.size;
    [self.descScrollView scrollRectToVisible:frame animated:YES];
    
    [Flurry logEvent:@"Scrolled_Login_Page" withParameters:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:((UIPageControl*) sender).currentPage] forKey:@"page_number"]];
}


@end
