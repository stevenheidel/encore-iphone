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

@implementation ECEventProfileStatusManager

-(void) checkProfileState {
    [ECJSONFetcher checkIfConcert:self.eventID isOnProfile:self.userID completion:^(BOOL isOnProfile) {
        [self.delegate profileState:isOnProfile];
    }];
}

-(void) toggleProfileState {
    if(self.isOnProfile) {
        [ECJSONPoster removeConcert:self.eventID toUser:self.userID completion:^(BOOL success) {
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
        [ECJSONPoster addConcert:self.eventID toUser:self.userID completion:^(BOOL success) {
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
