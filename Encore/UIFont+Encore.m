//
//  UIFont+Encore.m
//  Encore
//
//  Created by Shimmy on 2013-07-01.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "UIFont+Encore.h"

@implementation UIFont (Encore)
+(UIFont*) heroFontWithSize: (CGFloat) size  {
    return [UIFont fontWithName:@"Hero" size:size];
}

+(UIFont*) lightHeroFontWithSize:(CGFloat)size {
    return [UIFont fontWithName:@"Hero Light" size:size];
}

@end
