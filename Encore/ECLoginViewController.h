//
//  ECLoginViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ECLoginViewController : UIViewController<UIScrollViewDelegate>{
    NSArray *arrPages;
}
- (void)loginFailed;
@property (nonatomic, retain) IBOutlet UIScrollView *descScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;

- (IBAction)changePage: (id) sender;

@end
