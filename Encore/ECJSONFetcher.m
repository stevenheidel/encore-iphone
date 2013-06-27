//
//  ECJSONFetcher.m
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECJSONFetcher.h"
#import "EncoreURL.h"
#define MAX_ERROR_LEN 200

//TODO could change to use blocks instead of delegates to return success
@implementation ECJSONFetcher
+(void) fetchConcertsForUserID: (NSString *) fbID  completion: (void (^)(NSDictionary* concerts)) completion {
    __block NSDictionary * concertList;
    NSString *  fullConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",BaseURL,UsersURL,fbID,ConcertsURL];
    NSURL * url = [NSURL URLWithString:fullConcertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        concertList = (NSDictionary*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        if (completion) {
            completion(concertList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching concerts for userID %@: %@...",fbID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        NSDictionary * past1 = [NSDictionary dictionaryWithObjectsAndKeys:@"2013-06-12", @"date", @"Test Venue 1", @"venue_name", @"My Artist", @"name", @"11", @"server_id", nil];
        NSDictionary * past2 = [NSDictionary dictionaryWithObjectsAndKeys:@"2012-05-11", @"date", @"Test Venue 2", @"venue_name", @"Go Artist", @"name", @"22", @"server_id", nil];
        NSDictionary * future1 = [NSDictionary dictionaryWithObjectsAndKeys:@"2013-09-11", @"date", @"Test Venue 3", @"venue_name", @"Artist2013", @"name", @"33", @"server_id", nil];
        NSDictionary * future2 = [NSDictionary dictionaryWithObjectsAndKeys:@"2013-12-22", @"date", @"Test Venue 4", @"venue_name", @"Cool Artist", @"name", @"44", @"server_id", nil];
        
        NSArray * past = [NSArray arrayWithObjects: past1, past2, nil];
        NSArray * future = [NSArray arrayWithObjects: future1, future2, nil];
        NSDictionary * concertList = [NSDictionary dictionaryWithObjectsAndKeys:past,@"past",future,@"future", nil];
        if (completion) {
            completion(concertList);
        }
    }];
    
    [operation start];
}

//GET /concerts/future?city=Toronto
+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion {
    __block NSArray * concertList;
    NSString *userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate
    NSString *  artistConcertsUrl;
    if (searchType == ECSearchTypePast) {
        artistConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@?%@%@", BaseURL, ConcertsURL, PastURL, CityURL, userLocation];
    } else if (searchType == ECSearchTypeFuture) {
        artistConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@?%@%@", BaseURL, ConcertsURL, FutureURL, CityURL, userLocation];
    } else {
        artistConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@?%@%@", BaseURL, ConcertsURL, TodayURL, CityURL, userLocation];
    }
    
    NSString *escapedDataString = [artistConcertsUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:escapedDataString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        concertList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        NSLog(@"Successfully fetched %d popular concerts", [concertList count]);
        if (completion) {
            completion(concertList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching popular concerts: %@...",[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        //TODO: replace so it loads in cached objects
        NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], @"server_id", nil];
        NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], @"server_id", nil];
        NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
        if (completion) {
            completion(testConcertList);
        }
    }];
    
    [operation start];
}

+(void)fetchArtistsForString:(NSString*) searchStr completion:(void (^)(NSArray* artists)) completion {
    __block NSArray * artistList;
    NSString *  artistSearchUrl = [NSString stringWithFormat:@"%@/%@/%@%@", BaseURL, ArtistsURL, SearchURL, searchStr];
    NSString *escapedDataString = [artistSearchUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:escapedDataString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Successfully fetched Artists for string. %@", searchStr);
        artistList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"artists"];
        if (completion) {
            completion(artistList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching artists for string %@: %@...",searchStr,[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        NSDictionary * artist1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 1",@"name", @"1234", @"songkick_id", nil];
        NSDictionary * artist2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 2",@"name", @"4321", @"songkick_id", nil];
        if(completion){
            completion([NSArray arrayWithObjects:artist1,artist2, nil]);
        }
    }];
    
    [operation start];
}

+(void) fetchConcertsForArtistID:(NSNumber *)artistID withSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion {
    __block NSArray * concertList;
    NSString *userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate
    NSString *  artistConcertsUrl;
    if (searchType == ECSearchTypePast) {
        artistConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@/%@?%@%@", BaseURL, ArtistsURL, [artistID stringValue], ConcertsURL, PastURL, CityURL, userLocation];
    } else {
        artistConcertsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@/%@?%@%@", BaseURL, ArtistsURL, [artistID stringValue], ConcertsURL, FutureURL, CityURL, userLocation];
    }
    
    NSString *escapedDataString = [artistConcertsUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:escapedDataString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        concertList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"concerts"];
        NSLog(@"Successfully fetched concerts for artist with id: %@", [artistID description]);
        if(completion){
            completion(concertList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching concerts for artist with ID %@: %@...",[artistID description],[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        //TODO: replace so it loads in cached objects
        NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], @"server_id", nil];
        NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], @"server_id", nil];
        NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
        if(completion){
            completion(testConcertList);
        }
    }];
    
    [operation start];
}

+(void) fetchPostsForConcertWithID: (NSNumber *) serverID completion: (void (^)(NSArray* fetchedPosts)) completion{
    __block NSArray * posts;
    NSString * fullPostsUrl = [NSString stringWithFormat:@"%@/%@/%@/%@",BaseURL,ConcertsURL,[serverID stringValue],PostsURL];
    NSURL * url = [NSURL URLWithString:fullPostsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        posts = (NSArray*) [(NSDictionary*)JSON objectForKey:@"posts"];
        if(completion) {
            completion(posts);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching posts for concert with id %@: %@...",[serverID description],[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];
}

+(void) checkIfConcert: (NSNumber*) concertID isOnProfile: (NSString *) userID completion: (void (^)(BOOL isOnProfile)) completion  {
   NSString * fullCheckURL = [NSString stringWithFormat:@"%@/%@/%@/%@?%@=%@",BaseURL, UsersURL,userID, ConcertsURL,SongkickIDURL, concertID.stringValue];
    
    NSURL * url = [NSURL URLWithString:fullCheckURL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Successfully polled server for if concert %@ is on profile %@", concertID, userID);
        BOOL result = FALSE;
        NSLog(@"%@",[JSON description]);
        result = [(NSNumber*)[(NSDictionary*) JSON objectForKey:@"response"] boolValue];
        if(completion)
            completion(result);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: ERROR checking if concert %@ is on profile %@: %@...", NSStringFromClass([self class]),concertID.stringValue,userID,[[error description] substringToIndex:MAX_ERROR_LEN]);
    }];
    [operation start];
}


@end
