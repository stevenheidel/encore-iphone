//
//  UIImage+Merge.m
//  Encore
//
//  Created by Mohamed Fouad on 8/6/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "UIImage+Merge.h"

@implementation UIImage(Merge)

+ (UIImage*)mergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
    CGImageRef firstImageRef = firstImage.CGImage;
    CGFloat firstWidth = CGImageGetWidth(firstImageRef);
    CGFloat firstHeight = CGImageGetHeight(firstImageRef);
        
    UIGraphicsBeginImageContext(firstImage.size);
    
    [firstImage drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    [secondImage drawInRect:CGRectMake(0, 0, firstWidth, firstHeight)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
@end
