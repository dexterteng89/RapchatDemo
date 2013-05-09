//
//  BRUser.m
//  BattleRap
//
//  Created by Henry Dearborn on 5/9/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRUser.h"
#import "SSKeychain.h" //using for persistent, secure key-value storage of userID, pass, token

#define SERVICE_NAME @"PassTheMic"
#define USER_ID_KEY @"username"
#define PASSWORD_KEY @"password"
#define AUTH_TOKEN_KEY @"auth_token"

@interface BRUser ()

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)secureValueForKey:(NSString *)key;

@end

@implementation BRUser

#pragma mark - Custom getters

- (NSString *)userID
{
}

- (NSString *)password
{
    
}

- (NSString *)authToken
{
    
}

#pragma mark - Custom setters

- (void)setUserID:(NSString *)userID
{
    [self setSecureValue:userID forKey:USER_ID_KEY];
}

- (void)setPassword:(NSString *)password
{
    [self setSecureValue:password forKey:PASSWORD_KEY];
}

- (void)setAuthToken:(NSString *)authToken
{
    [self setSecureValue:authToken forKey:AUTH_TOKEN_KEY];
    // TODO: code for authToken changed, allows auto-login
}

#pragma mark - SSKeychain universal getter/setter

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key
{
    if (value) {
        [SSKeychain setPassword:value forService:SERVICE_NAME account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME account:key];
    }
}

- (NSString *)secureValueForKey:(NSString *)key
{
    return [SSKeychain passwordForService:SERVICE_NAME account:key];
}

@end
