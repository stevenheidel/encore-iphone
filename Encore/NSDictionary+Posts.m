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
    NSString *url = [self objectForKey:@"image_url"];
    if (![url isKindOfClass:[NSNull class]] && url.length > 0) {
        return [NSURL URLWithString:url];
    } else {
        return nil;
    }
}

-(NSString *) userName {
    return [self objectForKey:@"user_name"];
}

-(NSURL *) profilePictureURL {
    if ([self objectForKey:@"user_profile_picture"] != [NSNull null]) {
        return [NSURL URLWithString:[self objectForKey:@"user_profile_picture"]];
    }
    return nil;
}

-(NSString *) caption {
    id returnString = [self objectForKey:@"caption"];
    return returnString == [NSNull null] ? @"" : returnString;
}

-(NSString*) postID {
    return [self objectForKey:@"id"];
}

-(ECPostType) postType {
    NSString* type =  [self objectForKey:@"type"];
    if ([type isEqualToString:@"photo"]) {
        return ECPhotoPost;
    }
    if ([type isEqualToString:@"video"]){
        return ECVideoPost;
    }
    return ECPhotoPost;// default
}

-(NSURL*) youtubeLink {
    return [NSURL URLWithString:[self objectForKey:@"youtube_link"]];
}
@end
