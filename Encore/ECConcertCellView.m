//
//  ECConcertCellView.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-23.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECConcertCellView.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDictionary+ConcertList.h"
#import "UIImage+GaussBlur.h"
#import "NSMutableDictionary+ConcertImages.h"

#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"

@implementation ECConcertCellView

- (void)setUpCellForConcert:(NSDictionary *)concertDic {
    self.lblDate.text = [concertDic niceDate];
    self.lblDate.font = [UIFont heroFontWithSize: 12.0];
    self.lblName.text = [concertDic artistName];
    self.lblName.font = [UIFont heroFontWithSize: 18.0];
    self.lblLocation.text = [concertDic venueName];
    self.lblLocation.font = [UIFont heroFontWithSize: 14.0];
    
    //TODO: Move this code to setUpCellImageForConcert: once we have a way to recognized if the server sent a blank image or not
    self.imageArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
    self.imageArtist.layer.cornerRadius = 15.0;
    self.imageArtist.layer.masksToBounds = YES;
//    self.imageArtist.layer.borderWidth = 1.0;
//    self.imageArtist.layer.borderColor = [UIColor imageBorderColor].CGColor;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setUpCellImageForConcert:(UIImage *)image {
    self.imageArtist.image = image;
}

@end
