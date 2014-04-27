//
//  ECEventProfileStatusManager.m
//  Encore
//
//  Created by Shimmy on 2013-08-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "ECEventProfileStatusManager.h"
#import "ECJSONFetcher.h"
#import "ECJSONPoster.h"
#import "NSUserDefaults+Encore.h"
#import <Crashlytics/Crashlytics.h>

@implementation ECEventProfileStatusManager

-(void) checkProfileState {
    NSString* userID = [NSUserDefaults userID]; //only check if the userID is not null (null if not logged in)
    //alternatively could check if logged in, but this is essentially the same result; can't check if on profile without an id
    if(userID){
        if (self.delegate == nil) {
            CLS_LOG(@"Delegate is nil");
        }
        if (self.eventID.length == 0) {
            CLS_LOG(@"Event ID is nil");
        }
        
        [ECJSONFetcher checkIfConcert:self.eventID isOnProfile:userID completion:^(BOOL isOnProfile) {
            if ([self.delegate respondsToSelector: @selector(profileState:)]) {
                [self.delegate profileState:isOnProfile];
            }
            self.isOnProfile = isOnProfile;
        }];
    }
    else if ([self.delegate respondsToSelector:@selector(profileState:)]){
        [self.delegate profileState:NO];
    }
}

-(void) toggleProfileState {
    if(self.isOnProfile) {
        [ECJSONPoster removeConcert:self.eventID toUser:[NSUserDefaults userID] completion:^(BOOL success) {
            if (success) {
                self.isOnProfile = !self.isOnProfile;
                if ([self.delegate respondsToSelector:@selector(successChangingState:)]) {
                    [self.delegate successChangingState:self.isOnProfile];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(failedToChangeState:)]) {
                    [self.delegate failedToChangeState:self.isOnProfile];
                }
            }
        }];
    }
    else {
        [ECJSONPoster addConcert:self.eventID toUser:[NSUserDefaults userID] completion:^(BOOL success) {
            if (success) {
                self.isOnProfile = !self.isOnProfile;
                if([self.delegate respondsToSelector:@selector(successChangingState:)]) {
                    [self.delegate successChangingState:self.isOnProfile];
                }
            }
            else {
                if ([self.delegate respondsToSelector:@selector(failedToChangeState:)]) {
                    [self.delegate failedToChangeState:self.isOnProfile];
                }
            }
        }];
    }
}
@end
