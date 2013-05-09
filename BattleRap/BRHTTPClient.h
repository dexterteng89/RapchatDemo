//
//  BRAPIClient.h
//  BattleRap
//
//  Created by Henry Dearborn on 5/7/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "AFNetworking.h"

// Typedefs to make calling blocks easier
typedef void (^BRHTTPClientSuccess)(AFJSONRequestOperation *operation, id responseObject);
typedef void (^BRHTTPClientFailure)(AFJSONRequestOperation *operation, NSError *error);

@interface BRHTTPClient : AFHTTPClient

+ (BRHTTPClient *)sharedClient;

#pragma mark - USER METHODS

- (void)signInWithHandle:(NSString *)handle password:(NSString *)password success:(BRHTTPClientSuccess)success failure:(BRHTTPClientFailure)failure;
- (void)signUpWithHandle:(NSString *)handle email:(NSString *)email password:(NSString *)password success:(BRHTTPClientSuccess)success failure:(BRHTTPClientFailure)failure;

@end
