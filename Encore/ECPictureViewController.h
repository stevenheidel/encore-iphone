//
//  ECPictureViewController.h
//  Encore
//  Display image selected by photo picker
//  Created by Shimmy on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECPictureViewController : UIViewController
@property(nonatomic,strong) IBOutlet UIImageView* imageView;

-(IBAction)cancel;
-(IBAction)confirm;

@end
