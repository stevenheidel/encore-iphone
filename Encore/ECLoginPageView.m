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
    }
    return self;
}

- (void)SetUpPageforItem:(NSDictionary *)currPageItem  {
    self.backgroundColor = [UIColor blackColor];
    
    [image setImage:[UIImage imageNamed:[currPageItem objectForKey:@"image"]]];
    CGFloat imageX = self.frame.size.width/2 - self.frame.size.width/2;
    CGFloat imageY = self.frame.size.height/2 - image.frame.size.height;
    [image setFrame:CGRectMake(imageX, imageY, image.frame.size.width, image.frame.size.height)];
    
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
