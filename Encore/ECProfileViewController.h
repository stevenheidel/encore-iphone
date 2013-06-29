//
//  ECProfileViewController.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECProfileViewController : UIViewController

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet UIImageView *imgProfile;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblConcerts;
@property (strong, nonatomic) IBOutlet UIImageView *imgLocationMarker;
@property (strong, nonatomic) IBOutlet UIImageView *imgStubs;

@end
