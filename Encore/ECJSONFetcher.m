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
#import <CoreLocation/CoreLocation.h>

//TODO could change to use blocks instead of delegates to return success
@implementation ECJSONFetcher
+(void) fetchConcertsForUserID: (NSString *) fbID  completion: (void (^)(NSDictionary* concerts)) completion {
    __block NSDictionary * concertList;
    NSString *  fullConcertsUrl = [NSString stringWithFormat:UserConcertsURL,fbID];
    NSURL * url = [NSURL URLWithString:fullConcertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        concertList = (NSDictionary*) [(NSDictionary*)JSON objectForKey:@"events"];
        NSLog(@"%@: Successfully fetched %d past and %d future concerts for profile %@", NSStringFromClass([ECJSONFetcher class]),[[concertList objectForKey:@"past"] count], [[concertList objectForKey:@"future"] count], fbID);
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

NSString* pathForSearchType (ECSearchType searchType) {
    if (searchType == ECSearchTypePast) {
        return [NSString stringWithFormat:PastPopularConcertsURL];
    } else if (searchType == ECSearchTypeFuture) {
        return [NSString stringWithFormat:FuturePopularConcertsURL];
    } else {
        return [NSString stringWithFormat:TodayPopularConcertsURL];
    }
}
NSString* stringForSearchType(ECSearchType searchType) {
    switch (searchType) {
        case ECSearchTypePast:
            return @"Past";
        case ECSearchTypeFuture:
            return @"Future";
        case ECSearchTypeToday:
            return @"Today";
        default:
            break;
    }
    return nil;
}
+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType location: (CLLocation*) location radius: (NSNumber*) radius completion: (void (^)(NSArray* concerts)) completion {
    __block NSArray * concertList;
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude", longitude, @"longitude", radius, @"radius",nil];
    
    NSURL * url = [NSURL URLWithString:BaseURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *  artistConcertsPath = pathForSearchType(searchType);
    
    [client getPath:artistConcertsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        concertList = (NSArray*) [(NSDictionary*)responseObject objectForKey:@"events"];
        NSLog(@"%@: Successfully fetched %d popular concerts for search type: %@ Location: %f %f", NSStringFromClass([ECJSONFetcher class]),concertList.count,stringForSearchType(searchType),location.coordinate.latitude,location.coordinate.longitude);
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
    
        else {
            if(completion)
                completion(nil);
        }
    }];
}

//using combined search
+(void)fetchArtistsForString:(NSString*)searchStr withSearchType:(ECSearchType)searchType forLocation:(CLLocation*)location radius: (NSNumber*) radius completion:(void (^)(NSDictionary* artists)) completion {
    
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
    
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude",longitude, @"longitude", searchStr, @"term", tenseString, @"tense",radius, @"radius",nil];
    
    [client getPath:ArtistCombinedSearchURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully fetched Artists and Concerts for string. %@", searchStr);
            artistConcertComboList = (NSDictionary*)responseObject;
            if (completion) {
                completion(artistConcertComboList);
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


+(void)fetchPictureForArtist: (NSString*) artist completion: (void(^) (NSURL* imageURL)) completion {
    NSString* fullArtistPicURL = [NSString stringWithFormat:ArtistPictureURL,[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURL * url = [NSURL URLWithString:fullArtistPicURL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSURL* imageURL = [NSURL URLWithString:[(NSDictionary*) JSON objectForKey:@"image_url"]];
        if (completion) {
            
            completion(imageURL);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completion) {
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
        NSLog(@"Successfully polled server for if concert %@ is on profile %@. Response: %@", concertID, userID,result ? @"YES" :@"NO");
        if(completion)
            completion(result);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@: ERROR checking if concert %@ is on profile %@: %@...", NSStringFromClass([self class]),concertID,userID,[[error description] substringToIndex:MAX_ERROR_LEN]);
    }];
}

+(void) checkIfEventIsPopulating: (NSString*) eventID completion: (void (^)(BOOL isPopulating)) completion {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:CheckEventPopulatingURL,eventID]];

    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        BOOL result = FALSE;
        result = [(NSNumber*)[(NSDictionary*) JSON objectForKey:@"response"] boolValue];
        NSLog(@"%@: Successfully polled server for if event %@ is populating: %@",NSStringFromClass([ ECJSONFetcher class]),eventID,result ? @"YES":@"NO");
        if (completion) {
            completion(result);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: ERROR Failed to poll server for if event %@ is populating: %@...",NSStringFromClass([ ECJSONFetcher class]),eventID,[error.description substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(FALSE); //default to false
        }
    }];
    [operation start];
}


@end
