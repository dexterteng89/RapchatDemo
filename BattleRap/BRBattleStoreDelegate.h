//
//  BRBattleStoreDelegate.h
//  BattleRap
//
//  Created by Dexter Teng on 4/21/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BRBattleStoreDelegate <NSObject>

- (void) usersDidFinishPostingUsers:(NSMutableArray *)users;
- (void) usersDidFinishPostingBattles:(NSMutableArray *)battles;

@end
