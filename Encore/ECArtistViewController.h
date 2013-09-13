//
//  ECArtistViewController.h
//  Encore
//
//  Created by Shimmy on 2013-08-05.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECArtistViewController : UITableViewController

@property (nonatomic,strong) NSString* artist;
@property (nonatomic,strong) NSDictionary* events;
@property (nonatomic, readonly) NSArray* pastEvents;
@property (nonatomic, readonly) NSArray* upcomingEvents;
@property (weak,nonatomic) IBOutlet UIImageView* artistImageView;
@property (weak,nonatomic) UIImage* artistImage;
@property (weak,nonatomic) IBOutlet UILabel* artistNameLabel;

@end
