//
//  ECPictureViewController.h
//  Encore
//  Display image selected by photo picker (app doesn't use this right now)
//  Created by Shimmy on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ECPictureViewControllerDelegate;
@interface ECPictureViewController : UIViewController {
    UIImage* _image;
}
-(id) initWithImage: (UIImage*) image;
-(IBAction)cancel;
-(IBAction)post;
@property(nonatomic,strong) IBOutlet UIImageView* imageView;
@property (unsafe_unretained,nonatomic) id <ECPictureViewControllerDelegate> delegate;
@end

@protocol ECPictureViewControllerDelegate <NSObject>

@required
-(void) postImage: (UIImage*) image;

@end
