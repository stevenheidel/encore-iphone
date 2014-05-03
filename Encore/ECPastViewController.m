//
//  ECPastViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//
static NSString * const kDateFormat = @"yyyy-MM-dd";
#import "ECPastViewController.h"
#import "ECGridViewController.h"
#import "NSDictionary+ConcertList.h"
#import "EncoreURL.h"
#import "NSUserDefaults+Encore.h"

@implementation ECPastViewController

-(void) setRows {
    int NumberOfRows = sizeof(pastRows)/sizeof(pastRows[0]);
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:NumberOfRows];
    for (int i = 0; i < NumberOfRows; i++) {
        array[i] = [NSNumber numberWithInt:pastRows[i]];
    }
    self.rowOrder = [NSArray arrayWithArray:array];
}
                    
- (void)viewDidLoad {
    [self setRows];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.''
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"PastViewControllerToGridViewController"]) {
        ECGridViewController* vc = [segue destinationViewController];
        vc.concert = self.concert;
        vc.concertDetailPage = self;
        vc.backButtonShouldGlow = NO;
        vc.isSingleColumn = YES;
        vc.hideShareButton = self.hideShareButton;
        [Flurry logEvent:@"Tapped_See_Photos_Past" withParameters:[self flurryParam]];
    }
}
#pragma mark FB Sharing

-(NSURL*) shareURL {
    return [NSURL URLWithString:[NSString stringWithFormat:ShareConcertURL,self.concert.eventID]];
}

-(NSString*) shareText {
    NSString * dateStr = [self.concert objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:kDateFormat];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"dd/MM/yy"];
    
    return [NSString stringWithFormat: @"Check out these photos and videos from the %@ %@ show",[dateFormat stringFromDate:date],[self.concert eventName]];
}

@end
