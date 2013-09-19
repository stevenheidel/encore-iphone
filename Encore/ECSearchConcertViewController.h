//
//  ECSearchConcertViewController.h
//  Encore
//
//  Created by Mohamed Fouad on 9/18/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECSearchConcertViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *searchbar;
@property (weak, nonatomic) IBOutlet UILabel *lblSearchConcert;
- (IBAction)dismissKeyboard:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end
