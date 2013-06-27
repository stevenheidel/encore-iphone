//
//  ECAddConcertViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECCustomSearchBar.h"
#import "ECSearchType.h"
@class MBProgressHUD;

@interface ECAddConcertViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    bool hasSearched;
}

@property (nonatomic, assign) ECSearchType searchType;
@property (nonatomic, assign) BOOL foundArtistConcerts;
@property (strong, nonatomic) NSArray *arrArtistData;
@property (strong, nonatomic) NSArray *arrArtistConcerts;
@property (strong, nonatomic) NSArray *arrPopularData;
@property (strong, nonatomic) NSMutableArray *arrPopularImages;
@property (strong, nonatomic) NSMutableArray *arrArtistImages;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextField *artistSearch;
@property (strong, nonatomic) IBOutlet UITextField *locationSearch;
@property (strong, nonatomic) IBOutlet UIButton *btnLocationIcon;
@property (strong, nonatomic) IBOutlet UIButton *btnSearchIcon;
@property (strong, nonatomic) IBOutlet UIView * searchDivisor;
@property (strong, nonatomic) IBOutlet UILabel *lblNoresults;
@property (strong, nonatomic) MBProgressHUD * hud;

@property (nonatomic, assign) NSDictionary * lastSelectedArtist;

-(IBAction)dismissKeyboard:(id)sender;
@end
