//
//  ECNewMainViewController.h
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECProfileViewController.h"

@interface ECNewMainViewController : UITableViewController
-(void) fetchConcerts;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (strong, nonatomic) ECProfileViewController *profileViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) NSString * userCity;

@property(nonatomic, strong) NSArray *arrTodaysConcerts;

@property (strong,nonatomic) UIBarButtonItem* shareButton;
@end
