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
#include "Echoo.h"

@interface MainViewController : UIViewController
    <CLLocationManagerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate>
{
    AVAudioSession *audioSession;
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    
    NSString *docsDir;
    NSString *audioFileName;
    NSURL *url;
    NSURL *outputFileURL;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
    
    NSString *date;
    NSString *address;
    NSString *country;
    NSString *state;
    NSString *city;
    NSString *zip;
    NSString *longitude;
    NSString *latitude;
    
    bool locationFound;
}

@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) AVPlayer *echooPlayer;
@end
