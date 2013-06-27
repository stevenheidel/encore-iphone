//
//  ECConcertCellView.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-23.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONCERT_CELL_HEIGHT 90.0

@interface ECConcertCellView : UITableViewCell

- (void)setUpCellImageForConcert:(UIImage *)image;
- (void)setUpCellForConcert:(NSDictionary *)concertDic;

@property(nonatomic, strong) IBOutlet UIImageView *imageArtist;
@property(nonatomic, strong) IBOutlet UILabel *lblDate;
@property(nonatomic, strong) IBOutlet UILabel *lblName;
@property(nonatomic, strong) IBOutlet UILabel *lblLocation;



@end
