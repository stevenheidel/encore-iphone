//
//  ECJSONFetcher.h
//  Encore
//
//  Created by Shimmy on 2013-06-12.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ECJSONFetcherDelegate;

@interface ECJSONFetcher : NSObject
-(void) fetchConcertsForUserId: (NSString *) id;
-(void)fetchArtistsForString:(NSString *)searchStr;
-(void)fetchConcertsForArtistId:(NSString *)artistId;
-(void) fetchPostsForConcertWithID: (NSString *) serverID;
@property (nonatomic,unsafe_unretained) id <ECJSONFetcherDelegate> delegate;
@end

@protocol ECJSONFetcherDelegate <NSObject>

@optional
-(void) fetchedConcerts: (NSDictionary *) concerts;
-(void) fetchedArtists:(NSArray *)artists;
-(void) fetchedArtistConcerts:(NSArray *)concerts;
-(void) fetchedPosts: (NSArray *) posts;
@end