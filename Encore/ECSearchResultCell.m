//
//  ECSearchResultCell.m
//  Encore
//
//  Created by Luis Ramirez on 2013-07-09.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECSearchResultCell.h"

@implementation ECSearchResultCell

- (void)setupCellForEvent:(NSDictionary *)concertDic {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.lblEventTitle.text = [concertDic artistName];
    self.lblDate.text = [concertDic niceDate];
    self.lblVenue.text = [concertDic venueName];

}

@end
