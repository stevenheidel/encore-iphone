//
//  ECSearchResultCell.m
//  Encore
//
//  Created by Luis Ramirez on 2013-07-09.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECSearchResultCell.h"
#import "UIColor+EncoreUI.h"

@implementation ECSearchResultCell

- (void)setupCellForEvent:(NSDictionary *)concertDic {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.lblEventTitle.text = [[concertDic artistName]uppercaseString];
    self.lblEventTitle.textColor = [UIColor blueArtistTextColor];
    
    self.lblDate.text = [concertDic niceDate];
    self.lblVenue.text = [[concertDic venueName] uppercaseString];
    self.lblDate.textColor = [UIColor whiteColor];
    self.lblVenue.textColor = [UIColor whiteColor];
    
    self.lblEventTitle.font = [UIFont fontWithName:@"Hero" size:self.lblEventTitle.font.pointSize];
    self.lblDate.font = [UIFont fontWithName:@"Hero" size:self.lblDate.font.pointSize];
    self.lblVenue.font = [UIFont fontWithName:@"Hero" size:self.lblVenue.font.pointSize];
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
}

@end
