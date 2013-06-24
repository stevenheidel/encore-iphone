//
//  ECTodayViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-17.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECJSONFetcher.h"
@class MBProgressHUD;
@interface ECTodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ECJSONFetcherDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *arrTodaysConcerts;
@property (strong, nonatomic) MBProgressHUD * hud;

@end
