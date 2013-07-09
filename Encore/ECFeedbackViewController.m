//
//  ECFeedbackViewController.m
//  Encore
//
//  Created by Shimmy on 2013-07-03.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECFeedbackViewController.h"
#import "TestFlight.h"
@interface ECFeedbackViewController ()

@end

@implementation ECFeedbackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        didEdit = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.text = NSLocalizedString(@"Feedback_Placeholder", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
    [Flurry logEvent:@"Canceled_Feedback"];
}

- (IBAction)send {
    BOOL textLengthNotZero = self.textView.text.length > 0;
    if (textLengthNotZero && didEdit) {
        [TestFlight submitFeedback:self.textView.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (textLengthNotZero && didEdit) {
            [self.delegate feedbackSent];
            [Flurry logEvent:@"Sent_Feedback" withParameters:[NSDictionary dictionaryWithObject:self.textView.text forKey:@"feedback"]];
        }
    }];

}
-(void) textViewDidBeginEditing:(UITextView *)textView {
    self.textView.text = @"";
    didEdit = YES;
}

@end
