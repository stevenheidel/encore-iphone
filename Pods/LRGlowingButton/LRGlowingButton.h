//
//  LRGlowingButton.h
//
//  Created by Nikita Lutsenko on 3/13/13.
//  Copyright (c) 2013 lightroomapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PULSE_DELAY 3.0
@interface LRGlowingButton : UIButton

@property (nonatomic,assign) BOOL glowsWhenHighlighted;
@property (nonatomic,retain) UIColor *highlightedGlowColor;
-(void) startPulse;
@end
