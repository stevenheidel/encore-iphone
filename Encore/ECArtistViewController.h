//
//  ECArtistViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECArtistViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSDictionary* artist;
@property (nonatomic,strong) NSDictionary* events;

@end
