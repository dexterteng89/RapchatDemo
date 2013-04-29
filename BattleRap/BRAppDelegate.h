//
//  BRAppDelegate.h
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRAppDelegate : UIResponder <UIApplicationDelegate, UIAppearanceContainer>

@property (strong, nonatomic) UIWindow *window;

- (void)applyStylesheet;

@end
