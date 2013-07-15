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
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ECLoginPageView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        [self addSubview:mainView];
        image.translatesAutoresizingMaskIntoConstraints = NO;
        lblHeader.translatesAutoresizingMaskIntoConstraints = NO;
        lblText.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

NSString* iPhone4() {
    if ([[UIScreen mainScreen] bounds].size.height != 568)
    {
        return @"iphone4";
    }
    return @"";
}
- (void)SetUpPageforItem:(NSDictionary *)currPageItem  {
    
    NSString* imagePath = [NSString stringWithFormat:@"%@%@",[currPageItem objectForKey:@"image"],iPhone4()];
    [image setImage:[UIImage imageNamed:imagePath]];
//    CGFloat imageX = self.frame.size.width/2 - self.frame.size.width/2;
//    CGFloat imageY = self.frame.size.height/2 - image.frame.size.height;
//    [image setFrame:CGRectMake(0, 0, image.frame.size.width, image.frame.size.height)];
    [image setBounds:CGRectMake(0, 0, 320, 50)];
    self.lblHeader.backgroundColor = self.backgroundColor;
    self.lblHeader.textColor = [UIColor whiteColor];
    self.lblHeader.text = [currPageItem objectForKey:@"header"];
    self.lblHeader.textAlignment = NSTextAlignmentCenter;
    
    self.lblText.backgroundColor = self.backgroundColor;
    self.lblText.textColor = [UIColor whiteColor];
    UIFont *font = self.lblText.font;
    for(int i = 14; i > 10; i--)
    {
        // Set the new font size.
        font = [self.lblText.font fontWithSize:i];
        CGSize constraintSize = CGSizeMake(260.0f, MAXFLOAT);
        CGSize labelSize = [[currPageItem objectForKey:@"text"] sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        if(labelSize.height <= 50.0f)
            break;
    }
    self.lblText.text = [currPageItem objectForKey:@"text"];
    self.lblText.textAlignment = NSTextAlignmentCenter;
    self.lblText.numberOfLines = 0;
    self.lblText.font = font;
    //lblText.minimumScaleFactor = 0.1f;
    self.lblText.adjustsFontSizeToFitWidth = YES;
}

@end
