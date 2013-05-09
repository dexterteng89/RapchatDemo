//
//  BRUser.h
//  BattleRap
//
//  Created by Henry Dearborn on 5/9/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *authToken;

@end
