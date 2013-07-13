//
//  NSDictionary+ConcertList.h
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ConcertList)

-(NSString *) niceDate;
-(NSString *) artistName;
-(NSString *) venueName;

-(NSString *) serverID;
-(NSString*) eventID;

-(NSURL *) backgroundURL;
-(NSURL *) imageURL;

-(NSString *) month;
-(NSString *) day;
-(NSString *) weekday;
-(NSString *) year;

-(NSArray *) past;
-(NSArray *) future;

-(BOOL) isLive;
-(BOOL) beforeToday;
@end
