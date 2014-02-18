//
//  MainViewController.m
//  Echoo
//
//  Created by Admin on 2/18/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController (){
    
}

@end

@implementation MainViewController

- (IBAction)RecordButtonPushed:(id)sender {
    NSError *error;
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    [audioSession setActive:YES error: &error];
    
    audioFileName = @"tempAudio";
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    url = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:[NSString stringWithFormat: @"tempAudio.caf"]]];
    //url = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@",audioFileName, @"caf"]]];
    
    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    [settings setValue :[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
stringByAppendingComponent: [NSString stringWithFormat: @"%@.%@", audioFileName, @"caf"];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
    [recorder setDelegate: self];
    
    if(!recorder.recording){
        [recorder prepareToRecord];
        [recorder record];
        NSLog(@"Recording Audio: Recording");
    } else {
        //Failed
    }

}

- (IBAction)RecordButtonReleased:(id)sender {
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
