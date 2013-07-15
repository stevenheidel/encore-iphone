//
//  ECPostCollectionHeaderView.m
//  Encore
//
//  Created by Shimmy on 2013-06-27.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECPostCollectionHeaderView.h"

@implementation ECPostCollectionHeaderView

- (id)initWithFrame:(CGRect)frame andOwner: (id) owner
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECPostCollectionHeaderView" owner:owner options:nil];
        self = [subviewArray objectAtIndex:0];
        self.frame = frame;
        
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
