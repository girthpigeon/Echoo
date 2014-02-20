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

@synthesize userid;

- (IBAction)RecordButtonPushed:(id)sender {
    
    NSError *error;
    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"dd-MM-yyyy-HH-mm-ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    NSLog(@"current date: %@", newDateString);
    
    //begin audioSession
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    [audioSession setActive:YES error: &error];
    
    audioFileName = [NSString stringWithFormat: @"%@_%@", userid, newDateString];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    url = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:[NSString stringWithFormat: @"%@.%@", audioFileName, @"m4a"]]];
  
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                                    [NSNumber numberWithFloat:16000.0], AVSampleRateKey,
                                    [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                    nil];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    if(!recorder){
        NSLog(@"recorder initialization error");
    }
    [recorder setDelegate: self];
    recorder.meteringEnabled = YES;
    
    if(!recorder.recording){
        [recorder prepareToRecord];
        [recorder record];
        NSLog(@"Recording Audio: Recording");
    } else {
        //Failed
    }

}

- (IBAction)RecordButtonReleased:(id)sender {
    NSError *error;
    if(recorder.recording){
        [recorder stop];
        [audioSession setActive:NO error:&error];
        NSLog(@"Stopped Recording Audio");
    }
}
- (IBAction)playAudio:(id)sender {
    if(!recorder.recording){
        if(player){
            //[player release];
        } else {NSError *error;
            player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
            player.delegate = self;
            
            if (error)
                NSLog(@"Error: %@", [error localizedDescription]);
            else
                [player play];
        }
    }
}

- (void)getCurrentLocation:(id)sender {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil){
        _longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        _latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            _addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                  placemark.subThoroughfare, placemark.thoroughfare,
                                  placemark.postalCode, placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    //Reverse geocoding
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            _addressLabel.text = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                  placemark.subThoroughfare, placemark.thoroughfare,
                                  placemark.postalCode, placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.country];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
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
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
