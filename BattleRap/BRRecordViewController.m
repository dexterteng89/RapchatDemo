//
//  BRRecordViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRRecordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SCUI.h"

@interface BRRecordViewController()
{
    int timerCount;
}
@property (nonatomic) double recordDuration; 
- (void)clearAndReset;
- (void)hideToolbar;
- (void)showToolbar;
@end

@implementation BRRecordViewController 
@synthesize dismissBlock, timer, recordPauseButton,
            recordingComplete, sendToolbar, recordDuration;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"BRRecordViewController" bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"New Verse";
        
        self.navigationItem.rightBarButtonItem =
            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                         target:self
                                                         action:@selector(cancelBattle:)];
    }
    return self;
}

#pragma mark - UIViewController Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //create play/pause button
    
    CGRect buttonFrame = CGRectMake(82, 230, 157, 157);
    recordPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordPauseButton setImage:[UIImage imageNamed:@"RecordButton.png"]
                       forState:UIControlStateNormal];
    recordPauseButton.frame = buttonFrame;
    [recordPauseButton addTarget:self action:@selector(controlButtonTapped:)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordPauseButton];

    // Have toolbar start offscreen
    sendToolbar.hidden = YES;
    [self hideToolbar];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"verse.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];

    
    // Setup audio session
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    
    // UNCOMMENT WHEN RUNNUNG ON PHONE - Overrides speaker settings so plays through speaker
//    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                             sizeof(audioRouteOverride),&audioRouteOverride);
    
    // Setup Background Beat
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:
                      [[NSBundle mainBundle] pathForResource:@"noreclip" ofType:@"wav"]];
    
    self.backgroundbeat = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    self.backgroundbeat.volume = 1.0;
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    [recorder prepareToRecord];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action methods

- (void)controlButtonTapped:(id)sender {
    NSLog(@"RecordPause tapped");
    
    if (!recorder.recording && !recordingComplete) {
        // Start recording
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        // Text fade kicks of countdown sequence
        [self fadeText];
    } else if (recordingComplete) {
        [self playbackRecording];
    } else {
        // cancel recording
        [self stopRecording];
    }
}

- (IBAction)submitVerse:(id)sender {
}

- (IBAction)convertAndSendTapped:(id)sender
{
    NSURL *trackURL = recorder.url;
    
    SCShareViewController *shareViewController;
    SCSharingViewControllerCompletionHandler handler;
    
    handler = ^(NSDictionary *trackInfo, NSError *error) {
        if (SC_CANCELED(error)) {
            NSLog(@"Canceled!");
        } else if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            NSLog(@"Uploaded track: %@", trackInfo);
        }
    };
    shareViewController = [SCShareViewController
                           shareViewControllerWithFileURL:trackURL
                           completionHandler:handler];
    [shareViewController setTitle:@"RAP BATTLE"];
    [shareViewController setPrivate:YES];
    [self presentModalViewController:shareViewController animated:YES];
}


- (void)stopRecording {
    // Capture recording time before stop. Stop method resets to zero.
    recordDuration = recorder.currentTime;
    [recorder stop];
    [recorder deleteRecording];
    [self.backgroundbeat stop];
}

- (void)playbackRecording {
    NSLog(@"Play tapped");
    
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (void)clearAndReset
{
    self.instructionsLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:32.0];
    self.instructionsLabel.text = @"RETRY YOUR VERSE";
    [recordPauseButton setImage:[UIImage imageNamed:@"RecordButton.png"]
                       forState:UIControlStateNormal];
    recordingComplete = NO;
    timerCount = 0;
    recordDuration = 0; 
    self.backgroundbeat.currentTime = 0;
    NSLog(@"reset complete");
}

- (IBAction)retryVerse:(id)sender {
    NSLog(@"retry attempted");
    [self clearAndReset];
    [self hideToolbar];
}

- (void)cancelBattle:(id)sender
{
    if (recorder.recording) {
        [self stopRecording];
    } else if (player.playing) {
        [player stop];
    }
    
    // TBD: code for setting battle object data to nil
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:dismissBlock];
}

- (void)playBackgroundMusic:(NSString *)beatChoice
{
    // Beat selection code goes here (will like occur in another view)
    //
    //    [self.backgroundbeat play];
}

#pragma mark - Animation Methods

- (void)fadeText
{
    CABasicAnimation *textFade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    textFade.fromValue = @1.0;
    textFade.toValue = @0.0;
    textFade.delegate = self;
    textFade.duration = 0.2;
    textFade.removedOnCompletion = NO;
    //    CAMediaTimingFunction *tf = [CAMediaTimingFunction
    //                                 functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //    pulseFade.timingFunction = tf;
    
    [textFade setValue:@"textFade" forKey:@"id"];
    [self.instructionsLabel.layer addAnimation:textFade forKey:@"textFade"];
}

- (void)fadeInOutText
{
    CAKeyframeAnimation *fadeInAndOut = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    fadeInAndOut.duration = 1.0;
    fadeInAndOut.autoreverses = NO;
    fadeInAndOut.keyTimes = [NSArray arrayWithObjects:  [NSNumber numberWithFloat:0.0],
                             [NSNumber numberWithFloat:0.15],
                             [NSNumber numberWithFloat:0.85],
                             [NSNumber numberWithFloat:1.0], nil];
    
    fadeInAndOut.values = [NSArray arrayWithObjects:    [NSNumber numberWithFloat:0.0],
                           [NSNumber numberWithFloat:1.0],
                           [NSNumber numberWithFloat:1.0],
                           [NSNumber numberWithFloat:0.0], nil];
    fadeInAndOut.beginTime = 0.0;
    fadeInAndOut.fillMode = kCAFillModeBoth;
    [self.instructionsLabel.layer addAnimation:fadeInAndOut forKey:@"fadeInOut"];
}

- (void)hideToolbar
{
    [UIView animateWithDuration:0.2
                     animations:^(void)
     {
         CGRect toolbarFrame = sendToolbar.frame;
         toolbarFrame.origin.y += 44; // moves toolbar offscreen
         sendToolbar.frame = toolbarFrame;
     }
                     completion:^(BOOL finished)
     {
         sendToolbar.hidden = YES;
     }];
}

- (void)showToolbar
{
    [UIView animateWithDuration:0.2
                     animations:^(void)
     {
         sendToolbar.hidden = NO;
         CGRect toolbarFrame = sendToolbar.frame;
         toolbarFrame.origin.y -= 44; // moves toolbar offscreen
         sendToolbar.frame = toolbarFrame;
     }
                     completion:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"%@ finished: %d", anim, flag);
    
    //begin timer that initiates countdown and repeats 3x
    if ([[anim valueForKey:@"id"] isEqualToString:@"textFade"]) {
        NSLog(@"animation did stop");
        timer = [NSTimer timerWithTimeInterval:1.0
                                        target:self
                                      selector:@selector(updateCountdown)
                                      userInfo:nil
                                       repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        self.instructionsLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:42.0];
        self.instructionsLabel.text = @"3";
        [self fadeInOutText];
    }
}

- (void)updateCountdown
{
    timerCount++;
    self.instructionsLabel.textAlignment = NSTextAlignmentCenter;
    
    NSLog(@"count updated");
    if (timerCount > 3) {
        [timer invalidate];
        timer = nil;
    } else if (timerCount == 1) {
        [self fadeInOutText];
        self.instructionsLabel.text = @"2";
        
    } else if (timerCount == 2) {
        self.instructionsLabel.text = @"1";
        [self fadeInOutText];
        [self.backgroundbeat prepareToPlay];
    } else if (timerCount == 3) {
        [recorder recordForDuration:self.backgroundbeat.duration];
        [self.backgroundbeat play];
        [self.recordPauseButton setImage:[UIImage imageNamed:@"CancelRecButton.png"]
                                forState:UIControlStateNormal];
        self.instructionsLabel.text = @"RAP!";
    }
    
}

#pragma mark - AVAudioRecorder/AVAudioPlayer Delegates

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder
                            successfully:(BOOL)flag
{
    // Check if complete recording was made. Duration goes to zero when
    // recording complete
    if (recordDuration > 0) {
        NSLog(@"Recording duration: %f", recordDuration);
        [self clearAndReset];
    } else {
        [self.recordPauseButton setImage:[UIImage imageNamed:@"PlayRecButton.png"]
                                forState:UIControlStateNormal];
        
        self.instructionsLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:32.0];
        self.instructionsLabel.text = @"REVIEW YOUR VERSE";
        
//        sendToolbar.hidden = NO;
        [self showToolbar];
        recordingComplete = YES;
    }
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}


- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
//                                                    message: @"Finish playing the recording!"
//                                                   delegate: nil
//                                          cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil];
//    [alert show];
}

@end
