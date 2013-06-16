//
//  ECEndCellView.m
//  Encore
//
//  Created by Shimmy on 2013-06-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECEndCellView.h"

@implementation ECEndCellView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECEndCellView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
    }
    return self;
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
