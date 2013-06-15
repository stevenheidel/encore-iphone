//
//  ECLoginViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ECLoginViewController : UIViewController<FBLoginViewDelegate, UIScrollViewDelegate>{
    UIScrollView *descScrollView;
    UIPageControl *pageControl;
    NSArray *arrPages;
}

@property (nonatomic, retain) IBOutlet UIScrollView *descScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (unsafe_unretained, nonatomic) IBOutlet FBLoginView *FBLoginView;

- (IBAction)changePage;

@end
