//
//  BRRecordViewController.h
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface BRRecordViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}


@property (nonatomic, strong) AVAudioPlayer *backgroundbeat;
@property (nonatomic, copy) void (^dismissBlock) (void);

@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;



- (IBAction)recordPauseTapped:(id)sender;
- (IBAction)stopTapped:(id)sender;
- (IBAction)playTapped:(id)sender;
- (IBAction)convertAndSendTapped:(id)sender;

@end
