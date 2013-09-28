//
//  UIColor+EncoreUI.m
//  Encore
//
//  Created by Shimmy on 2013-06-30.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "UIColor+EncoreUI.h"

@implementation UIColor (EncoreUI)
UIColor* colorWithRGB(float red, float green, float blue, float alpha) {
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

UIColor* colorWithHSB(float hue, float saturation, float brightness, float alpha) {
    return [UIColor colorWithHue:hue/360.0 saturation:saturation brightness:brightness alpha:alpha];
}

+(UIColor*) lightGrayTableColor {
    return colorWithRGB(246.0f,248.0f,250.0f,1.0f);
}

+(UIColor*) lightGrayHeaderColor {
    return colorWithRGB(225.0f,224.0f,225.0f,1.0);
}

+(UIColor*) encoreDarkGreenColorWithAlpha: (CGFloat) alpha {
    return colorWithRGB(8.0f,56.0f,76.0f,alpha);
}

+(UIColor*) encoreDarkGreenColor {
    return [UIColor encoreDarkGreenColorWithAlpha:1.0];
}

+(UIColor*) darkTextColorWithAlpha: (CGFloat) alpha {
   return colorWithRGB(28.0f,29.0f,31.0f,alpha);
}

+(UIColor*) imageBorderColor {
    return colorWithRGB(135.0f, 206.0f, 235.0f, 1.0f); // color equivalent is #87ceeb
}
+(UIColor*) profileImageBorderColor {
    return colorWithRGB(160.0f,165.0f,170.0f,1.0);
}

#pragma mark - HUD
+(UIColor*) lightBlueHUDConfirmationColor {
    return colorWithRGB(0.0f,176.0f,227.0f,0.90);
}

+(UIColor*) redHUDConfirmationColor {
    return colorWithRGB(255.0f,51.0f,51.0f,0.90f);
}

#pragma mark - Horizontal select
+(UIColor*) horizontalSelectTextColor {
    return colorWithRGB(160.0f, 164.0f, 167.0f, 1.0f);
}

+(UIColor*) horizontalSelectTodayCellColor {
    return colorWithRGB(0.0f, 176.0f, 227.0f, 1.0f);
}

+(UIColor*) horizontalSelectGrayCellColor {
    return colorWithRGB(246.0f,248.0f,250.0f,1.0f);
}
+(UIColor*) unselectedSegmentedControlColor {
    return colorWithRGB(255.0f, 255.0f, 255.0f, 0.5f);
}
#pragma mark - Nav bar
+(UIColor*) lightBlueNavBarColor {
    return colorWithHSB(193.0f, 0.99f, 0.8f, 0.8f); 
}

+(UIColor*) lightBlueNavBarEndColor {
    return  colorWithHSB(184.0f, 0.98f, 0.78f, 0.5f);
}

+(UIColor*) blueArtistTextColor {
    return colorWithRGB(3.0f, 176.0f, 227.0f, 1.0f);
}

+(UIColor*) separatorColor {
    return colorWithRGB(255.0f, 255.0f, 255.0f, 0.2f);
}

#pragma mark - Events
+(UIColor*) eventRowBackgroundColor {
    return colorWithRGB(0.0f, 0.0f, 0.0f, 0.6f);
}
@end
