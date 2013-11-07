//
//  NSDictionary+ConcertList.m
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSDictionary+ConcertList.h"
#import <CoreLocation/CoreLocation.h>
static NSString * const kDateFormat = @"yyyy-MM-dd";

@implementation NSDictionary (ConcertList)
-(NSString *) niceDate {
    return [[self niceDateNotUppercase]uppercaseString];
}

-(NSString*) niceDateNotUppercase {
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:kDateFormat];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"MMMM d, yyyy"];
    return [dateFormat stringFromDate:date];
}
-(NSString*) smallDate
{
    NSString * dateStr = [self objectForKey:@"date"];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:kDateFormat];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    [dateFormat setDateFormat:@"MMM dd/yy"];
    return [dateFormat stringFromDate:date];

}

-(NSString *) eventName {
    return [self objectForKey:@"name"];
}

-(NSString*) venueName {
   return [self objectForKey:@"venue_name"];
}
-(NSDictionary*) venueDetails {
    return [self objectForKey:@"venue"];
}

-(NSString*) city {
    return  [[self venueDetails] objectForKey:@"city"];
}

-(NSString*) postalCode {
    return [[self venueDetails] objectForKey:@"postalcode"];
}

-(NSString*) street {
    return  [[self venueDetails] objectForKey:@"street"];
}

-(NSString*) country {
    return [[self venueDetails] objectForKey:@"country"];
}
-(NSString *) address
{
    NSMutableArray* address = [[NSMutableArray alloc] init];
    [address addObject:[self street]];
    [address addObject:[self city]];
    [address addObject:[self country]];
    [address removeObject:@""];
    return [address componentsJoinedByString:@", "];
}
-(NSString *) addressWithoutCountry
{
    NSMutableArray* address = [[NSMutableArray alloc] init];
    [address addObject:[self street]];
    [address addObject:[self city]];
    [address removeObject:@""];
    return [address componentsJoinedByString:@", "];
}

-(NSString*) startTime {
    NSString* time = [self objectForKey:@"start_time"];
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"EE, d MMM yyyy HH:mm:ss"];
    NSDate* date = [formatter dateFromString:time];
    NSDateFormatter* formatter2 = [NSDateFormatter new];
    formatter2.timeStyle = NSDateFormatterShortStyle;
    time = [formatter2 stringFromDate:date];
    return time;
}

-(CLLocation*) coordinates {
    NSDictionary* venueDeets = [self venueDetails];
    double latitude = [(NSString*)[venueDeets objectForKey:@"latitude"] doubleValue];
    double longitude = [(NSString*)[venueDeets objectForKey:@"longitude"] doubleValue];
    return [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
}
-(NSString*) venueAndDate {
    return [NSString stringWithFormat:@"%@, %@", [self venueName], [[self niceDate] capitalizedString]];
}
-(NSString*) serverID {
    return [self eventID];
}

-(NSString*) eventID {
    return [self objectForKey:@"lastfm_id"];
}

-(NSURL *) imageURL {
    NSString *url = [self objectForKey:@"image_url"];
    if (![url isKindOfClass:[NSNull class]] && url.length > 0) {
        return [NSURL URLWithString:url];
    } else {
        return nil;
    }
}

-(NSURL *) lastfmURL {
    NSString* lastfmURL = [self objectForKey:@"lastfm_url"];
    
    if (lastfmURL != (id)[NSNull null]) {
        return [NSURL URLWithString:lastfmURL];
    }
    return nil;
}

-(NSURL *) ticketsURL {
    NSString* ticketsURLString = [self objectForKey:@"tickets_url"];
    if (ticketsURLString != (id)[NSNull null]) {
        return [NSURL URLWithString: ticketsURLString];
    }
    return [self lastfmURL];
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
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:kDateFormat];
    NSDate* date = [formatter dateFromString:dateStr];
    unsigned int unitFlags =  NSDayCalendarUnit;
    NSDateComponents* breakdownInfo = [[NSCalendar currentCalendar] components: unitFlags fromDate:date];
    return [NSString stringWithFormat:@"%d",[breakdownInfo day]];
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

-(NSString *) headliner
{
    return  [self objectForKey:@"headliner"];
}
-(NSArray *) artists
{
    NSMutableArray* artists =[[NSMutableArray alloc] initWithCapacity:[[self objectForKey:@"artists"] count]];
    
    for( NSDictionary* artist in[self objectForKey:@"artists"])
    {
        if(![[artist objectForKey:@"artist"] isEqualToString:[self headliner]]) //remove headliner
            [artists addObject:[artist objectForKey:@"artist"]];
    }
    return  [NSArray arrayWithArray:artists];;
}
-(NSArray*)lineup
{
    
    return  [self objectForKey:@"artists"];
 
}
@end
