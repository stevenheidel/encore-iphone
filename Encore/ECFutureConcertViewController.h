//
//  ECFutureConcertViewController.h
//  Encore
//
//  Created by Luis Ramirez on 2013-07-03.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECFutureConcertViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSArray* arrFutureConcerts;
@property(nonatomic, strong) NSArray* arrImages;
@property(nonatomic, strong) IBOutlet UITableView *tableView;

@end
