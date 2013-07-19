//
//  ECNewMainViewController.h
//  Encore
//
//  Created by Shimmy on 2013-07-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECProfileViewController.h"
#import "ECSearchType.h"
#import "ECLocationSetterViewController.h"

@class CLLocation;
@class MBProgressHUD, ECLocationSetterViewController;

@interface ECNewMainViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource,UITableViewDelegate, ECLocationSetterDelegate>

- (void)dismissKeyboard;
- (IBAction)openLastFM:(id)sender;
- (IBAction)openLocationSetter;
-(void) initializeSearchLocation: (CLLocation*) currentSearchLocation;

@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (nonatomic, strong) CLLocation* currentSearchLocation;
@property (nonatomic, assign) NSNumber* currentSearchRadius;

@property(nonatomic, weak) IBOutlet UIImageView *imgBackground;
@property (nonatomic, strong) ECLocationSetterViewController* locationSetterView;

@property(nonatomic, weak) IBOutlet UILabel *lblTodaysDate;
@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) BOOL isLoggedIn; //Getter that pulls from app delegate

@property (assign, nonatomic) BOOL hasSearched; //Flag for whether use has performed a search

@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imgLastfmAttr;

@property (nonatomic, assign) ECSearchType currentSearchType;

@property (strong, nonatomic) UINavigationController *profileViewController;

@property(nonatomic, strong) NSArray* todaysConcerts;
@property(nonatomic, strong) NSArray* pastConcerts;
@property(nonatomic, strong) NSArray* futureConcerts;

@property(nonatomic, readonly) NSArray *searchResultsEvents;
@property(nonatomic, readonly) NSDictionary *searchedArtistDic;
@property(nonatomic, readonly) NSArray *otherArtists;
//The three above properties are custom getters based on the one below
@property (nonatomic, strong) NSDictionary* comboSearchResultsDic;

@property (strong,nonatomic) UIBarButtonItem* shareButton;

@property (strong, nonatomic) MBProgressHUD * hud;

@property (strong, nonatomic) UIView* searchHeaderView;

@property (strong,nonatomic) UIRefreshControl* refreshControl;
@end
