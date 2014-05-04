//
//  ECUpcomingViewController.m
//  Encore
//
//  Created by Simon Bromberg on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECUpcomingViewController.h"
#import "NSDictionary+ConcertList.h"
#import "ECJSONFetcher.h"
#import "DZWebBrowser.h"

@interface ECUpcomingViewController ()<ECEventProfileStatusManagerDelegate>
@property (nonatomic, assign) BOOL seatgeekURLSuccess;
@property (nonatomic, strong) UIActivityIndicatorView* getTicketsActivityIndicator;
@end

@implementation ECUpcomingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [self setRows];
    [self getTicketsURL];
    [super viewDidLoad];
}

-(void) getTicketsURL {
    self.seatgeekURLSuccess = NO;
    self.ticketsURL = self.concert.ticketsURL;
    [ECJSONFetcher fetchSeatgeekURLForEvent:[self.concert eventID] completion:^(NSString *seatgeek_url) {
        self.seatgeekURLSuccess = YES;
        if (seatgeek_url.length > 0) {
            self.ticketsURL = [NSURL URLWithString:seatgeek_url];
        }
    }];
}

-(void) setRows {
    int NumberOfRows = sizeof(upcomingRows)/sizeof(upcomingRows[0]);
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:NumberOfRows];
    for (int i = 0; i < NumberOfRows; i++) {
        array[i] = [NSNumber numberWithInt:upcomingRows[i]];
    }
    self.rowOrder = [NSArray arrayWithArray:array];
}

-(void) grabTicketTapped: (id) sender {
    NSString* flag = @"success";
    if (!self.seatgeekURLSuccess) {
        NSLog(@"seatgeek not done yet");
        [(UIButton*)sender setEnabled:NO];
        if (!self.getTicketsActivityIndicator) {
            self.getTicketsActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            CGRect frame = self.getTicketsActivityIndicator.frame;
            frame.origin.x = 5;
            frame.origin.y = 13;
            self.getTicketsActivityIndicator.frame = frame;
            self.getTicketsActivityIndicator.hidesWhenStopped = YES;
            [(UIButton*) sender addSubview:self.getTicketsActivityIndicator];
        }
        [self.getTicketsActivityIndicator startAnimating];
        [self performSelector:@selector(grabTicketTapped:) withObject:sender afterDelay:0.7]; //fairly arbitrary delay
    }
    else if (self.concert.ticketsURL) {
        DZWebBrowser* browser = [[DZWebBrowser alloc] initWebBrowserWithURL:self.ticketsURL];
        browser.pushed = YES;
        browser.showProgress = YES;
        browser.allowSharing = YES;
        [self.navigationController pushViewController:browser animated:YES];
        [(UIButton*)sender setEnabled:YES];
        [self.getTicketsActivityIndicator stopAnimating];
        [Flurry logEvent:@"Tapped_Grab_Tickets" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.concert.ticketsURL, @"URL", flag, @"success_flag", nil]];
    }
    else {
        flag = @"failed";
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, no tickets link was found." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self.getTicketsActivityIndicator stopAnimating];
        [Flurry logEvent:@"Tapped_Grab_Tickets" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:self.concert.ticketsURL, @"URL", flag, @"success_flag", nil]];
    }


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
}

#pragma mark - sharing
-(NSURL*) shareURL {
    return self.ticketsURL;
}
-(NSString*) shareText {
    return [NSString stringWithFormat: @"Want to come to %@%@ show at %@, %@?",[self shareTextPrefix],[self.concert eventName],[self.concert venueName],[self.concert smallDateNoYear]];
}


@end

