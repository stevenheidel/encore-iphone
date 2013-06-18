//
//  ECAddConcertViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECJSONFetcher.h"

@interface ECAddConcertViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ECJSONFetcherDelegate> {
    bool hasSearched;
}

@property (nonatomic, assign) ECSearchType searchType;
@property (strong, nonatomic) NSArray *arrArtistData;
@property (strong, nonatomic) NSArray *arrPopularData;
@property (strong, nonatomic) ECJSONFetcher * JSONFetcher;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) NSString * lastSelectedArtist;
@end
