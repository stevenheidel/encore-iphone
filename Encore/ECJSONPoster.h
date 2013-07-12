//
//  ECJSONPoster.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol FBGraphUser;
@interface ECJSONPoster : NSObject
+(void) postUser:(NSDictionary<FBGraphUser> *)user completion: (void (^)(NSDictionary* response)) completion;

+(void) addConcert: (NSString *) concertID toUser: (NSString *) userID completion: (void (^)()) completion;
+(void) removeConcert: (NSString *) concertID toUser: (NSString *) userID completion: (void (^)()) completion;

+(void) postImage:(NSDictionary*)imageDic completion:(void (^)())completion;

+(void) flagPost:(NSString *)postID withFlag:(NSString *)flag completion:(void (^)(BOOL success))completion;

@end
