//
//  BRVerse.h
//  BattleRap
//
//  Created by Dexter Teng on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRVerse : NSObject

@property (strong, nonatomic) NSData *audioClip;
@property (assign, nonatomic) NSInteger round;
@property (strong, nonatomic) NSString *name;

@end
