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
-(void) awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.lblEventTitle.textColor = [UIColor blueArtistTextColor];
    self.lblDate.textColor = [UIColor whiteColor];
    self.lblVenue.textColor = [UIColor whiteColor];
    self.lblEventTitle.font = [UIFont fontWithName:@"Hero" size:self.lblEventTitle.font.pointSize];
    self.lblDate.font = [UIFont fontWithName:@"Hero" size:self.lblDate.font.pointSize];
    self.lblVenue.font = [UIFont fontWithName:@"Hero" size:self.lblVenue.font.pointSize];
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];

}
- (void)setupCellForEvent:(NSDictionary *)concertDic {
    
    self.lblEventTitle.text = [[concertDic eventName]uppercaseString];
    
    self.lblDate.text = [concertDic niceDate];
    self.lblVenue.text = [[concertDic venueName] uppercaseString];
}

-(IBAction) addToProfile {
    
}

@end
