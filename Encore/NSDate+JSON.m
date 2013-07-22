//
//  NSDate+JSON.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//  Convert an NSDate into a json friendly string

#import "NSDate+JSON.h"
@implementation NSDate (JSON)

-(NSString*) jsonString {
    return [self description]; //tried various things, but this ended up working fine. Probably should change
}

@end
