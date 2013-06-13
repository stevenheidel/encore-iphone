//
//  ECJSONFetcher.m
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECJSONFetcher.h"

static NSString *const BaseURLString = @"http://192.168.11.15:9283/api/v1";
static NSString *const UsersURL = @"users";
static NSString *const ConcertsURL = @"concerts";
static NSString *const PostsURL = @"posts";

@implementation ECJSONFetcher
-(void) fetchConcertsForUserId: (NSString *) fb_id {
    __block NSArray * concertList;
    NSString *  fullConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",BaseURLString,UsersURL,fb_id,ConcertsURL];
    NSURL * url = [NSURL URLWithString:fullConcertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        concertList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        [self.delegate fetchedConcerts: concertList];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR:%@",[error description]);
    }];
    
    [operation start];
}

-(void) fetchPostsForConcertWithID: (NSString *) serverID {
    __block NSArray * posts;
    NSString * fullPostsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",BaseURLString,ConcertsURL,serverID,PostsURL];
    NSURL * url = [NSURL URLWithString:fullPostsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            posts = (NSArray*) [(NSDictionary*)JSON objectForKey:@"posts"];
            [self.delegate fetchedPosts: posts];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR:%@",[error description]);
    }];
    [operation start];
}


@end
