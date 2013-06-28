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
#define BASE_URL_DEF "http://staging.encoretheapp.com/api/v1/"
#else
#define BASE_URL_DEF "http://192.168.11.15:9283/api/v1/"
#endif

#define BASE_URL_PUBLIC_DEF "http://staging.encoretheapp.com/"

#define CONCERTS_DEF "concerts"
#define USERS_DEF "users"
#define POSTS_DEF "posts"
#define SEARCH_DEF "search?term="
#define ARTISTS_DEF "artists"
#define PAST_DEF "past"
#define FUTURE_DEF "future"
#define TODAY_DEF "today"
#define CITY_DEF "city="
#define SONGKICK_ID_DEF "songkick_id"


#define MAX_ERROR_LEN 200

static NSString *const BaseURL = @BASE_URL_DEF;
//URLS

//Sharing
static NSString *const ShareConcertURL = @BASE_URL_PUBLIC_DEF CONCERTS_DEF "/%@";
static NSString *const SharePostURL = @BASE_URL_PUBLIC_DEF POSTS_DEF "/%@";

//User's concerts
static NSString *const UserConcertsURL = @BASE_URL_DEF USERS_DEF "/%@/" CONCERTS_DEF; //,facebook id

//Popular concerts
static NSString *const PastPopularConcertsURL = @BASE_URL_DEF CONCERTS_DEF "/" PAST_DEF "?" CITY_DEF "%@"; //,userLocation
static NSString *const FuturePopularConcertsURL = @BASE_URL_DEF CONCERTS_DEF "/" FUTURE_DEF "?" CITY_DEF "%@"; //,userLocation
static NSString *const TodayPopularConcertsURL = @BASE_URL_DEF CONCERTS_DEF "/" TODAY_DEF "?" CITY_DEF "%@"; //,userLocation

//Artists
static NSString *const ArtistSearchURL = @BASE_URL_DEF ARTISTS_DEF "/" SEARCH_DEF "%@"; //, searchStr
static NSString *const ArtistConcertSearchPastURL = @BASE_URL_DEF ARTISTS_DEF "/%@/" CONCERTS_DEF "/" PAST_DEF "?" CITY_DEF "%@"; //, artistID, userLocation
static NSString *const ArtistConcertSearchFutureURL = @BASE_URL_DEF ARTISTS_DEF "/%@/" CONCERTS_DEF "/" FUTURE_DEF "?" CITY_DEF "%@"; //artistID, , userLocation

//Posts
static NSString *const ConcertPostsURL = @BASE_URL_DEF CONCERTS_DEF "/%@/" POSTS_DEF ; //,concertID

//Concert Check
static NSString *const CheckConcertOnProfileURL = @BASE_URL_DEF USERS_DEF "/%@/" CONCERTS_DEF "?" SONGKICK_ID_DEF "=" "%@"; // , userID, ConcertID

#pragma mark - Posting
//static NSString *const ;
//Add concert to User
static NSString* const AddConcertToUserURL = @USERS_DEF "/%@/" CONCERTS_DEF; //,userID
static NSString* const RemoveConcertFromUserURL = @USERS_DEF "/%@/" CONCERTS_DEF "/%@"; //,userID, concertID
static NSString* const PostImageURL = @CONCERTS_DEF "/%@/" POSTS_DEF;

#pragma mark - Components
static NSString *const UsersURL = @USERS_DEF;
static NSString *const ConcertsURL = @CONCERTS_DEF;
static NSString *const PostsURL = @POSTS_DEF;
static NSString *const SearchURL = @SEARCH_DEF;
static NSString *const ArtistsURL = @ARTISTS_DEF;
static NSString *const PastURL = @PAST_DEF;
static NSString *const FutureURL = @FUTURE_DEF;
static NSString *const TodayURL = @TODAY_DEF;
static NSString *const CityURL = @CITY_DEF;
static NSString *const SongkickIDURL = @SONGKICK_ID_DEF;

//static NSString *const userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate


#endif
