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

-(void) postUserID: (NSString*) facebookID {
    NSString * oauth = FBSession.activeSession.accessTokenData.accessToken;
    NSDate * expiryDate = FBSession.activeSession.accessTokenData.expirationDate;
    NSString * jsonExpiryDateString = [expiryDate jsonString];
    
    NSString * baseURLString = NSLocalizedString(@"BaseURL",nil);
    NSString * usersURL = NSLocalizedString(@"UsersURL",nil );
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:oauth, @"oauth",jsonExpiryDateString,@"expiration_date",facebookID, @"facebook_id",nil];
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",baseURLString,usersURL]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];

    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

//    [client postPath: parameters:<#(NSDictionary *)#> success:<#^(AFHTTPRequestOperation *operation, id responseObject)success#> failure:<#^(AFHTTPRequestOperation *operation, NSError *error)failure#>]
}

@end
