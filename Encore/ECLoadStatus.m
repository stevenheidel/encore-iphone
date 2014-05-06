//
//  ECLoadStatus.m
//  Encore
//
//  Created by Simon Bromberg on 2014-05-06.
//  Copyright (c) 2014 Encore. All rights reserved.
//

#import "ECLoadStatus.h"

@implementation ECLoadStatus
-(id) init {
    if (self = [self initWithSearchType:ECSearchTypeToday]) {
        
    }
    NSLog(@"invalid initialization of ECLoadStatus!! Defaulting to today");
    return self;
}
-(id) initWithSearchType:(ECSearchType)type {
    if (self = [super init]) {
        self.statusTag = StatusNothingYet;
        self.hasLaunched = NO;
    }
    return self;
}

@end

@interface ECLoadStatusManager() {
    ECLoadStatus* past;
    ECLoadStatus* today;
    ECLoadStatus* future;
}

@end

@implementation ECLoadStatusManager
-(id) init {
    if (self = [super init]) {
        past = [[ECLoadStatus alloc] initWithSearchType:ECSearchTypePast];
        today = [[ECLoadStatus alloc] initWithSearchType:ECSearchTypeToday];
        future = [[ECLoadStatus alloc] initWithSearchType:ECSearchTypeFuture];
    }
    return self;
}

-(ECLoadStatus*) loadStatusObjectForType: (ECSearchType) type {
    switch (type) {
        case ECSearchTypePast:
            return past;
        case ECSearchTypeToday:
            return today;
        case ECSearchTypeFuture:
            return future;
        default:
            return nil;
    }
}

-(void) updateLaunchState:(BOOL)launchState forType:(ECSearchType)type {
    [self loadStatusObjectForType:type].hasLaunched = launchState;
}

-(BOOL) launchStateForType:(ECSearchType)type {
    return [self loadStatusObjectForType:type].hasLaunched;
}

-(void) updateTag:(ECLoadStatusTag)statusTag ForType:(ECSearchType)type {
    [self loadStatusObjectForType:type].statusTag = statusTag;
}

-(ECLoadStatusTag) statusTagForType:(ECSearchType)type {
    return [self loadStatusObjectForType:type].statusTag;
}

@end