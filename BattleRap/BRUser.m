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
#define EMAIL_KEY @"email"

// Global instance of current user (pseudo-singleton)

@interface BRUser ()

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key;
- (NSString *)secureValueForKey:(NSString *)key;

@end


@implementation BRUser
@synthesize userID, password, authToken, email;

#pragma mark - Singleton methods

+ (BRUser *)currentUser
{
    static BRUser *currentUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        currentUser = [[self alloc] init];
    });
    return currentUser;
}

- (id)init
{
    if (self = [super init]) {
        userID = [self userID];
        password = [self password];
        authToken = [self authToken];
        email = [self email];
    }
    return self;
}


#pragma mark - Custom getters

- (NSString *)userID
{
    return [self secureValueForKey:USER_ID_KEY];
}

- (NSString *)password
{
    return [self secureValueForKey:PASSWORD_KEY];
}

- (NSString *)authToken
{
    return [self secureValueForKey:AUTH_TOKEN_KEY];
}

- (NSString *)email
{
    return [self secureValueForKey:EMAIL_KEY];
}

#pragma mark - Custom setters

- (void)setUserID:(NSString *)handle
{
    [self setSecureValue:handle forKey:USER_ID_KEY];
}

- (void)setPassword:(NSString *)pass
{
    [self setSecureValue:pass forKey:PASSWORD_KEY];
}

- (void)setAuthToken:(NSString *)token
{
    [self setSecureValue:token forKey:AUTH_TOKEN_KEY];
    // TODO: code for authToken changed, allows auto-login
}

- (void)setEmail:(NSString *)mail
{
    [self setSecureValue:mail forKey:EMAIL_KEY];
}

- (void)updateCurrentUserWith:(NSString *)handle
                        email:(NSString *)mail
                     password:(NSString *)pass
                    authToken:(NSString *)token
{
    [self setUserID:handle];
    [self setEmail:mail];
    [self setPassword:pass];
    [self setAuthToken:token];
}

#pragma mark - SSKeychain universal getter/setter

- (void)setSecureValue:(NSString *)value forKey:(NSString *)key
{
    if (value) {
        [SSKeychain setPassword:value forService:SERVICE_NAME account:key];
    } else {
        [SSKeychain deletePasswordForService:SERVICE_NAME account:key];
        NSLog(@"credential deleted: %@", key);
    }
}

- (NSString *)secureValueForKey:(NSString *)key
{
    return [SSKeychain passwordForService:SERVICE_NAME account:key];
}


@end
