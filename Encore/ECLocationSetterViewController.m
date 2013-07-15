//
//  ECLocationSetterView.m
//  Encore
//
//  Created by Shimmy on 2013-07-14.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLocationSetterViewController.h"
#import "NSUserDefaults+Encore.h"

@implementation ECLocationSetterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    [self.locationSlider setThumbImage:[UIImage imageNamed:@"oval"] forState:UIControlStateNormal];
    [self.locationSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum"] forState:UIControlStateNormal];
    [self.locationSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum"] forState:UIControlStateNormal];
    self.locationSearchBar.text = [NSUserDefaults userCity];
    
}
-(IBAction) touchedOutsideTextField: (id) sender {
    [self.view endEditing:YES];
}
#define kOFFSET_FOR_KEYBOARD 200.0


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  
}

-(BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    [self resignFirstResponder];
    if ([textField isEqual:self.locationSearchBar])
    {
        //move the main view, so that the keyboard does not hide it.
        [self moveBack];
    }

    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {

    if ([textField isEqual:self.locationSearchBar])
    {
        [self moveUp];
    }
    return YES;
}

//- (NSInteger)getKeyBoardHeight:(NSNotification *)notification
//{
//    NSDictionary* keyboardInfo = [notification userInfo];
//    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
//    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
//    NSInteger keyboardHeight = keyboardFrameBeginRect.size.height;
//    return keyboardHeight;
//}


-(void) moveUp {
    [self setViewMovedUp:YES];
}

-(void) moveBack {
    [self setViewMovedUp:NO];
}
//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)viewWillAppear:(BOOL)animated
{
//    // register for keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    // unregister for keyboard notifications while not visible.
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
}

@end
