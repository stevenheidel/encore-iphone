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

@class MBProgressHUD;

@interface ECNewMainViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource,UITableViewDelegate>

- (IBAction)dismissKeyboard:(id)sender;

@property(nonatomic, strong) IBOutlet UIImageView *imgBackground;
@property(nonatomic, strong) IBOutlet UILabel *lblTodaysDate;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) BOOL isLoggedIn; //Getter that pulls from app delegate

@property (assign, nonatomic) BOOL hasSearched; //Flag for whether use has performed a search
@property (assign, nonatomic) BOOL loadOther; //Flag for whether user has asked for other search results

@property (strong, nonatomic) UITapGestureRecognizer *tap;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) IBOutlet UITextField *searchBar;
@property (strong, nonatomic) IBOutlet UIImageView *imgLastfmAttr;

@property (nonatomic, assign) ECSearchType currentSearchType;

@property (strong, nonatomic) UINavigationController *profileViewController;
@property (strong, nonatomic) NSString * facebook_id;
@property (strong, nonatomic) NSString * userName;
@property (strong, nonatomic) NSString * userCity;

@property(nonatomic, strong) NSArray* todaysConcerts;
@property(nonatomic, strong) NSArray* pastConcerts;
@property(nonatomic, strong) NSArray* futureConcerts;

//@property(nonatomic, strong) NSMutableArray *arrTodaysImages;
@property(nonatomic, readonly) NSArray *searchResultsEvents;
@property(nonatomic, readonly) NSDictionary *searchedArtistDic;
@property(nonatomic, readonly) NSArray *otherArtists;
//The three above properties are custom getters based on the one below
@property (nonatomic, strong) NSDictionary* comboSearchResultsDic;

@property (strong,nonatomic) UIBarButtonItem* shareButton;

@property (strong, nonatomic) MBProgressHUD * hud;
@end
