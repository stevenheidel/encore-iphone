//
//  ECPictureViewController.m
//  Encore
//
//  Created by Shimmy on 2013-06-28.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECPictureViewController.h"

@interface ECPictureViewController ()

@end

@implementation ECPictureViewController
-(id) initWithImage:(UIImage *)image {
    if (self = [super initWithNibName:@"ECPictureViewController" bundle:[NSBundle mainBundle]]){
        _image = image;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = _image;
    // Do any additional setup after loading the view from its nib.
}

-(BOOL)shouldAutorotate{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions
-(IBAction) cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction) post {
    [self.delegate postImage: _image];
}

@end
