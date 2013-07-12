//
//  ECJSONFetcher.h
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSearchType.h"

@protocol ECJSONFetcherDelegate;

@interface ECJSONFetcher : NSObject
+(void) fetchConcertsForUserID: (NSString *) fbID  completion: (void (^)(NSDictionary* concerts)) completion;

+(void)fetchArtistsForString:(NSString*) searchStr completion:(void (^)(NSArray* artists)) completion;

+(void)fetchArtistsForString:(NSString*)searchStr withSearchType:(ECSearchType)searchType forLocation:(NSString*)locationString completion:(void (^)(NSDictionary* artists)) completion;

+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion;

+(void) fetchConcertsForArtistID:(NSNumber *)artistID withSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion;

+(void) fetchPostsForConcertWithID: (NSString *) concertID completion: (void (^)(NSArray* fetchedPosts)) completion;
+(void) checkIfConcert: (NSString*) concertID isOnProfile: (NSString *) userID completion: (void (^)(BOOL isOnProfile)) completion;
+(void) checkIfEventIsPopulating: (NSString*) eventID completion: (void (^)(BOOL isPopulating)) completion;

//@property (nonatomic,unsafe_unretained) id <ECJSONFetcherDelegate> delegate;
@end

