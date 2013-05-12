//
//  BRAPIClient.m
//  BattleRap
//
//  Created by Henry Dearborn on 5/7/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "BRUser.h"

static NSString * const kBRHTTPClientBaseURLString = @"http://rapchat-staging.herokuapp.com/";
static NSString * const kBRHTTPClientTestBaseURLString = @"http://ptm-upload-test.herokuapp.com/";

@implementation BRHTTPClient

#pragma mark - Singleton

+ (BRHTTPClient *)sharedClient
{
    static BRHTTPClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[BRHTTPClient alloc] initWithBaseURL:
                        [NSURL URLWithString:kBRHTTPClientTestBaseURLString]];
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
    NSLog(@"sign in called");
    
    NSDictionary *params = @{@"user": @{
                                         @"username" : handle,
                                         @"password" : password}
                             };
    
    
    [self postPath:@"users/sign_in"
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               NSString *authToken = [[responseObject objectForKey:@"data"] objectForKey:@"auth_token"];
               
               NSLog(@"JSON: %@", responseObject);
               NSLog(@"Pulled Auth token: %@", authToken);
               NSLog(@"Saved Auth token: %@", [[BRUser currentUser] authToken]);
               
               [[BRUser currentUser] updateCurrentUserWith:handle
                                                     email:nil
                                                  password:password
                                                 authToken:authToken];
               
               NSLog(@"sign in successful");
                              
               NSLog(@"Username: %@", [[BRUser currentUser] userID]);

               
               success((AFJSONRequestOperation *)operation, responseObject);
               
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"sign in failed");
        NSLog(@"%@", [error localizedDescription]);

        if (operation.response.statusCode == 500) 
            NSLog(@"reponse code: 500");

    }];
    
    // Setup POST request with postPath:
        // in request's success block: instantiate current user, set auth_token,
        // call method's success block
        // in failure block, call method's failure block
    
    // [self clearAuthorizationHeader]
}

- (void)signUpWithHandle:(NSString *)handle
                   email:(NSString *)email
                password:(NSString *)password
                 success:(BRHTTPClientSuccess)success
                 failure:(BRHTTPClientFailure)failure
{
    NSLog(@"sign up called");
    
    NSDictionary *params = @{@"handle" : handle,
                           @"password" : password,
                              @"email" : email};
    
    [self postPath:@"users/sign_in"
        parameters:params
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               
               NSString *authToken = [responseObject objectForKey:@"auth_token"];
               
               NSLog(@"%@", authToken);
               
               [[BRUser currentUser] updateCurrentUserWith:handle
                                                     email:nil
                                                  password:password
                                                 authToken:authToken];
               
               NSLog(@"sign up successful");
               
               success((AFJSONRequestOperation *)operation, responseObject);
               
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               NSLog(@"sign up failed");
           }];
}

- (void)signOutWithSuccess:(BRHTTPClientSuccess)success failure:(BRHTTPClientFailure)failure
{
    NSDictionary *params = @{@"auth_token": [[BRUser currentUser] authToken]};
    
    [self deletePath:@"users/sign_out" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"Signout JSON:%@", responseObject);
        
        [[BRUser currentUser] updateCurrentUserWith:nil
                                              email:nil
                                           password:nil
                                          authToken:nil];
        success((AFJSONRequestOperation *)operation, responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Log out failed. Error: %@", [error localizedDescription]);
        failure((AFJSONRequestOperation *)operation, (NSError *)error);
    }];
    
}


@end
