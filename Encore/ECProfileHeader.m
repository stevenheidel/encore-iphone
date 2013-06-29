//
//  ECProfileHeader.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-29.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECProfileHeader.h"

@implementation ECProfileHeader

- (id)initWithFrame:(CGRect)frame andOwner: (id) owner
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECProfileHeader" owner:owner options:nil];
        self = [subviewArray objectAtIndex:0];
        self.frame = frame;
        
    }
    return self;
}

@end
