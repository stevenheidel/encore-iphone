//
//  UIColor+EncoreUI.h
//  Encore
//
//  Created by Shimmy on 2013-06-30.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (EncoreUI)

+(UIColor*) separatorColor;

+(UIColor*) blueArtistTextColor;
+(UIColor *) lightGrayTableColor;

+(UIColor *) lightGrayHeaderColor;

+(UIColor*) encoreDarkGreenColorWithAlpha: (CGFloat) alpha;

+(UIColor*) encoreDarkGreenColor;

+(UIColor*) darkTextColorWithAlpha: (CGFloat) alpha;

+(UIColor*) imageBorderColor;

+(UIColor*) profileImageBorderColor;
+(UIColor*) unselectedSegmentedControlColor;

//HUDs
+(UIColor*) lightBlueHUDConfirmationColor;
+(UIColor*) redHUDConfirmationColor;

//Horizontal select
+(UIColor*) horizontalSelectTextColor;
+(UIColor*) horizontalSelectGrayCellColor;
+(UIColor*) horizontalSelectTodayCellColor;

//navbar
+(UIColor*) lightBlueNavBarColor;
+(UIColor*) lightBlueNavBarEndColor;

//events
+(UIColor*) eventRowBackgroundColor;
@end
