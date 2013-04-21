//
//  BRRecordViewController.m
//  BattleRap
//
//  Created by Henry Dearborn on 4/20/13.
//  Copyright (c) 2013 Henry Dearborn. All rights reserved.
//

#import "BRRecordViewController.h"
#import "SCUI.h"

@implementation BRRecordViewController
@synthesize dismissBlock;

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
    
    // Disable Stop/Play button when application launches
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
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

- (IBAction)recordPauseTapped:(id)sender {
    NSLog(@"RecordPause tapped");
    
    
    
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
        [self.backgroundbeat stop];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
        
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [self playBackgroundMusic:@"cyclebeat"];
        [self.recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [self.backgroundbeat stop];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
}

- (IBAction)stopTapped:(id)sender {
    NSLog(@"Stop tapped");
    
    [recorder stop];
    [self.backgroundbeat stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:YES];
}

- (IBAction)playTapped:(id)sender {
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

//- (IBAction)convertAndSendTapped:(id)sender
//{
//    //    NSDictionary *someDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Dexter", @"handle", nil];
//    //
//    //    NSDictionary *topDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:someDictionary, @"user", nil];
//    
//    //http://4nmq.localtunnel.com
//    //NSURL *url = [NSURL URLWithString:@"http://4c3k.localtunnel.com/users.json"];
//    //http://rapchat-assets.s3.amazonaws.com/ << S3 thing
//    //    NSData *file1Data = [NSJSONSerialization dataWithJSONObject:topDictionary options:0 error:&error];
//    
//    NSData *file1Data = [[NSData alloc] initWithContentsOfURL:recorder.url];
//    
////    NSString* newStr = [NSString stringWithUTF8String:[file1Data bytes]];
////    
////    NSMutableString *jsonRequest = [[NSMutableString alloc]init];
////    [jsonRequest appendString:newStr];
////    
////    NSData *requestData = [NSData dataWithBytes:[jsonRequest UTF8String] length:[jsonRequest length]];
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"FILL IN THIS"]];
//    
//    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:[NSString stringWithFormat:@"%d", [file1Data length]] forHTTPHeaderField:@"Content-Length"];
//    [request setHTTPBody: file1Data];
//    
//    [NSURLConnection connectionWithRequest:request delegate:self];
//    
//}

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


@end
