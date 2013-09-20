//
//  ECNextConcertViewController.h
//  Encore
//
//  Created by Mohamed Fouad on 9/19/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ECNextConcertViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblNextConcert;
- (IBAction)skipButtonTapped:(id)sender;

@end
