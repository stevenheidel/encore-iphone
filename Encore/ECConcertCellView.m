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

@implementation ECConcertCellView

- (void)setUpCellForConcert:(NSDictionary *)concertDic {
    self.lblDate.text = [concertDic niceDate];
    self.lblDate.font = [UIFont fontWithName:@"Hero" size:13.0];
    self.lblName.text = [concertDic artistName];
    self.lblName.font = [UIFont fontWithName:@"Hero" size:18.0];
    self.lblLocation.text = [concertDic venueName];
    self.lblLocation.font = [UIFont fontWithName:@"Hero" size:14.0];
    
    self.imageArtist.image = [UIImage imageNamed:@"placeholder.jpg"];
    self.imageArtist.layer.cornerRadius = 30.0;
    self.imageArtist.layer.masksToBounds = YES;
    self.imageArtist.layer.borderColor = [UIColor grayColor].CGColor;
    self.imageArtist.layer.borderWidth = 3.0;
    
    self.imageBackground.image = [[UIImage imageNamed:@"sampleArtistImage.jpg"] imageWithGaussianBlur];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setUpCellImagesForConcert:(NSMutableDictionary *)imageDic {
    self.imageArtist.image = [imageDic regularImage];
    self.imageBackground.image = [imageDic gaussImage];
}

@end
