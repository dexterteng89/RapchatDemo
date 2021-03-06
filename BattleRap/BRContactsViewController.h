//
//  BRContactsViewController.h
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRRecordViewController;

@interface BRContactsViewController : UITableViewController
{
    NSArray *userHandles;
    BRRecordViewController *recordViewController;
}

@property (nonatomic, strong) NSIndexPath *checkedIndexPath;
@property (nonatomic, copy) void (^dismissBlock) (void);

@end
