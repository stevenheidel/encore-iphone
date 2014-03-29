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

@implementation ECEventProfileStatusManager

-(void) checkProfileState {
    NSString* userID = [NSUserDefaults userID]; //only check if the userID is not null (null if not logged in)
    //alternatively could check if logged in, but this is essentially the same result; can't check if on profile without an id
    if(userID){
        [ECJSONFetcher checkIfConcert:self.eventID isOnProfile:userID completion:^(BOOL isOnProfile) {
            if (self.delegate) {
                [self.delegate profileState:isOnProfile];
            }
            self.isOnProfile = isOnProfile;
        }];
    }
    else {
        [self.delegate profileState:NO];
    }
}

-(void) toggleProfileState {
    if(self.isOnProfile) {
        [ECJSONPoster removeConcert:self.eventID toUser:[NSUserDefaults userID] completion:^(BOOL success) {
            if (success) {
                self.isOnProfile = !self.isOnProfile;
                [self.delegate successChangingState:self.isOnProfile];
            }
            else {
                [self.delegate failedToChangeState:self.isOnProfile];
            }
        }];
    }
    else {
        [ECJSONPoster addConcert:self.eventID toUser:[NSUserDefaults userID] completion:^(BOOL success) {
            if (success) {
                self.isOnProfile = !self.isOnProfile;
                if(self.delegate) {
                    [self.delegate successChangingState:self.isOnProfile];
                }
            }
            else {
                if (self.delegate) {
                    [self.delegate failedToChangeState:self.isOnProfile];
                }
            }
        }];
    }
}
@end
