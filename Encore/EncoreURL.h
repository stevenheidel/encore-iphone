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

#define EVENTS_DEF "events"
#define USERS_DEF "users"
#define POSTS_DEF "posts"
#define SEARCH_DEF "search"
#define TERM_DEF "term"
#define ARTISTS_DEF "artists"
#define PAST_DEF "past"
#define FUTURE_DEF "future"
#define TODAY_DEF "today"
#define TENSE_DEF "tense"
#define CITY_DEF "city"
#define JSON_DEF ".json"
#define LASTFM_ID_DEF "lastfm_id"
#define SONGKICK_ID_DEF "songkick_id"
#define COMBINED_SEARCH_DEF "combined_search"
#define POPULATING_DEF "populating.json"
#define FLAG_DEF "flag"

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
static NSString* const PostImageURL = @EVENTS_DEF "/%@/" POSTS_DEF;

#pragma mark - Check populating
static NSString* const CheckEventPopulatingURL = @BASE_URL_DEF "events/%@/populating.json"; //,eventID
static NSString* const PopulateEventURL = @BASE_URL_DEF "events/%@/populate.json"; //, eventID

#pragma mark - Components
static NSString *const UsersURL = @USERS_DEF;
static NSString *const ConcertsURL = @EVENTS_DEF;
static NSString *const PostsURL = @POSTS_DEF;
static NSString *const SearchURL = @SEARCH_DEF;
static NSString *const ArtistsURL = @ARTISTS_DEF;
static NSString *const PastURL = @PAST_DEF;
static NSString *const FutureURL = @FUTURE_DEF;
static NSString *const TodayURL = @TODAY_DEF;
static NSString *const CityURL = @CITY_DEF;
static NSString *const TermURL = @TERM_DEF;
static NSString *const TenseURL = @TENSE_DEF;
static NSString *const LastfmIDURL = @LASTFM_ID_DEF;
static NSString *const SongkickIDURL = @SONGKICK_ID_DEF;

//static NSString *const userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate


#endif
