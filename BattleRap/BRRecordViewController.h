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

@interface BRRecordViewController : UIViewController <AVAudioRecorderDelegate,
AVAudioPlayerDelegate, UIAppearanceContainer>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    int timerCount;
}


@property (nonatomic, strong) AVAudioPlayer *backgroundbeat;
@property (nonatomic, copy) void (^dismissBlock) (void);
@property (weak, nonatomic) IBOutlet UIToolbar *sendTool;

@property (weak, nonatomic) UIButton *recordPauseButton;    
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (nonatomic) BOOL recordingComplete;
@property (nonatomic, strong) NSTimer *timer;
- (IBAction)submitVerse:(id)sender;
- (IBAction)retryVerse:(id)sender;

- (void)recordPauseTapped;
- (void)stopRecording;
- (void)playbackRecording;
- (IBAction)convertAndSendTapped:(id)sender;

- (void)fadeText;
- (void)updateCountdown;

@end
