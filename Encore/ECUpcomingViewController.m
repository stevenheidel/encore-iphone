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
}

-(NSString*) shareText {
    return [NSString stringWithFormat: @"Want to come to %@%@ show at %@, %@?",[self shareTextPrefix],[self.concert eventName],[self.concert venueName],[self.concert niceDateNotUppercase]];
}


@end

