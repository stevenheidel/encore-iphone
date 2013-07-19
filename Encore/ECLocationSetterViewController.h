//
//  ECLocationSetterViewController.h
//  Encore
//
//  Created by Shimmy on 2013-07-14.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLLocation;
@protocol ECLocationSetterDelegate;
@interface ECLocationSetterViewController : UIViewController <UITextFieldDelegate,UIAlertViewDelegate>
- (IBAction)touchedOutsideTextField:(id)sender;

- (IBAction)infoButtonTapped;
@property (nonatomic, assign) float radius;
@property (nonatomic, strong) CLLocation* location;

@property (weak, nonatomic) IBOutlet UISlider *locationSlider;
@property (weak, nonatomic) IBOutlet UITextField *locationSearchBar;
@property (nonatomic, unsafe_unretained) id <ECLocationSetterDelegate> delegate;
@end

@protocol ECLocationSetterDelegate <NSObject>

@required
-(void) updateSearchLocation:(CLLocation *)location radius: (float) radius;

@end