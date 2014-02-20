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
    AVAudioPlayer *player;
    
    NSString *docsDir;
    NSString *audioFileName;
    NSURL *url;
    NSURL *outputFileURL;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *currentLocation;
    
    NSString *address;
    NSString *longitude;
    NSString *latitude;
    
}

@property (strong, nonatomic) NSString *userid;
//@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
//@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;
//@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;

@end
