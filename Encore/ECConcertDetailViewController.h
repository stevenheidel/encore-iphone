//
//  ECConcertDetailViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECJSONFetcher.h"

@interface ECConcertDetailViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,ECJSONFetcherDelegate>

@property (nonatomic,strong) NSDictionary * concert;
@property (nonatomic,strong) IBOutlet UILabel * artistNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * venueNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * dateLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray * posts;

@end
