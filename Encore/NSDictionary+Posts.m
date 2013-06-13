//
//  NSDictionary+Posts.m
//  Encore
//
//  Created by Shimmy on 2013-06-13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import "NSDictionary+Posts.h"

@implementation NSDictionary (Posts)
-(NSURL *) imageURL {
    return [NSURL URLWithString:[self objectForKey:@"image_url"] ];
}

-(NSString *) userName {
    return [self objectForKey:@"user_name"];
}

-(NSURL *) profilePictureURL {
    return [NSURL URLWithString:[self objectForKey:@"user_profile_picture"]];
}

-(NSString *) caption {
    return [self objectForKey:@"caption"];
}
@end
