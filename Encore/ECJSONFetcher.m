//
//  ECJSONFetcher.m
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECJSONFetcher.h"
#import "EncoreURL.h"
#import "AFNetworking.h"

//TODO could change to use blocks instead of delegates to return success
@implementation ECJSONFetcher
+(void) fetchConcertsForUserID: (NSString *) fbID  completion: (void (^)(NSDictionary* concerts)) completion {
    __block NSDictionary * concertList;
    NSString *  fullConcertsUrl = [NSString stringWithFormat:UserConcertsURL,fbID];
    NSURL * url = [NSURL URLWithString:fullConcertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        concertList = (NSDictionary*) [(NSDictionary*)JSON objectForKey:@"events"];
        if (completion) {
            completion(concertList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching concerts for userID %@: %@...",fbID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        if (RETURN_TEST_DATA) {
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
        }
        else if (completion){
            completion(nil);
        }
    }];
        
    
    [operation start];
}


+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion {
    __block NSArray * concertList;
    NSString *userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:userLocation, CityURL,nil];
    
    NSURL * url = [NSURL URLWithString:BaseURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *  artistConcertsUrl;
    if (searchType == ECSearchTypePast) {
        artistConcertsUrl = [NSString stringWithFormat:PastPopularConcertsURL];
    } else if (searchType == ECSearchTypeFuture) {
        artistConcertsUrl = [NSString stringWithFormat:FuturePopularConcertsURL];
    } else {
        artistConcertsUrl = [NSString stringWithFormat:TodayPopularConcertsURL];
    }
    
    [client getPath:artistConcertsUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@: %@",NSStringFromClass([self class]),[responseObject description]);
        concertList = (NSArray*) [(NSDictionary*)responseObject objectForKey:@"concerts"];
        NSLog(@"Successfully fetched %d popular concerts", [concertList count]);
        if (RETURN_TEST_DATA) {
            NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], LastfmIDURL, nil];
            NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], LastfmIDURL, nil];
            NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
            if (completion) {
                completion(testConcertList);
            }
        }else {
            if (completion) {
                completion(concertList);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR fetching popular concerts: %@...",[[error description] substringToIndex:MAX_ERROR_LEN]);
        
        
        if (RETURN_TEST_DATA) {
            NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], LastfmIDURL, nil];
            NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], LastfmIDURL, nil];
            NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
            if (completion) {
                completion(testConcertList);
            }
        }
    }];
}

+(void)fetchArtistsForString:(NSString*) searchStr completion:(void (^)(NSArray* artists)) completion {
    __block NSArray * artistList;
    NSString *  artistSearchUrl = [NSString stringWithFormat:ArtistSearchURL, searchStr];
    NSString *escapedDataString = [artistSearchUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL * url = [NSURL URLWithString:escapedDataString];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        artistList = (NSArray*) [(NSDictionary*)JSON objectForKey:@"artists"];
        NSLog(@"Successfully fetched %d Artists for string. %@", artistList.count, searchStr);
        if (completion) {
            completion(artistList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching artists for string %@: %@...",searchStr,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (RETURN_TEST_DATA) {
            NSDictionary * artist1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 1",@"name", @"1234", @"songkick_id", nil];
            NSDictionary * artist2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 2",@"name", @"4321", @"songkick_id", nil];
            if(completion){
                completion([NSArray arrayWithObjects:artist1,artist2, nil]);
            }
        }
    }];
    
    [operation start];
}

+(void)fetchArtistsForString:(NSString*)searchStr withSearchType:(ECSearchType)searchType forLocation:(NSString*)locationString completion:(void (^)(NSDictionary* artists)) completion {
    
    __block NSDictionary * artistConcertComboList;

    
    NSURL * url = [NSURL URLWithString:BaseURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    NSString *tenseString;
    if (searchType == ECSearchTypePast) {
        tenseString = PastURL;
    } else {
        tenseString = FutureURL;
    }
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:locationString, CityURL, searchStr, TermURL, tenseString, TenseURL, nil];
    
    [client getPath:UsersURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (RETURN_TEST_DATA) {
            //temporary test data to test ui
            NSMutableDictionary *testArtistConcertCombo = [[NSMutableDictionary alloc] init];
            [testArtistConcertCombo setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 1",@"name", @"1234", @"songkick_id", nil] forKey:@"artist"];
            
            NSDictionary * artist2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 2",@"name", @"1234", @"songkick_id", nil];
            NSDictionary * artist3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 3",@"name", @"4321", @"songkick_id", nil];
            NSDictionary *others = [NSArray arrayWithObjects:artist2, artist3, nil];
            [testArtistConcertCombo setObject:others forKey:@"others"];
            
            NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], @"server_id", nil];
            NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], @"server_id", nil];
            NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
            [testArtistConcertCombo setObject:testConcertList forKey:@"concerts"];
            
            if(completion){
                completion(testArtistConcertCombo);
            }
        } else {
            NSLog(@"Successfully fetched Artists and Concerts for string. %@", searchStr);
            artistConcertComboList = (NSDictionary*)responseObject;
            if (completion) {
                completion(artistConcertComboList);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR fetching artists for string %@: %@...",searchStr,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (RETURN_TEST_DATA) {
            
            NSMutableDictionary *testArtistConcertCombo = [[NSMutableDictionary alloc] init];
            [testArtistConcertCombo setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 1",@"name", @"1234", @"songkick_id", nil] forKey:@"artist"];
            
            NSDictionary * artist2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 2",@"name", @"1234", @"songkick_id", nil];
            NSDictionary * artist3 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Artist 3",@"name", @"4321", @"songkick_id", nil];
            NSDictionary *others = [NSArray arrayWithObjects:artist2, artist3, nil];
            [testArtistConcertCombo setObject:others forKey:@"others"];
            
            NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], @"server_id", nil];
            NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], @"server_id", nil];
            NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
            [testArtistConcertCombo setObject:testConcertList forKey:@"concerts"];
            
            if(completion){
                completion(testArtistConcertCombo);
            }
        } else if (completion){
            completion(nil);
        }
    }];
}

+(void) fetchConcertsForArtistID:(NSNumber *)artistID withSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion {
    __block NSArray * concertList;
    NSString *userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate
    NSString *  artistConcertsUrl;
    if (searchType == ECSearchTypePast) {
        artistConcertsUrl = [NSString stringWithFormat:ArtistConcertSearchPastURL, [artistID stringValue], userLocation];
    } else {
        artistConcertsUrl = [NSString stringWithFormat:ArtistConcertSearchFutureURL, [artistID stringValue], userLocation];
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
        
        if (RETURN_TEST_DATA) {
            NSDictionary * concert1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 1", @"venue_name", @"1989-02-16", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:99], @"server_id", nil];
            NSDictionary * concert2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Venue Name 2", @"venue_name", @"1999-03-26", @"date",@"Simon and the Destroyers", @"name",[NSNumber numberWithInt:55], @"server_id", nil];
            NSArray * testConcertList = [NSArray arrayWithObjects:concert1,concert2, nil];
            if(completion){
                completion(testConcertList);
            }
        }
        else if (completion){
            completion(nil);
        }
    }];
    
    [operation start];
}

+(void) fetchPostsForConcertWithID: (NSString *) concertID completion: (void (^)(NSArray* fetchedPosts)) completion{
    __block NSArray * posts;
    NSString * fullPostsUrl = [NSString stringWithFormat:ConcertPostsURL,concertID];
    NSURL * url = [NSURL URLWithString:fullPostsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        posts = (NSArray*) [(NSDictionary*)JSON objectForKey:@"posts"];
        if(completion) {
            completion(posts);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching posts for concert with id %@: %@...",[concertID description],[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];
}

+(void) checkIfConcert: (NSString*) concertID isOnProfile: (NSString *) userID completion: (void (^)(BOOL isOnProfile)) completion  {
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:concertID, LastfmIDURL,nil];
    
    NSURL * url = [NSURL URLWithString:BaseURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *  CheckConcertForUserUrl = [NSString stringWithFormat:CheckConcertOnProfileURL, userID];
    
    [client getPath:CheckConcertForUserUrl parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        BOOL result = FALSE;
        result = [(NSNumber*)[(NSDictionary*) responseObject objectForKey:@"response"] boolValue];
        NSLog(@"Successfully polled server for if concert %@ is on profile %@. Response: %d", concertID, userID,result);
        if(completion)
            completion(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR checking if concert %@ is on profile %@: %@...", NSStringFromClass([self class]),concertID,userID,[[error description] substringToIndex:MAX_ERROR_LEN]);
    }];
}


@end
