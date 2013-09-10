//
//  ECProfileViewController.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FBProfilePictureView.h>
@interface ECProfileViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    NSString* userID;
}

@property (nonatomic, strong) UIRefreshControl* refreshControl;
@property(nonatomic, strong) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *imgBackground;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *imgProfile;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblConcerts;
@property (weak, nonatomic) IBOutlet UIImageView *imgLocationMarker;
@property (weak, nonatomic) IBOutlet UIImageView *imgStubs;

@property (nonatomic, readonly) NSArray* pastEvents;
@property (nonatomic, readonly) NSArray* futureEvents;
@property (nonatomic, strong) NSDictionary* events;

@property(assign) BOOL shouldUpdateView;
@end
