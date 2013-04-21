//
//  BRBattleStore.m
//  BattleRap
//
//  Created by Dexter Teng on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRBattleStore.h"

@implementation BRBattleStore

+ (BRBattleStore *)sharedStore
{
    static BRBattleStore *sharedStore = nil;
    if (!sharedStore)
    {
        sharedStore = [[super allocWithZone:nil] init];
    }
    
    return sharedStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)createBattleWith:(NSString *)friendName
{
    
}

- (void)updateBattleWith:(NSInteger)battleID andWith:(BRVerse *)verse
{
    
}

- (void)populateUsersWithArray:(NSMutableArray *)data
{
    users = data;
}

- (void)populateBattlesWithArray:(NSMutableArray *)data
{
    battles = data;
}

@end
