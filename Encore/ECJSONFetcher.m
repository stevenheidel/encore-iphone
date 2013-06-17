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
static NSString *const ArtistsURL = @"artists";
static NSString *const SearchURL = @"search?term=";
static NSString *const PastURL = @"past";
static NSString *const FutureURL = @"future";
static NSString *const CityURL = @"city=";
static NSString *const PostsURL = @"posts";

//TODO could change to use blocks instead of delegates to return success
@implementation ECJSONFetcher

-(void) fetchConcertsForUserId: (NSString *) fb_id {
    __block NSDictionary * concertList;
    NSString *  fullConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",BaseURLString,UsersURL,fb_id,ConcertsURL];
    NSURL * url = [NSURL URLWithString:fullConcertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSLog(@"FetchConcertsForUserId: %@", [JSON description]);
        concertList = (NSDictionary*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        [self.delegate fetchedConcerts: concertList];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR:%@",[error description]);
    }];
    
    [operation start];
}

-(void)fetchArtistsForString:(NSString *)searchStr {
    __block NSArray * artistList;
    NSString *  artistSearchUrl = [NSString stringWithFormat:@"%@/%@/%@%@", BaseURLString, ArtistsURL, SearchURL, searchStr];
    NSString *escapedDataString = [artistSearchUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:escapedDataString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", [JSON description]);
        artistList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"artists"];
        [self.delegate fetchedArtists:artistList];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR:%@",[error description]);
    }];
    
    [operation start];
}



-(void)fetchConcertsForArtistID:(NSString *)artistID {
    __block NSArray * concertList;
    NSString *userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate
    NSString *  artistConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@/%@?%@%@", BaseURLString, ArtistsURL, artistID, ConcertsURL, PastURL, CityURL, userLocation];
    NSString *escapedDataString = [artistConcertsUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:escapedDataString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", [JSON description]);
        concertList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        [self.delegate fetchedArtistConcerts: concertList];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR:%@",[error description]);
    }];
    
    [operation start];
}

//-(void) fetchConcertsForId:(NSString *) id completion: (void (^)()){
//    
//}

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
