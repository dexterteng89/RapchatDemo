//
//  BRBattleStore.h
//  BattleRap
//
//  Created by Dexter Teng on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BRVerse.h"

@interface BRBattleStore : NSObject
{
    NSMutableArray *battles;
    NSMutableArray *users;
}

+ (BRBattleStore *)sharedStore;

- (void)populateUsersWithArray:(NSMutableArray *)data;
- (void)populateBattlesWithArray:(NSMutableArray *)data;

- (void)createBattleWith:(NSString *)friendName;
- (void)addBattleWith:(NSString *)friendName;
- (void)updateBattleWith:(NSInteger)battleID andWith:(BRVerse *)verse;

@end
