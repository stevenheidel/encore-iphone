//
//  EncoreURL.h
//  Encore
// 
//  Created by Shimmy on 2013-06-26.
//  Copyright (c) 2013 Encore. All rights reserved.
//
#import "Staging.h"



#ifndef Encore_EncoreURL_h
#define Encore_EncoreURL_h

#if STAGING
#define BASE_URL_PUBLIC_DEF "http://encore-backend-staging.herokuapp.com/"
#else
#if PRODUCTION
#define BASE_URL_PUBLIC_DEF "http://on.encore.fm/"
#else
#define BASE_URL_PUBLIC_DEF "http://192.168.11.15:3000/"
#endif
#endif

#define BASE_URL_DEF BASE_URL_PUBLIC_DEF "api/v1/"

#define MAX_ERROR_LEN 200

static NSString *const BaseURL = @BASE_URL_DEF;
//URLS

//Sharing
static NSString *const ShareConcertURL = @BASE_URL_PUBLIC_DEF "events/%@"; //,event id
static NSString *const SharePostURL = @BASE_URL_PUBLIC_DEF "posts/%@"; //,post id

//User's concerts
static NSString *const UserConcertsURL = @BASE_URL_DEF "users/%@/events"; //,facebook id

//Popular concerts
static NSString *const PastPopularConcertsURL = @"events/past.json";
static NSString *const FuturePopularConcertsURL = @"events/future.json";
static NSString *const TodayPopularConcertsURL = @"events/today.json";

//Artists and Concerts combo
//purposely left out base url, get is initialized with base url
static NSString *const ArtistCombinedSearchURL = @"artists/combined_search.json";
static NSString *const ArtistPictureURL = @BASE_URL_DEF "artists/picture.json?artist_id=%@"; //,artistid
static NSString *const ArtistInfoURL = @BASE_URL_DEF "artists/info.json?artist_id=%@&limit_events=%d";//,arist,limit events
//Posts
static NSString *const ConcertPostsURL = @BASE_URL_DEF "events/%@/posts" ; //,concertID
static NSString *const FlagPostURL = @"posts/%@/flag.json"; //,postID
//Concert Check
static NSString *const CheckConcertOnProfileURL = @"users/%@/events.json"; //,userID

#pragma mark - Posting
//static NSString *const ;
//Add concert to User
static NSString* const AddConcertToUserURL = @"users/%@/events.json"; //,userID
static NSString* const RemoveConcertFromUserURL = @"users/%@/events/%@.json"; //,userID, concertID
static NSString* const PostImageURL = @"events/%@/posts"; //,concertid

#pragma mark - Check populating
static NSString* const CheckEventPopulatingURL = @BASE_URL_DEF "events/%@/populating.json"; //,eventID
static NSString* const PopulateEventURL = @BASE_URL_DEF "events/%@/populate.json"; //, eventID

#pragma mark - Friends
static NSString* const SaveFriendsURL = @BASE_URL_DEF "users/%@/events/%@/add_facebook_friends"; //,userID,eventID
static NSString* const GetFriendsURL = @BASE_URL_DEF "users/%@/events/%@/facebook_friends"; //


#endif
