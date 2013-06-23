//
//  ECConcertCellView.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-23.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONCERT_CELL_HEIGHT 134.0

@interface ECConcertCellView : UITableViewCell

+ (NSString *)reuseIdentifier;
- (NSString *)reuseIdentifier;
+ (ECConcertCellView *)cell;

@property(nonatomic, strong) IBOutlet UIImageView *imageArtist;
@property(nonatomic, strong) IBOutlet UIImageView *imageBackground;
@property(nonatomic, strong) IBOutlet UILabel *lblDate;
@property(nonatomic, strong) IBOutlet UILabel *lblName;
@property(nonatomic, strong) IBOutlet UILabel *lblLocation;



@end
