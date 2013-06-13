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
-(void) fetchPostsForConcertWithID: (NSString *) serverID;
@property (nonatomic,unsafe_unretained) id <ECJSONFetcherDelegate> delegate;
@end

@protocol ECJSONFetcherDelegate <NSObject>

@optional
-(void) fetchedConcerts: (NSArray *) concerts;
-(void) fetchedPosts: (NSArray *) posts;
@end