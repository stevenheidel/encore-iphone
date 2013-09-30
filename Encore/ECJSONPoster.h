//
//  ECJSONPoster.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
//@protocol FBGraphUser;
@interface ECJSONPoster : NSObject
+(void) postUser:(NSDictionary/*<FBGraphUser>*/ *)user completion: (void (^)(NSDictionary* response)) completion;

+(void) addConcert: (NSString *) concertID toUser: (NSString *) userID completion: (void (^)(BOOL success)) completion;
+(void) removeConcert: (NSString *) concertID toUser: (NSString *) userID completion: (void (^)(BOOL success)) completion;

+(void) postImage:(NSDictionary*)imageDic completion:(void (^)())completion;

+(void) flagPost:(NSString *)postID withFlag:(NSString *)flag fromUser: (NSString*) userID completion:(void (^)(BOOL success))completion;

+(void) populateConcert: (NSString*) eventID completion: (void(^)(BOOL success)) completion;


+(void) addFriends: (NSArray*) friends
            ofUser: (NSString*) userID
           toEvent: (NSString*) eventID
        completion: (void(^)(NSArray* friends)) completion;

@end
