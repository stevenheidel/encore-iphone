//
//  NSDictionary+ConcertList.h
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CLLocation;
@interface NSDictionary (ConcertList)

-(NSString *) niceDate;
-(NSString*) niceDateNotUppercase;

-(NSString *) eventName;
-(NSString *) venueName;
-(NSString*) venueAndDate; //string with both, separated by comma
-(NSString*) startTime;

-(NSString *) serverID;
-(NSString*) eventID;

-(NSURL *) backgroundURL;
-(NSURL *) imageURL;
-(NSURL *) lastfmURL;
-(NSURL *) ticketsURL;

-(NSString *) month;
-(NSString *) day;
-(NSString *) weekday;
-(NSString *) year;

-(NSArray *) past;
-(NSArray *) future;

-(BOOL) isLive;
-(BOOL) beforeToday;

-(CLLocation*) coordinates;
-(NSString*) country;
-(NSString*) street;
-(NSString*) postalCode;
-(NSString*) city;
-(NSDictionary*) venueDetails;
-(NSString *) address;
-(NSString *) addressWithoutCountry;

-(NSString *) headliner;
-(NSArray *) artists;
-(NSArray *) lineup;

@end
