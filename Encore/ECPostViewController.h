//
//  ECViewController.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECPostViewController : UIViewController

@property (nonatomic,strong) NSDictionary * post;
@property (nonatomic,strong) IBOutlet UIImageView * postImage;
@property (nonatomic,strong) IBOutlet UIImageView * profilePicture;
@property (nonatomic,strong) IBOutlet UILabel * captionLabel;
@property (nonatomic,strong) IBOutlet UILabel * userNameLabel;

@end
