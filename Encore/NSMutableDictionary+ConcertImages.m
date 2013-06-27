//
//  NSMutableDictionary+ConcertImages.m
//  Encore
//
//  Created by Luis Ramirez on 2013-06-26.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSMutableDictionary+ConcertImages.h"

@implementation NSMutableDictionary (ConcertImages)

- (UIImage *)regularImage {
    return [self objectForKey:@"regImage"];
}

- (UIImage *)gaussImage {
    return [self objectForKey:@"gaussImage"];
}

- (void) addImages:(UIImage *)regImage :(UIImage *)gaussImage {
    [self setObject:regImage forKey:@"regImage"]; //crashed here a couple times, June 26
    [self setObject:gaussImage forKey:@"gaussImage"];
}

@end
