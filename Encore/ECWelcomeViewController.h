//
//  ECWelcomeViewController.h
//  Encore
//
//  Created by Mohamed Fouad on 9/17/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECWelcomeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblPickConcert;
@property (weak, nonatomic) IBOutlet UILabel *lblWelcomeTo;
@property (weak, nonatomic) IBOutlet UITableView *featuredTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
- (IBAction)nextButtonTapped:(id)sender;

@end
