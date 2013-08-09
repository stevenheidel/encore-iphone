//
//  ECEventProfileStatusManager.h
//  Encore
//
//  Created by Shimmy on 2013-08-08.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ECEventProfileStatusManagerDelegate <NSObject>
-(void) profileState: (BOOL) isOnProfile;
-(void) successChangingState: (BOOL) isOnProfile;
-(void) failedToChangeState: (BOOL) isOnProfile;

@end

@interface ECEventProfileStatusManager : NSObject
-(void) checkProfileState;
-(void) toggleProfileState;

@property (nonatomic, copy) NSString* eventID;
@property (nonatomic, unsafe_unretained) id <ECEventProfileStatusManagerDelegate> delegate;
@property (nonatomic,assign) BOOL isOnProfile;
@end
