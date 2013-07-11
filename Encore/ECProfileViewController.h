//
//  ECProfileViewController.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBProfilePictureView.h"
#import "ECFeedbackViewController.h"
@interface ECProfileViewController : UIViewController <UIAlertViewDelegate,ECFeedbackViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSString* userID;
}

@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property(nonatomic, strong) NSArray *arrPastConcerts;
@property(nonatomic, strong) NSMutableArray *arrPastImages;

@property (strong, nonatomic) IBOutlet UIImageView *imgBackground;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *imgProfile;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) IBOutlet UILabel *lblConcerts;
@property (strong, nonatomic) IBOutlet UIImageView *imgLocationMarker;
@property (strong, nonatomic) IBOutlet UIImageView *imgStubs;

@property (nonatomic, readonly) NSArray* pastEvents;
@property (nonatomic, readonly) NSArray* futureEvents;
@property (nonatomic, strong) NSDictionary* events;

@end
