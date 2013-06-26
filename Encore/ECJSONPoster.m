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
#import "UIImage+Orientation.h"
#import "EncoreURL.h"

@implementation ECJSONPoster
+(void) postUser:(NSDictionary <FBGraphUser>*) user {
    NSString * facebookID = user.id;
    NSString * name = user.name;
    
    NSString * oauth = FBSession.activeSession.accessTokenData.accessToken;
    NSDate * expiryDate = FBSession.activeSession.accessTokenData.expirationDate;
    NSString * jsonExpiryDateString = [expiryDate jsonString];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:oauth, @"oauth",jsonExpiryDateString,@"expiration_date",facebookID, @"facebook_id",name,@"name",nil];
    
    NSURL * url = [NSURL URLWithString:BaseURL];
    
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:UsersURL parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"%@: %@",NSStringFromClass([self class]),[responseObject description]);
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"ERROR: %@",[error description]);
             }];
}

+(void) addConcert: (NSNumber *) concertID toUser: (NSString *) userID completion: (void (^)()) completion{
    //POST /users/:uuid/concerts     {'songkick_id': '1234578'}
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@",UsersURL,userID,ConcertsURL];
    NSDictionary * parameters = [NSDictionary dictionaryWithObject:[concertID stringValue] forKey:SongkickIDURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

    [client postPath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@: Success adding concert %@ to profile %@. Response: %@", NSStringFromClass([self class]),concertID,userID, [responseObject description]);
        if (completion) {
            completion();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR removing concert %@ from profile %@: %@",NSStringFromClass([self class]), concertID.stringValue, userID,[error description]);
    }];
}

+(void) removeConcert: (NSNumber *) concertID toUser: (NSString *) userID completion: (void (^)()) completion{
    //POST /users/:uuid/concerts
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@",UsersURL,userID,ConcertsURL,concertID.stringValue];
    NSDictionary * parameters = [NSDictionary dictionaryWithObject:[concertID stringValue] forKey:@"songkick_id"];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client deletePath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@: Success removing concert %@ from profile %@. Response: %@", NSStringFromClass([self class]),concertID.stringValue,userID,[responseObject description]);
        if (completion) {
            completion();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR removing concert %@ from profile %@: %@",NSStringFromClass([self class]), concertID.stringValue, userID,[error description]);
    }];
    
}

//Expect nsdictionary with image, concert, and user
+(void) postImage:(NSDictionary*)imageDic completion:(void (^)())completion {
    //POST /concerts/:id/posts
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@",ConcertsURL,[imageDic objectForKey:@"concert"],PostsURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

    NSData* imageData = UIImagePNGRepresentation([(UIImage*)[imageDic objectForKey:@"image"] fixOrientation]);
    NSMutableURLRequest * request = [client multipartFormRequestWithMethod:@"POST" path:urlString parameters:imageDic constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: imageData name:@"image" fileName:@"image.png" mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"fail");
    }];
    [operation start];
}
@end
