//
//  ECJSONFetcher.h
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ECSearchTypePast,
    ECSearchTypeFuture,
    ECSearchTypeToday
} ECSearchType;

@protocol ECJSONFetcherDelegate;

@interface ECJSONFetcher : NSObject
-(void) fetchConcertsForUserId: (NSString *) id;
-(void)fetchArtistsForString:(NSString *)searchStr;
-(void)fetchPopularConcertsWithSearchType:(ECSearchType)searchType;
-(void)fetchConcertsForArtistID:(NSNumber *)artistID withSearchType:(ECSearchType)searchType;
-(void) fetchPostsForConcertWithID: (NSNumber *) serverID;

+(void) checkIfConcert: (NSNumber*) concertID isOnProfile: (NSString *) userID completion: (void (^)(BOOL isOnProfile)) completion;

@property (nonatomic,unsafe_unretained) id <ECJSONFetcherDelegate> delegate;
@end

@protocol ECJSONFetcherDelegate <NSObject>

@optional
-(void) fetchedConcerts: (NSDictionary *) concerts;
-(void) fetchedPopularConcerts:(NSArray *)concerts;
-(void) fetchedArtists:(NSArray *)artists;
-(void) fetchedArtistConcerts:(NSArray *)concerts;
-(void) fetchedPosts: (NSArray *) posts;

@end