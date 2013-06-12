//
//  ECJSONFetcher.m
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECJSONFetcher.h"

static NSString *const BaseURLString = @"http://192.168.11.15:9283/api/v1/users";

@implementation ECJSONFetcher
-(void) fetchConcertsForUserId: (NSString *) fb_id {
    __block NSArray * concertList;
    NSString *  concertsUrl = [NSString stringWithFormat:@"%@/%@/concerts",BaseURLString,fb_id];
    NSURL * url = [NSURL URLWithString:concertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        concertList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        [self.delegate fetchedConcerts: concertList];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR:%@",[error description]);
    }];
    
    [operation start];
}
@end
