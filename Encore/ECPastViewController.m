//
//  ECPastViewController.m
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECPastViewController.h"
#import "ECGridViewController.h"
#import "NSDictionary+ConcertList.h"
#import "EncoreURL.h"

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
        vc.hideShareButton = self.hideShareButton;
        [Flurry logEvent:@"Tapped_See_Photos_Past" withParameters:[self flurryParam]];
    }
}
#pragma mark FB Sharing

-(NSString*) shareText {
    return [NSString stringWithFormat: @"Check out these photos and videos on Encore from %@%@ show at %@, %@.",[self shareTextPrefix],[self.concert eventName],[self.concert venueName],[self.concert niceDate]];
}

@end
