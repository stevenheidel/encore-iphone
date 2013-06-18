//
//  ECJSONPoster.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECJSONPoster.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSDate+JSON.h"

@implementation ECJSONPoster
+(void) postUserID:(NSString*) facebookID {
    NSString * oauth = FBSession.activeSession.accessTokenData.accessToken;
    NSDate * expiryDate = FBSession.activeSession.accessTokenData.expirationDate;
    NSString * jsonExpiryDateString = [expiryDate jsonString];
    
    NSString * baseURLString = [NSString stringWithFormat:@"%@/",NSLocalizedString(@"BaseURL",nil)];
    NSString * usersURL = NSLocalizedString(@"UsersURL",nil );
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:oauth, @"oauth",jsonExpiryDateString,@"expiration_date",facebookID, @"facebook_id",nil];
    
    NSURL * url = [NSURL URLWithString:baseURLString];
    
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:usersURL parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"%@: %@",NSStringFromClass([self class]),[responseObject description]);
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"ERROR: %@",[error description]);
             }];
}


+(void) addConcert: (NSNumber *) concertID toUser: (NSString *) userID {

    NSString * baseURLString = [NSString stringWithFormat:@"%@/", NSLocalizedString(@"BaseURL", nil)];
    NSLog(@"%@", baseURLString);
    NSString * kUsers = NSLocalizedString(@"UsersURL", nil);
    NSString * kConcerts = NSLocalizedString(@"ConcertsURL", nil);
    
    //POST /users/:uuid/concerts     {'songkick_id': '1234578'}
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@",kUsers,userID,kConcerts];
    NSDictionary * parameters = [NSDictionary dictionaryWithObject:[concertID stringValue] forKey:@"songkick_id"];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@: Success adding to profile %@", NSStringFromClass([self class]),[responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR: %@",[error description]);
    }];
}
@end
