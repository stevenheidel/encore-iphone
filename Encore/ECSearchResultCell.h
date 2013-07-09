//
//  ECSearchResultCell.h
//  Encore
//
//  Created by Luis Ramirez on 2013-07-09.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SEARCH_CELL_HEIGHT 70.0
@interface ECSearchResultCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UIButton *btnAdd;
@property(nonatomic, strong) IBOutlet UIButton *btnDisclosure;
@property(nonatomic, strong) IBOutlet UILabel *lblEventTitle;
@property(nonatomic, strong) IBOutlet UILabel *lblDate;
@property(nonatomic, strong) IBOutlet UILabel *lblVenue;

@end
