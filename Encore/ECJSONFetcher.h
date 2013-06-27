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

+(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion;

+(void) fetchConcertsForArtistID:(NSNumber *)artistID withSearchType:(ECSearchType)searchType completion: (void (^)(NSArray* concerts)) completion;

+(void) fetchPostsForConcertWithID: (NSNumber *) serverID completion: (void (^)(NSArray* fetchedPosts)) completion;
+(void) checkIfConcert: (NSNumber*) concertID isOnProfile: (NSString *) userID completion: (void (^)(BOOL isOnProfile)) completion;

@property (nonatomic,unsafe_unretained) id <ECJSONFetcherDelegate> delegate;
@end

@protocol ECJSONFetcherDelegate <NSObject>

@optional
-(void) fetchedArtists:(NSArray *)artists;
-(void) fetchedArtistConcerts:(NSArray *)concerts;

@end