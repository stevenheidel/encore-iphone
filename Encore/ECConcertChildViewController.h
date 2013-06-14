//
//  ECConcertChildViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-14.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECConcertChildViewController : UIViewController
-(void) updateView;
@property (nonatomic,strong) IBOutlet UILabel * artistLabel;
@property (nonatomic,strong) NSDictionary * concert;
@end
