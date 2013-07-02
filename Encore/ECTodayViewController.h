//
//  ECTodayViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-17.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@protocol ECTodayViewControllerDelegate;

@interface ECTodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *arrTodaysConcerts;
@property(nonatomic, strong) NSMutableArray *arrTodaysImages;
@property (strong, nonatomic) MBProgressHUD * hud;
@property (nonatomic, unsafe_unretained) id <ECTodayViewControllerDelegate> delegate;
@end

@protocol ECTodayViewControllerDelegate <NSObject>

@required
-(void) doneLoadingTodayConcerts;

@end