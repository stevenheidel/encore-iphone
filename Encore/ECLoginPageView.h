//
//  ECLoginPageView.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECLoginPageView : UIViewController {
    
    UIImageView *image;
    UILabel *lblHeader;
    UILabel *lblText;
    
}

@property (nonatomic, retain) IBOutlet UIImageView *image;
@property (nonatomic, retain) IBOutlet UILabel *lblHeader;
@property (nonatomic, retain) IBOutlet UILabel *lblText;

@end
