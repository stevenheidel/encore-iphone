//
//  ECYouTubeViewController.h
//  Encore
//
//  Created by Shimmy on 2013-07-21.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECYouTubeViewController : UIViewController
-(id) initWithLink: (NSURL*) link;
@property (weak, nonatomic) IBOutlet UIWebView *youTubeWebView;
@property (nonatomic, copy) NSURL* link;
@end
