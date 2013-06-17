//
//  ECAddConcertViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-16.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECJSONFetcher.h"

typedef enum {
    ECSelectPopular,
    ECSelectArtist,
    ECSelectConcert
} ECSelectionStage;


@interface ECAddConcertViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ECJSONFetcherDelegate> {
    ECSelectionStage selectionStage;
}

@property (strong, nonatomic) NSArray *arrData;
@property (strong, nonatomic) ECJSONFetcher * JSONFetcher;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
