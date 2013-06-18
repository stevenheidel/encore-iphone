//
//  ECJSONPoster.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECJSONPoster : NSObject
+(void) postUserID:(NSString*) facebookID;
+(void) addConcert: (NSNumber *) concertID toUser: (NSString *) userID completion: (void (^)()) completion;
+(void) removeConcert: (NSNumber *) concertID toUser: (NSString *) userID completion: (void (^)()) completion;
@end
