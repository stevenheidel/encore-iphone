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
static NSString *const BaseURL = @"http://staging.encoretheapp.com/api/v1/";
#else
static NSString *const BaseURL = @"http://192.168.11.15:9283/api/v1/";
#endif
static NSString *const UsersURL = @"users";
static NSString *const ConcertsURL = @"concerts";
static NSString *const PostsURL = @"posts";
static NSString *const SearchURL = @"search?term=";
static NSString *const ArtistsURL = @"artists";
static NSString *const PastURL = @"past";
static NSString *const FutureURL = @"future";
static NSString *const TodayURL = @"today";
static NSString *const CityURL = @"city=";
static NSString *const SongkickIDURL = @"songkick_id";

//static NSString *const userLocation = @"Toronto"; //TODO: Get location dynamically from app delegate
#endif
