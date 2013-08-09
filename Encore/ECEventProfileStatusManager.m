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
    [ECJSONFetcher checkIfConcert:self.eventID isOnProfile:[NSUserDefaults userID] completion:^(BOOL isOnProfile) {
        [self.delegate profileState:isOnProfile];
        self.isOnProfile = isOnProfile;
    }];
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
                [self.delegate successChangingState:self.isOnProfile];
            }
            else {
                [self.delegate failedToChangeState:self.isOnProfile];
            }
        }];
    }
}
@end
