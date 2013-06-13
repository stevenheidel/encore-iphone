//
//  NSDate+JSON.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSDate+JSON.h"
@implementation NSDate (JSON)

-(NSString*) jsonString {
    return [self description];
}

@end
