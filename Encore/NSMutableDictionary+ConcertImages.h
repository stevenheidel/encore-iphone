//
//  NSMutableDictionary+ConcertImages.h
//  Encore
//
//  Created by Luis Ramirez on 2013-06-26.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (ConcertImages)
- (UIImage *)regularImage;
- (UIImage *)gaussImage;
- (void) addImages:(UIImage *)regImage :(UIImage *)gaussImage;
@end
