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


@property (assign, nonatomic) BOOL hasSearched;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *SearchBar;

@property (strong, nonatomic) ECProfileViewController *profileViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) NSString * userCity;

@property(nonatomic, strong) NSArray *arrTodaysConcerts;
@property(nonatomic, strong) NSMutableArray *arrTodaysImages;
@property(nonatomic, strong) NSArray *arrSearchConcerts;
@property(nonatomic, strong) NSDictionary *searchedArtistDic;
@property(nonatomic, strong) NSArray *arrAltArtists;

@property (strong,nonatomic) UIBarButtonItem* shareButton;
@end
