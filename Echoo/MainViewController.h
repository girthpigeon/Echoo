//
//  MainViewController.h
//  Echoo
//
//  Created by Admin on 2/18/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface MainViewController : UIViewController
    <CLLocationManagerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
    AVAudioSession *audioSession;
    AVAudioRecorder *recorder;
    NSString *docsDir;
    NSString *audioFileName;
    NSURL *url;
}

@property (strong, nonatomic) NSString *userid;
@end
