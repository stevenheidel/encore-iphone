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

+(void) fetchConcertWithEventID: (NSString *) eventID completion: (void (^)(NSDictionary* concert)) completion {
    NSString* concertURL = [NSString stringWithFormat:SingleConcertURL,eventID];
    NSURL* url = [NSURL URLWithString:concertURL];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (completion) {
            completion((NSDictionary*) JSON);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: Failed to get single concert %@, Error; %@", NSStringFromClass([ECJSONFetcher class]), eventID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];
}

+(void) fetchConcertsForUserID: (NSString *) fbID  completion: (void (^)(NSDictionary* concerts)) completion {
    __block NSDictionary * concertList;
    NSString *  fullConcertsUrl = [NSString stringWithFormat:UserConcertsURL,fbID];
    NSURL * url = [NSURL URLWithString:fullConcertsUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        concertList = (NSDictionary*) [(NSDictionary*)JSON objectForKey:@"events"];
        NSLog(@"%@: Successfully fetched %d past and %d future concerts for profile %@", NSStringFromClass([ECJSONFetcher class]),(int)[[concertList objectForKey:@"past"] count], (int)[[concertList objectForKey:@"future"] count], fbID);
        if (completion) {
            completion(concertList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching concerts for userID %@: %@...",fbID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (RETURN_TEST_DATA) {
            NSDictionary * past1 = [NSDictionary dictionaryWithObjectsAndKeys:@"2013-06-12", @"date", @"%ldst Venue 1", @"venue_name", @"My Artist", @"name", @"11", @"server_id", nil];
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
+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType location: (CLLocation*) location radius: (NSNumber*) radius page:(NSInteger) page completion: (void (^)(NSArray* concerts,NSInteger total)) completion {
    __block NSArray * concertList;
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    NSDictionary * parameters ;
    if(searchType == ECSearchTypeFuture)
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude", longitude, @"longitude", radius, @"radius",[NSString stringWithFormat:@"%d",(int)page],@"page",@"50",@"limit",nil];
    else
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude", longitude, @"longitude", radius, @"radius",nil];

    
    NSURL * url = [NSURL URLWithString:BaseURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *  artistConcertsPath = pathForSearchType(searchType);
    
    [client getPath:artistConcertsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        concertList = (NSArray*) [(NSDictionary*)responseObject objectForKey:@"events"];
        if(page > 10)
            concertList = nil;
        NSInteger total = [[(NSDictionary*) responseObject objectForKey:@"total"] integerValue];
        
        NSLog(@"%@: Successfully fetched %d popular concerts for search type: %@ Location: %f %f", NSStringFromClass([ECJSONFetcher class]),(int)concertList.count,stringForSearchType(searchType),location.coordinate.latitude,location.coordinate.longitude);
        if (completion) {
            completion(concertList,total);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR fetching popular concerts: %@...",[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (searchType == ECSearchTypePast) { // so you don't get 3 error messages
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        if(completion)
            completion(nil,0);
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
        tenseString = @"past";
    } else {
        tenseString = @"future";
    }
    
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude",longitude, @"longitude", searchStr, @"term", tenseString, @"tense",radius, @"radius",nil];
    
    [client getPath:ArtistCombinedSearchURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

            artistConcertComboList = (NSDictionary*)responseObject;
//        NSLog(@"%@",artistConcertComboList.description);
        NSLog(@"Successfully fetched %d %@ Artists and Concerts for string. %@", (int)[[artistConcertComboList objectForKey:@"events"] count],tenseString, searchStr);
        
            if (completion) {
                completion(artistConcertComboList);
            }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR fetching artists for string %@: %@...",searchStr,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion){
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
            NSLog(@"%@: Successfully fetched picture for artist %@",NSStringFromClass([ECJSONFetcher class]),artist);
            completion(imageURL);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: Failed to fetch picture for artist %@: %@...",NSStringFromClass([ECJSONFetcher class]),artist,[error.description  substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];
}

+(AFJSONRequestOperation*) fetchInfoForArtist:(NSString*) artist completion: (void(^) (NSDictionary* artistInfo)) completion {
    int limitEvents = 10;
    NSString* infoURL = [NSString stringWithFormat:ArtistInfoURL,[artist stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],limitEvents];
    NSURL* url = [NSURL URLWithString:infoURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __block NSDictionary* info;
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        info = (NSDictionary*) JSON;
        NSDictionary* events = [info objectForKey:@"events"];
        NSInteger pastCount = [[events objectForKey:@"past"] count];
        NSInteger upcomingCount = [[events objectForKey:@"upcoming"] count];
        NSLog(@"%@: Successfully retrieved info for artist %@. %d upcoming and %d past",NSStringFromClass([ECJSONFetcher class]),artist,(int)upcomingCount,(int)pastCount);

        if (completion) {
            completion(info);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR: failed to retrieve info for artist %@, %@",artist,[error.description substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];
    return operation;
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
    
    NSDictionary * parameters = [NSDictionary dictionaryWithObjectsAndKeys:concertID, @"lastfm_id",nil];
    
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
+ (NSString*)urlEscapeString:(id)unencodedString {
    if ([unencodedString isKindOfClass:[NSString class]]) {
        CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
        NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
        CFRelease(originalStringRef);
        return s;
    }
    return unencodedString;
}
+(void) fetchSongPreviewsForArtist:(NSString*) artist
                       completion: (void(^) (NSArray* songs)) completion
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale objectForKey:NSLocaleCountryCode];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&media=music&limit=10&country=%@",[ECJSONFetcher urlEscapeString:artist],country]];
    
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSArray* songs = [JSON objectForKey:@"results"];
        NSLog(@"%@: Successfully got %d songs for artist %@",NSStringFromClass([self class]),(int)songs.count,artist);
        if (completion) {
            completion (songs);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: Failed to get song preview for artist %@: %@",NSStringFromClass([self class]),artist,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];

}

+(void) fetchFriendsForUser: (NSString*) userID atEvent: (NSString*) eventID completion: (void (^) (NSArray* friends)) completion {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:GetFriendsURL,userID,eventID]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* friends = (NSArray*) JSON;
        NSLog(@"%@: Successfully got %d friends for user %@ at event %@",NSStringFromClass([self class]),friends.count,userID,eventID);
        if (completion) {
            completion(friends);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: Failed to get friends for user %@ at event %@: %@...",NSStringFromClass([self class]),userID,eventID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    [operation start];
}
                  

@end
