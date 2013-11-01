//
//  ECLoginViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-10.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ECLoginViewController : UIViewController{
    NSArray *arrPages;
}
- (void)loginFailed;
@property (weak, nonatomic) IBOutlet UILabel *lblWarning;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@end
