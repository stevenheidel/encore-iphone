//
//  ECAddConcertViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECJSONFetcher.h"
#import "ECCustomSearchBar.h"
@class MBProgressHUD;
@interface ECAddConcertViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ECJSONFetcherDelegate, UITextFieldDelegate> {
    bool hasSearched;
}

@property (nonatomic, assign) ECSearchType searchType;
@property (strong, nonatomic) NSArray *arrArtistData;
@property (strong, nonatomic) NSArray *arrArtistConcerts;
@property (strong, nonatomic) NSArray *arrPopularData;
@property (strong, nonatomic) NSMutableArray *arrPopularImages;
@property (strong, nonatomic) NSMutableArray *arrArtistImages;
@property (strong, nonatomic) ECJSONFetcher * JSONFetcher;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
//@property (strong, nonatomic) IBOutlet ECCustomSearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITextField *artistSearch;
@property (strong, nonatomic) IBOutlet UITextField *locationSearch;
@property (strong, nonatomic) IBOutlet UIButton *btnLocationIcon;
@property (strong, nonatomic) IBOutlet UIButton *btnSearchIcon;
@property (strong, nonatomic) IBOutlet UIView * searchDivisor;
//@property (strong, nonatomic) IBOutlet UILabel *lblLocation;
@property (strong, nonatomic) MBProgressHUD * hud;

@property (nonatomic, assign) NSDictionary * lastSelectedArtist;

-(IBAction)dismissKeyboard:(id)sender;
@end
