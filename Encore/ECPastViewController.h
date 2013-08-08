//
//  ECPastViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-07.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSearchType.h"


@interface ECPastViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventVenueAndDate;

@property (nonatomic, assign) ECSearchType tense;
@property (nonatomic,strong) NSDictionary * concert;

@end
