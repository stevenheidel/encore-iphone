//
//  UIColor+EncoreUI.m
//  Encore
//
//  Created by Shimmy on 2013-06-30.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "UIColor+EncoreUI.h"

@implementation UIColor (EncoreUI)
+(UIColor*) lightGrayTableColor {
    return [UIColor colorWithRed:246.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
}

+(UIColor*) lightGrayHeaderColor {
    return [UIColor colorWithRed:225.0/255.0 green:224.0/255.0 blue:225.0/255.0 alpha:1.0];
}

+(UIColor*) encoreDarkGreenColorWithAlpha: (CGFloat) alpha {
    return [UIColor colorWithRed:8.0/255.0 green:56.0/255.0 blue:76.0/255.0 alpha:alpha];
}

+(UIColor*) encoreDarkGreenColor {
    return [UIColor encoreDarkGreenColorWithAlpha:1.0];
}

+(UIColor*) darkTextColorWithAlpha: (CGFloat) alpha {
   return [UIColor colorWithRed:28.0/255.0 green:29.0/255.0 blue:31.0/255.0 alpha:alpha];
}

+(UIColor*) imageBorderColor {
    return [UIColor colorWithRed:0.529 green:0.808 blue:0.922 alpha:1]; // color equivalent is #87ceeb
}
+(UIColor*) profileImageBorderColor {
    return [UIColor colorWithRed:160.0/255.0 green:165.0/255.0 blue:170.0/255.0 alpha:1.0];
}


#pragma mark - HUD
+(UIColor*) lightBlueHUDConfirmationColor {
    return [UIColor colorWithRed:0.0/255.0 green:176.0/255.0 blue:227.0/255.0 alpha:0.90];
}

+(UIColor*) redHUDConfirmationColor {
    return [UIColor colorWithRed:255.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:0.90];
}

#pragma mark - Horizontal select
+(UIColor*) horizontalSelectTextColor {
    return [UIColor colorWithRed:160.0/255.0 green:164.0/255.0 blue:167.0/255.0 alpha:1.0];
}

+(UIColor*) horizontalSelectTodayCellColor {
    return [UIColor colorWithRed:0.0 green:176.0/255.0 blue:227.0/255.0 alpha:1.0];
}

+(UIColor*) horizontalSelectGrayCellColor {
    return [UIColor colorWithRed:246.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
}
@end
