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

@interface ECUpcomingViewController ()<ECEventProfileStatusManagerDelegate>

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
    self.ticketsURL = self.concert.ticketsURL;
    [ECJSONFetcher fetchSeatgeekURLForEvent:[self.concert eventID] completion:^(NSString *seatgeek_url) {
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

