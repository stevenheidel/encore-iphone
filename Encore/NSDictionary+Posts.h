//
//  NSDictionary+Posts.h
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ECPostType.h"

@interface NSDictionary (Posts)
-(NSURL *) imageURL;
-(NSString *) userName;
-(NSURL *) profilePictureURL;
-(NSString *) caption;
-(NSString *) postID;
-(ECPostType) postType;
@end
