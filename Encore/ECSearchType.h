//
//  ECSearchType.h
//  Encore
//
//  Created by Shimmy on 2013-06-27.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#ifndef Encore_ECSearchType_h
#define Encore_ECSearchType_h

typedef enum {
    ECSearchTypePast = 1, //not sure why I did this but don't change it
    ECSearchTypeToday,
    ECSearchTypeFuture
} ECSearchType;

static NSString* const TenseStrPast = @"Past";
static NSString* const TenseStrFuture = @"Future";
static NSString* const TenseStrToday = @"Today";
static NSString* const TenseStr = @"Tense";
#endif
