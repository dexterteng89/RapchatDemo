//
//  BRRecordViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRRecordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCUI.h"

@implementation BRRecordViewController
@synthesize dismissBlock, timer, recordPauseButton, recordingComplete, sendTool;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"BRRecordViewController" bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"New Verse";
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBattle)];
        
        self.navigationItem.rightBarButtonItem = cancelButton;

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //create play/pause button
    
    CGRect buttonFrame = CGRectMake(82, 230, 157, 157);
    recordPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordPauseButton setImage:[UIImage imageNamed:@"RecordButton.png"] forState:UIControlStateNormal];
    recordPauseButton.frame = buttonFrame;
    [recordPauseButton addTarget:self action:@selector(recordPauseTapped)
                forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordPauseButton];
    
    //BG for UIToolbar - couldnt get to work
//    UIImage *toolbarBG = [[UIImage imageNamed:@"UIToolbarBG.png"]
//                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//
//    [[UIToolbar appearance] setBackgroundImage:toolbarBG
//                            forToolbarPosition:1
//                                    barMetrics:UIBarMetricsDefault];
//    //Buttons for uitoolbar
//    UIButton *retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    retryButton.frame = CGRectMake(0, 0, 70, 38);
//    UIImage *retryBtnImage = [UIImage imageNamed:@"retryButton.png"];
//    [retryButton setImage:retryBtnImage forState:UIControlStateNormal];
////    [retryBtnImage addTarget:self action:@selector(resetCriteria:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    retryButton.frame = CGRectMake(0, 0, 70, 38);
//    UIImage *sendBtnImage = [UIImage imageNamed:@"sendButton.png"];
//    [sendButton setImage:sendBtnImage forState:UIControlStateNormal];
//    //    [retryBtnImage addTarget:self action:@selector(resetCriteria:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [retryButton setTitle:@"Retry" forState:UIControlStateNormal];
//    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
//
//    
//    UIBarButtonItem *retryItem = [[UIBarButtonItem alloc] initWithCustomView:retryButton];
//    UIBarButtonItem *sendItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
//    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    
//    
//    [retryItem setTitle:@"Retry"];
//    
//    NSArray *barItems = [NSArray arrayWithObjects:retryItem, fixed, sendItem, nil];    
//    [self setToolbarItems:barItems animated:YES];
//
    sendTool.hidden = YES;
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"verse.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
}


- (void)playBackgroundMusic:(NSString *)beatChoice
{
    NSString *path = [[NSBundle mainBundle] pathForResource:beatChoice ofType:@"wav"];
    
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    
    self.backgroundbeat = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    
    self.backgroundbeat.volume = 1.0;
    
    [self.backgroundbeat prepareToPlay];
    
    [self.backgroundbeat play];
}

- (IBAction)submitVerse:(id)sender {
}

- (IBAction)retryVerse:(id)sender {
    NSLog(@"retry attempted");
    recordingComplete = NO;
    [self.recordPauseButton setImage:[UIImage imageNamed:@"PlayRecButton.png"]
                            forState:UIControlStateNormal];

}

- (void)recordPauseTapped {
    NSLog(@"RecordPause tapped");
    
    
    
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
        [self.backgroundbeat stop];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
        
    }
    
    if (!recorder.recording && !recordingComplete) {
        // Start recording
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        [self fadeText];
        
    } else if (recordingComplete) {
        [self playbackRecording];
        
    } else {
        
        // cancel recording
        [recorder stop];
        [recorder deleteRecording];
        [self.backgroundbeat stop];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }

}

- (void)stopRecording {
    NSLog(@"recording stopped");
    
    [recorder stop];
    [self.backgroundbeat stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordPauseButton setImage:[UIImage imageNamed:@"PlayRecButton.png"]
                            forState:UIControlStateNormal];
    
    self.instructionsLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:32.0];
    self.instructionsLabel.text = @"REVIEW YOUR VERSE";
    
    sendTool.hidden = NO;
    recordingComplete = YES;
    
}

- (void)playbackRecording {
    NSLog(@"Play tapped");
    
    if (!recorder.recording){
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
    }
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark - Private methods

- (void)cancelBattle
{
    //code for setting battle object data to nil
    
    [self.presentingViewController dismissViewControllerAnimated:YES
                                                      completion:dismissBlock];
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

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"%@ finished: %d", anim, flag);
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
    } else if (timerCount == 3) {
        [recorder record];
        [self playBackgroundMusic:@"noreclip"];
        NSTimer *playTimer = [NSTimer timerWithTimeInterval:9.89
                                                     target:self
                                                   selector:@selector(stopRecording)
                                                   userInfo:nil
                                                    repeats:NO];
       [[NSRunLoop currentRunLoop] addTimer:playTimer forMode:NSRunLoopCommonModes];
       [self.recordPauseButton setImage:[UIImage imageNamed:@"CancelRecButton.png"]
                                forState:UIControlStateNormal];
        self.instructionsLabel.text = @"RAP!";
    }
    
}


@end
