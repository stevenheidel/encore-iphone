//
//  NSDate+JSON.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSDate+JSON.h"
#define JSON_DATE_FORMAT @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
@implementation NSDate (JSON)

-(NSString*) jsonString {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:JSON_DATE_FORMAT];
    
    return [dateFormat stringFromDate:self];
}

@end
