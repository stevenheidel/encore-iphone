//
//  ECLoadStatus.h
//  Encore
//
//  Created by Simon Bromberg on 2014-05-06.
//  Copyright (c) 2014 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECSearchType.h"
typedef enum {
    StatusNothingYet,
    StatusFailed,
    StatusSuccess
} ECLoadStatusTag;

@interface ECLoadStatus : NSObject
-(id) initWithSearchType: (ECSearchType) type;
@property (nonatomic,assign) BOOL hasLaunched;
@property (nonatomic,assign) ECLoadStatusTag statusTag;
@end

@interface ECLoadStatusManager : NSObject
-(void) updateTag: (ECLoadStatusTag) statusTag ForType: (ECSearchType) type;
-(ECLoadStatusTag) statusTagForType: (ECSearchType) type;
-(void) updateLaunchState: (BOOL) launchState forType: (ECSearchType) type;
-(BOOL) launchStateForType: (ECSearchType) type;

@end