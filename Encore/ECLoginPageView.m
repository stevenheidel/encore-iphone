//
//  ECLoginPageView.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-15.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECLoginPageView.h"

@interface ECLoginPageView ()
@end

@implementation ECLoginPageView

@synthesize image;
@synthesize lblHeader, lblText;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"ECLoginPageView%@",iPhone4()] owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
        image.translatesAutoresizingMaskIntoConstraints = NO;
        lblHeader.translatesAutoresizingMaskIntoConstraints = NO;
        lblText.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}
BOOL isiPhone4Screen() {
    return [[UIScreen mainScreen] bounds].size.height != 568;
}
NSString* iPhone4() {
    if (isiPhone4Screen()) {
        return @"iphone4";
    }
    return @"";
}
- (void)SetUpPageforItem:(NSDictionary *)currPageItem  {
    
    NSString* imagePath = [NSString stringWithFormat:@"%@%@",[currPageItem objectForKey:@"image"],iPhone4()];
    [image setImage:[UIImage imageNamed:imagePath]];
    self.lblHeader.text = [currPageItem objectForKey:@"header"];
    self.lblText.text = [currPageItem objectForKey:@"text"];
}

@end
