//
//  BRAPIClient.m
//  BattleRap
//
//  Created by Henry Dearborn on 5/7/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRHTTPClient.h"
#import "AFJSONRequestOperation.h"

static NSString * const kBRHTTPClientBaseURLString = @"http://rapchat-staging.herokuapp.com/";

@implementation BRHTTPClient

#pragma mark - Singleton

+ (BRHTTPClient *)sharedClient
{
    static BRHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BRHTTPClient alloc] initWithBaseURL:
                        [NSURL URLWithString:kBRHTTPClientBaseURLString]];
    });
    return _sharedClient;
}

#pragma mark - NSObject

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    self.parameterEncoding = AFJSONParameterEncoding;
    
    //TODO: add as observer for "tokenChanged" notification
    
    return self;
}

#pragma mark - User Login

- (void)signInWithHandle:(NSString *)handle
                password:(NSString *)password
                 success:(BRHTTPClientSuccess)success
                 failure:(BRHTTPClientFailure)failure
{
    // Set params dictionary
    
    // Set authorization header
    
    // Setup POST request with postPath:
        // in request's success block: instantiate current user, set auth_token,
        // call method's success block
        // in failure block, call method's failure block
    
    // [self clearAuthorizationHeader]
}

// Passive, token-based sign-in for reopening app
- (void)signInWithAuthToken:(NSString *)token
                    success:(BRHTTPClientSuccess)success
                    failure:(BRHTTPClientFailure)failure
{
    // Basically the same content at sign-in with auth_token for params instead of
    // handle and password
}


@end
