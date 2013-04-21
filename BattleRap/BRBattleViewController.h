//
//  BRBattleViewController.h
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BRBattleViewController : UITableViewController
<AVAudioPlayerDelegate>

@property (nonatomic) BOOL playing;
@property (nonatomic, strong) AVAudioPlayer *audio;

- (void)playVerseForRowAtIndexPath:(NSIndexPath *)path;

@end
