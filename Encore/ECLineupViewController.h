//
//  ECLineupViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECLineupViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSArray* artists;
@property (strong, nonatomic) NSString* headliner;
@end
