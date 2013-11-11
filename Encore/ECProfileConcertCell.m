//
//  ECConcertCellView.m
//  Encore
//  Used in listing Profile's concerts
//  Created by Simon Bromberg.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileConcertCell.h"
#import <QuartzCore/QuartzCore.h>
#import "NSDictionary+ConcertList.h"
#import "UIImage+GaussBlur.h"

#import "UIColor+EncoreUI.h"
#import "UIFont+Encore.h"
#import "UIImageView+AFNetworking.h"

@implementation ECProfileConcertCell

- (void)setUpCellForConcert:(NSDictionary *)concertDic {
    
    self.lblDate.text = [concertDic niceDate];
    self.lblDate.font = [UIFont heroFontWithSize: 10.0];
    self.lblDate.textColor = [UIColor whiteColor];
    self.lblName.text = [[concertDic eventName] uppercaseString];
    self.lblName.font = [UIFont heroFontWithSize: 16.0];
    self.lblName.textColor = [UIColor blueArtistTextColor];
    self.lblLocation.text = [[concertDic venueName] uppercaseString];
    self.lblLocation.font = [UIFont heroFontWithSize: 10.0];
    self.lblLocation.textColor = [UIColor whiteColor];
    
    if (![concertDic imageURL]) {
        self.imageArtist.image = [UIImage imageNamed:@"placeholder"];
    }
    else {
        __weak typeof(self) weakSelf = self;
        [self.imageArtist setImageWithURLRequest:[NSURLRequest requestWithURL:[concertDic imageURL]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            if (!image) {
                weakSelf.imageArtist.image = [UIImage imageNamed:@"placeholder"];
            }
            else weakSelf.imageArtist.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            weakSelf.imageArtist.image = [UIImage imageNamed:@"placeholder"];
        }];
    }

    
    
    self.imageArtist.layer.cornerRadius = 5.0;
    self.imageArtist.layer.masksToBounds = YES;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone; //TODO: custom selection style?
    self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory"]];
}

- (void)setUpCellImageForConcert:(UIImage *)image {
    self.imageArtist.image = image;
}

@end
