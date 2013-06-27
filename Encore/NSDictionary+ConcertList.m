//
//  NSDictionary+ConcertList.m
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSDictionary+ConcertList.h"
static NSString * const kDateFormat = @"yyyy-MM-dd";

@implementation NSDictionary (ConcertList)
-(NSString *) niceDate {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:kDateFormat];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"MMMM d, yyyy"];
    return [[dateFormat stringFromDate:date] capitalizedString];
}

-(NSString *) artistName {
    return [self objectForKey:@"name"];
}

-(NSString*) venueName {
   return [self objectForKey:@"venue_name"];
}

-(NSNumber*) serverID {
    return [self songkickID];//[self objectForKey:@"server_id"];
}

-(NSNumber*) songkickID {
    return [self objectForKey:@"songkick_id"];
}

-(NSURL *) backgroundURL {
    return [NSURL URLWithString:[self objectForKey:@"background_url"]];
}

-(NSURL *) imageURL {
    return [NSURL URLWithString:[self objectForKey:@"image_url"] ];
}

-(NSString *) month {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter * dateFormat =  [NSDateFormatter new];
    [dateFormat setDateFormat:kDateFormat];
    NSDate * date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"MMM"]; //returns abbreviated month string e.g. Jan, Feb, Mar, etc.
    return [[dateFormat stringFromDate:date] uppercaseString];
}

-(NSString *) day {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter * dateFormat =  [NSDateFormatter new];
    [dateFormat setDateFormat:kDateFormat];
    NSDate * date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"dd"]; 
    return [dateFormat stringFromDate:date];
}

-(NSString *) weekday {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter * dateFormat =  [NSDateFormatter new];
    [dateFormat setDateFormat:kDateFormat];
    NSDate * date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"ccc"];
    return [[dateFormat stringFromDate:date] substringToIndex:3];
}

-(NSString *) year {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter * dateFormat =  [NSDateFormatter new];
    [dateFormat setDateFormat:kDateFormat];
    NSDate * date = [dateFormat dateFromString:dateStr];
    [dateFormat setDateFormat:@"yyyy"];
    return [dateFormat stringFromDate:date];
}

-(BOOL) isLive {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter * dateFormat =  [NSDateFormatter new];
    [dateFormat setDateFormat:kDateFormat];
    NSDate * date = [dateFormat dateFromString:dateStr];
    return [date isEqualToDate:[NSDate date]];
}

-(BOOL) beforeToday {
    NSLog(@"beforeToday doesn't work yet");
    //The date is stored without time and it's annoying to fix so left as is
    return FALSE;
}

#pragma mark -

-(NSArray *) past {
    return [self objectForKey:@"past"];
}

-(NSArray *) future {
    return [self objectForKey:@"future"];
}
@end
