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

NSString* baseURL(){
    return NSLocalizedString(@"BaseURL", nil);
}

@implementation ECJSONPoster
+(void) postUser:(NSDictionary <FBGraphUser>*) user {
    NSString * kUsers = NSLocalizedString(@"UsersURL", nil);
    NSString * baseURLString = baseURL();
    NSString * facebookID = user.id;
    NSString * name = user.name;
    
    NSString * oauth = FBSession.activeSession.accessTokenData.accessToken;
    NSDate * expiryDate = FBSession.activeSession.accessTokenData.expirationDate;
    NSString * jsonExpiryDateString = [expiryDate jsonString];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:oauth, @"oauth",jsonExpiryDateString,@"expiration_date",facebookID, @"facebook_id",name,@"name",nil];
    
    NSURL * url = [NSURL URLWithString:baseURLString];
    
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:kUsers parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"%@: %@",NSStringFromClass([self class]),[responseObject description]);
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"ERROR: %@",[error description]);
             }];
}

+(void) addConcert: (NSNumber *) concertID toUser: (NSString *) userID completion: (void (^)()) completion{
    NSString * kUsers = NSLocalizedString(@"UsersURL", nil);
    NSString * kConcerts = NSLocalizedString(@"ConcertsURL", nil);
    NSString * baseURLString = baseURL();
    //POST /users/:uuid/concerts     {'songkick_id': '1234578'}
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@",kUsers,userID,kConcerts];
    NSDictionary * parameters = [NSDictionary dictionaryWithObject:[concertID stringValue] forKey:@"songkick_id"];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    
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
    NSString * kUsers = NSLocalizedString(@"UsersURL", nil);
    NSString * kConcerts = NSLocalizedString(@"ConcertsURL", nil);
    NSString * baseURLString = baseURL();
    
    //POST /users/:uuid/concerts
    NSString * urlString = [NSString stringWithFormat:@"%@/%@/%@/%@",kUsers,userID,kConcerts,concertID.stringValue];
    NSDictionary * parameters = [NSDictionary dictionaryWithObject:[concertID stringValue] forKey:@"songkick_id"];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    
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
    NSString * baseURLString = baseURL();
    NSString * kConcerts = NSLocalizedString(@"ConcertsURL", nil);
    NSString* kPosts = NSLocalizedString(@"PostsURL", nil);
    
    //POST /concerts/:id/posts
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/%@",kConcerts,[imageDic objectForKey:@"concert"],kPosts];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
//    [client postPath:urlString parameters:imageDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@: Success posting %@", NSStringFromClass([self class]),[responseObject description]);
//        if (completion) {
//            completion();
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@: ERROR posting image. %@",NSStringFromClass([self class]),[error description]);
//    }];
    
    NSData* imageData = UIImagePNGRepresentation([imageDic objectForKey:@"image"]);
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
