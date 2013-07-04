//
//  ECFeedbackViewController.h
//  Encore
//
//  Created by Shimmy on 2013-07-03.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ECFeedbackViewControllerDelegate;
@interface ECFeedbackViewController : UIViewController <UITextViewDelegate> {
    BOOL didEdit;
}

- (IBAction)cancel;
- (IBAction)send;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, unsafe_unretained) id <ECFeedbackViewControllerDelegate> delegate;
@end
@protocol ECFeedbackViewControllerDelegate <NSObject>

@optional
-(void) feedbackSent;

@end