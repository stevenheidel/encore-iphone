//
//  ECChangeConcertStateButton.m
//  Encore
//
//  Created by Mohamed Fouad on 8/9/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECChangeConcertStateButton.h"

@implementation ECChangeConcertStateButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)toggleButtonState
{
    [self setButtonIsOnProfile:[self isSelected]];
}
-(void)setButtonIsOnProfile:(BOOL)isOnProfile
{
    if(isOnProfile)
    {
        [self setSelected:YES];
        [self setBackgroundColor:[UIColor colorWithRed:52.0/255.0 green:224.0/255.0 blue:193.0/255.0 alpha:1]];

    }else
    {
        [self setSelected:NO];
        [self setBackgroundColor:[UIColor grayColor]];

    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
