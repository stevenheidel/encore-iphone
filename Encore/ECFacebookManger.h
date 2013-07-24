//
//  ECFacebookManger.h
//  Encore
//
//  Created by Mohamed Fouad on 7/24/13.
//  Copyright (c) 2013 Encore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ECFacebookManger : NSObject

+ (ECFacebookManger *)sharedFacebookManger;

- (BOOL)loginUserWithCompletionHandler:(void(^)(NSError* error))handler;
- (void)logout;

- (void)fetchUserInformation:(void(^)(NSDictionary *userInfo))handler;
- (void)requestWithGraphPath:(NSString*) path completionHandler:(void(^)(NSDictionary *userInfo))handler;

- (BOOL)handleOpenURL:(NSURL *)url;
- (void)handleDidBecomeActive;

- (NSString *)accessToken;
- (NSDate *)expirationDate;

- (BOOL)isLoggedIn;
- (void)displayShareDialogFrom:(id)controller initialText:(NSString*)text image:(UIImage*)image url:(NSURL*)url completionHandler:(void(^)(NSError* error))handler;
@end
