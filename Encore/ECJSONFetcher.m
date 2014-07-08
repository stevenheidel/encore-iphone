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
#import "NSUserDefaults+Encore.h"

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
    NSString* date = [[self dateStringForFetch] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?date=%@",fullConcertsUrl,date]];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation * operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        concertList = (NSDictionary*) [(NSDictionary*)JSON objectForKey:@"events"];
        NSLog(@"%@: Fetched %d past and %d future concerts for profile %@", NSStringFromClass([ECJSONFetcher class]),(int)[[concertList objectForKey:@"past"] count], (int)[[concertList objectForKey:@"future"] count], fbID);
        if (completion) {
            completion(concertList);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"ERROR fetching concerts for userID %@: %@...",fbID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion){
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

+(NSString*) dateStringForFetch {
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return [formatter stringFromDate:[NSDate date]];
}

+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType location: (CLLocation*) location radius: (NSNumber*) radius page:(NSInteger) page completion: (void (^)(BOOL success, NSArray* concerts,NSInteger total,ECSearchType searchType)) completion {
    __block NSArray * concertList;
    NSNumber* latitude = [NSNumber numberWithDouble:location.coordinate.latitude];
    NSNumber* longitude = [NSNumber numberWithDouble:location.coordinate.longitude];
    NSDictionary * parameters;

    NSString* sendDate = [self dateStringForFetch];
    
    if(searchType == ECSearchTypeFuture)
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude", longitude, @"longitude", radius, @"radius",[NSString stringWithFormat:@"%d",(int)page],@"page",@"50",@"limit",sendDate, @"date",nil];
    else
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude", longitude, @"longitude", radius, @"radius",sendDate, @"date",nil];

    NSURL * url = [NSURL URLWithString:BaseURL];
    AFHTTPClient * client = [[AFHTTPClient alloc] initWithBaseURL:url];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    
    NSString *  artistConcertsPath = pathForSearchType(searchType);
    NSLog(@"%@",artistConcertsPath);
    [client getPath:artistConcertsPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (![responseObject respondsToSelector:@selector(objectForKey:)]) {
            if (completion) {
                completion(NO,nil,0,searchType);
            }
            NSLog(@"ERROR fetching popular concerts: invalid response object");
            return;
        }
        concertList = (NSArray*) [(NSDictionary*)responseObject objectForKey:@"events"];
        if(page > 10)
            concertList = nil;
        NSInteger total = [[(NSDictionary*) responseObject objectForKey:@"total"] integerValue];
        
        NSLog(@"%@: Fetched %d popular concerts for search type: %@ Location: %f %f", NSStringFromClass([ECJSONFetcher class]),(int)concertList.count,stringForSearchType(searchType),location.coordinate.latitude,location.coordinate.longitude);
        if (completion) {
            completion(YES,concertList,total,searchType);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERROR fetching popular concerts: %@...",[[error description] substringToIndex:MAX_ERROR_LEN]);
        if(completion)
            completion(NO,nil,0,searchType);
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
        NSLog(@"Fetched %d %@ Artists and Concerts for string. %@", (int)[[artistConcertComboList objectForKey:@"events"] count],tenseString, searchStr);
        
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
            NSLog(@"%@:Fetched picture for artist %@",NSStringFromClass([ECJSONFetcher class]),artist);
            completion(imageURL);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: Failed to fetch picture for artist %@: %@...",NSStringFromClass([ECJSONFetcher class]),artist,[error.description  substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
        [Flurry logEvent:@"FailedToLoadArtistPhoto" withParameters:@{@"artist":artist}];
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
        NSLog(@"%@:Retrieved info for artist %@. %d upcoming and %d past",NSStringFromClass([ECJSONFetcher class]),artist,(int)upcomingCount,(int)pastCount);

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
        NSLog(@"Checked if concert %@ is on profile %@. Response: %@", concertID, userID,result ? @"YES" :@"NO");
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
        NSLog(@"%@: Polled server for if event %@ is populating: %@",NSStringFromClass([ ECJSONFetcher class]),eventID,result ? @"YES":@"NO");
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
        NSLog(@"%@: Got %d songs for artist %@",NSStringFromClass([self class]),(int)songs.count,artist);
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
        NSLog(@"%@: Got %d friends for user %@ at event %@",NSStringFromClass([self class]),friends.count,userID,eventID);
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

+(void) fetchSeatgeekURLForEvent: (NSString*) eventID completion: (void(^) (NSString* seatgeek_url)) completion {
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:SeatgeekURL,eventID]];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation* operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString* seatgeek_url = (NSString*) JSON[@"seatgeek_url"];
        if (completion) {
            if (![seatgeek_url isKindOfClass:[NSString class]]) {
                seatgeek_url = nil;
                NSLog(@"%@: No seatgeek URL for event %@",NSStringFromClass([self class]),eventID);
            }
            else NSLog(@"%@: Got seatgeek URL for event %@",NSStringFromClass([self class]),eventID);
            completion(seatgeek_url);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@: Failed to get seatgeek url for event %@: %@...",NSStringFromClass([self class]),eventID,[[error description] substringToIndex:MAX_ERROR_LEN]);
        if (completion) {
            completion(nil);
        }
    }];
    
    [operation start];
    
}

+(void) fetchAutocompletions: (void(^) (NSArray* suggestions)) completion {
    [ECJSONFetcher fetchAutocompletionVersion:^(NSInteger version) {
        NSLog(@"Fetched autocompletion version %d",version);
        if (version == [NSUserDefaults autocompletionsVersion]) {
            if (completion) {
                completion(nil);
            }
            NSLog(@"fetchAutocompletions: already up to date");
        }
        else {
            [ECJSONFetcher fetchAutocompletionsForRealsies:completion];
            [NSUserDefaults setAutocompletionsVersion:version];
            [NSUserDefaults synchronize];
        }
    }];
   }


+(void) fetchAutocompletionVersion:(void (^)(NSInteger version))completion {
    NSURL* versionURL = [NSURL URLWithString:AutocompletionsVersionURL];
    NSURLRequest* versionReq = [NSURLRequest requestWithURL:versionURL];
    [AFPropertyListRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    AFPropertyListRequestOperation * operation = [AFPropertyListRequestOperation propertyListRequestOperationWithRequest:versionReq success:^(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList) {
        NSDictionary* dic = (NSDictionary*) propertyList;
        NSInteger version = [dic[@"version"] integerValue];
        if (completion) {
            completion(version);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id propertyList) {
        if (completion)
            completion(-1);
        NSLog(@"Failed fetching autocompletion version %@",error.description);
    }];
    [operation start];
}

+(void) fetchAutocompletionsForRealsies: (void(^) (NSArray* suggestions)) completion {
    NSURL* url = [NSURL URLWithString:AutocompletionsURL];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [AFPropertyListRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/plain"]];
    AFPropertyListRequestOperation* operation = [AFPropertyListRequestOperation propertyListRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id propertyList) {
        NSArray* array = (NSArray*) propertyList;
        if (completion) {
            completion(array);
        }
        NSString *path = [applicationDocumentsDirectory().path stringByAppendingPathComponent:@"SavedAutocompletions.plist"];
        [array writeToFile:path atomically:YES];
        NSLog(@"%@: Fetched autocompletions",NSStringFromClass([ECJSONFetcher class]));
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id propertyList) {
        if (completion) {
            completion(nil);
        }
        NSLog(@"%@: Failed to get autocompletions %@",NSStringFromClass([ECJSONFetcher class]), [error.description substringToIndex:MAX_ERROR_LEN]);
    }];
    [operation start];

}

NSURL * applicationDocumentsDirectory() {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}



@end
