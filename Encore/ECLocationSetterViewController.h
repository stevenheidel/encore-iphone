//
//  ECLocationSetterViewController.h
//  Encore
//
//  Created by Shimmy on 2013-07-14.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECLocationSetterViewController : UIViewController <UITextFieldDelegate>
- (IBAction)touchedOutsideTextField:(id)sender;

@property (weak, nonatomic) IBOutlet UISlider *locationSlider;
@property (weak, nonatomic) IBOutlet UITextField *locationSearchBar;
@end
