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
#define BASE_URL_DEF "http://armadillo.rewrite.c66.me/api/v1/"
#else
#define BASE_URL_DEF "http://192.168.11.15:3000/api/v1/"
#endif

#define BASE_URL_PUBLIC_DEF "http://armadillo.rewrite.c66.me/"

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
static NSString *const ShareConcertURL = @BASE_URL_PUBLIC_DEF EVENTS_DEF "/%@";
static NSString *const SharePostURL = @BASE_URL_PUBLIC_DEF POSTS_DEF "/%@";

//User's concerts
static NSString *const UserConcertsURL = @BASE_URL_DEF USERS_DEF "/%@/" EVENTS_DEF; //,facebook id

//Popular concerts
static NSString *const PastPopularConcertsURL = @EVENTS_DEF "/" PAST_DEF JSON_DEF;
static NSString *const FuturePopularConcertsURL = @EVENTS_DEF "/" FUTURE_DEF JSON_DEF;
static NSString *const TodayPopularConcertsURL = @EVENTS_DEF "/" TODAY_DEF JSON_DEF;

//Artists and Concerts combo
static NSString *const ArtistConcertComboURL = @ARTISTS_DEF "/" SEARCH_DEF JSON_DEF;

//Artists
static NSString *const ArtistSearchURL = @BASE_URL_DEF ARTISTS_DEF "/" SEARCH_DEF TERM_DEF "%@"; //, searchStr
static NSString *const ArtistConcertSearchPastURL = @BASE_URL_DEF ARTISTS_DEF "/%@/" EVENTS_DEF "/" PAST_DEF "?" CITY_DEF "%@"; //, artistID, userLocation
static NSString *const ArtistConcertSearchFutureURL = @BASE_URL_DEF ARTISTS_DEF "/%@/" EVENTS_DEF "/" FUTURE_DEF "?" CITY_DEF "%@"; //artistID, , userLocation


//purposely left out base url, get is initialized with base url
static NSString *const ArtistCombinedSearchURL = @ARTISTS_DEF "/" COMBINED_SEARCH_DEF JSON_DEF;

//Posts
static NSString *const ConcertPostsURL = @BASE_URL_DEF EVENTS_DEF "/%@/" POSTS_DEF ; //,concertID
static NSString *const FlagPostURL = @POSTS_DEF "/%@/" FLAG_DEF JSON_DEF; //,postID
//Concert Check
static NSString *const CheckConcertOnProfileURL = @USERS_DEF "/%@/" EVENTS_DEF JSON_DEF;

#pragma mark - Posting
//static NSString *const ;
//Add concert to User
static NSString* const AddConcertToUserURL = @USERS_DEF "/%@/" EVENTS_DEF; //,userID
static NSString* const RemoveConcertFromUserURL = @USERS_DEF "/%@/" EVENTS_DEF "/%@"; //,userID, concertID
static NSString* const PostImageURL = @EVENTS_DEF "/%@/" POSTS_DEF;

#pragma mark - Check populating
static NSString* const CheckEventPopulatingURL = @BASE_URL_DEF EVENTS_DEF "/%@/" POPULATING_DEF; //,eventID

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
