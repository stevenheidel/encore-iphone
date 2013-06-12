//
//  ECMyConcertViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-11.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECMyConcertViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray * concertList;
@property (nonatomic,strong) NSDictionary * concerts;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@end
