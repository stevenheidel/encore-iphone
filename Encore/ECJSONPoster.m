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
#import "AFNetworking.h"
#import "ECAppDelegate.h"
#import "ECFacebookManger.h"

#import "ECConstKeys.h"

@implementation ECJSONPoster

+(int) ageFromFBBdayString: (NSString*) bday {
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"mm/dd/yyyy"];
    NSDate* date = [formatter dateFromString:bday];
    NSDate* today = [NSDate date];
    unsigned int unitFlags =  NSYearCalendarUnit;
    NSDateComponents* breakdownInfo = [[NSCalendar currentCalendar] components: unitFlags fromDate:date toDate:today options:0];
//    NSLog(@"%d", [breakdownInfo year]);
    return (int)[breakdownInfo year];
}

+(void) postUser:(NSDictionary/*<FBGraphUser>*/ *)user completion: (void (^)(NSDictionary* response)) completion {
    NSString * facebookID = [user objectForKey: @"id"];
    NSString * name = [user objectForKey: @"name"];
    
    NSString * oauth = [ECFacebookManger sharedFacebookManger].accessToken; //FBSession.activeSession.accessTokenData.accessToken;
    NSDate * expiryDate = [ECFacebookManger sharedFacebookManger].expirationDate; //FBSession.activeSession.accessTokenData.expirationDate;
    NSString * jsonExpiryDateString = [expiryDate jsonString];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:oauth, @"oauth",jsonExpiryDateString,@"expiration_date",facebookID, @"facebook_id",name,@"name",nil];
    
    NSURL * url = [NSURL URLWithString:BaseURL];
    
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:@"users" parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"%@: Successfully posted user %@",NSStringFromClass([self class]),facebookID);
                 NSDictionary *userDic = [responseObject objectForKey:@"user"];
                 
                 if (completion) {
                     completion(userDic);
                 }
     
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"ERROR posting user %@: %@...",facebookID,[[error description] substringToIndex:MAX_ERROR_LEN]);
                 if(completion) {
                     completion(nil);
                 }
             }];
    [Flurry setUserID:facebookID];
    NSString* bday = [user objectForKey:@"birthday"];
    int age = 0;
    if (bday) {
        age = [ECJSONPoster ageFromFBBdayString:bday];
    }
    [Flurry setAge:age];
    
    [Flurry setGender:[[user objectForKey:@"gender"] substringToIndex:1]];
}

+(void) addConcert: (NSString *) concertID toUser: (NSString *) userID completion: (void (^)(BOOL success)) completion{
    //POST /users/:uuid/concerts
    NSString * urlString = [NSString stringWithFormat:AddConcertToUserURL,userID];
    NSDictionary * parameters = [NSDictionary dictionaryWithObject:concertID forKey:KeyLastFMId];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    [client postPath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@: Success adding concert %@ to profile %@. Response: %@", NSStringFromClass([self class]),concertID,userID, [responseObject description]);
        BOOL response = [[responseObject objectForKey:@"response"] isEqualToString:@"success"];
        if (completion) {
            completion(response);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR removing concert %@ from profile %@: %@...",NSStringFromClass([self class]), concertID, userID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(FALSE);
        }   
    }];
}

+(void) removeConcert: (NSString *) concertID toUser: (NSString *) userID completion: (void (^)(BOOL success)) completion{
    //POST /users/:uuid/concerts
    NSString * urlString = [NSString stringWithFormat:RemoveConcertFromUserURL,userID,concertID];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client deletePath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@: Success removing concert %@ from profile %@. Response: %@", NSStringFromClass([self class]),concertID,userID,[responseObject description]);
        BOOL response = [[responseObject objectForKey:@"response"] isEqualToString:@"success"];
        if (completion) {
            completion(response);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR removing concert %@ from profile %@: %@...",NSStringFromClass([self class]), concertID, userID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(FALSE);
        }
    }];
    
}

//Expect nsdictionary with image, concert, and user
+(void) postImage:(NSDictionary*)imageDic completion:(void (^)())completion {
    //POST /concerts/:id/posts
    NSString* concertIDStr = [[imageDic objectForKey:@"concert"] stringValue];
    NSString* urlString = [NSString stringWithFormat:PostImageURL,concertIDStr];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

    NSData* imageData = UIImagePNGRepresentation([(UIImage*)[imageDic objectForKey:@"image"] fixOrientation]);
    
    NSDictionary* params = [NSDictionary dictionaryWithObject:[imageDic objectForKey:@"user"] forKey:@"facebook_id"];
    NSLog(@"%@",params.description);
    NSMutableURLRequest * request = [client multipartFormRequestWithMethod:@"POST" path:urlString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData: imageData name:@"image" fileName:@"image.png" mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completion) {
            completion();
        }
        NSLog(@"Successfully posted image to concert %@",concertIDStr);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to post image to concert %@: %@...",concertIDStr, [error.description substringToIndex:MAX_ERROR_LEN]);
    }];
    [operation start];
}

+(void) flagPost:(NSString *)postID withFlag:(NSString *)flag fromUser: (NSString*) userID completion:(void (^)(BOOL success))completion {
    NSString * urlString = [NSString stringWithFormat:FlagPostURL,postID];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:flag,@"flag",userID, @"facebook_id",nil];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* returnValue = [responseObject objectForKey:@"response"];
        NSLog(@"%@: Success flagging post %@. Response: %@", NSStringFromClass([self class]),postID,returnValue);

        if (completion) {
            completion([returnValue isEqualToString:@"success"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR flagging post %@: %@...",NSStringFromClass([self class]), postID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        if (completion) {
            completion(FALSE);
        }
    }];
}

+(void) populateConcert: (NSString*) eventID completion: (void(^)(BOOL success)) completion {
    NSString * urlString = [NSString stringWithFormat:PopulateEventURL,eventID];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    [client postPath:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString* returnValue = [responseObject objectForKey:@"response"];
        NSLog(@"%@: Success asking server to populate event %@. Response: %@", NSStringFromClass([self class]),eventID,returnValue);
        
        if (completion) {
            completion([returnValue isEqualToString:@"success"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR asking server to populate event %@: %@...",NSStringFromClass([self class]), eventID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        if (completion) {
            completion(FALSE);
        }
    }];

}


+(void) addFriends: (NSArray*) friends ofUser: (NSString*) userID toEvent: (NSString*) eventID completion: (void(^)(NSArray* friends)) completion {
    NSString* urlString = [NSString stringWithFormat:SaveFriendsURL,userID,eventID];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BaseURL]];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:friends,@"friends", nil];
    
    [client postPath:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@:Success posting friends of user %@ to event %@.",NSStringFromClass([self class]),userID,eventID);
        if (completion) {
            completion(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@:Failed to post friends of user %@ to event %@: %@...",NSStringFromClass([self class]),userID,eventID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    
}
@end
