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
    date = [outputFormatter stringFromDate:now];
    //NSLog(@"current date: %@", newDateString);
    
    //begin audioSession
    audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    [audioSession setActive:YES error: &error];
    
    audioFileName = [NSString stringWithFormat: @"%@_%@", userid, date];
    
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
    
    [self getCurrentLocation:self];
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
    locationFound = false;
    
    //initialize variables
    latitude = @"";
    longitude = @"";
    country = @"";
    state = @"";
    zip = @"";
    city = @"";
    address = @"";
    
    
    
    [locationManager startUpdatingLocation];
    [NSThread sleepForTimeInterval:5.0];
    [self upload:self];
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
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    currentLocation = newLocation;
    
    if (currentLocation != nil){
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    
    // Stop Location Manager
    [locationManager stopUpdatingLocation];
    
    //NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            country = placemark.country;
            state = placemark.administrativeArea;
            zip = placemark.postalCode;
            city = placemark.locality;
            address = [NSString stringWithFormat:@"%@, %@", placemark.subThoroughfare, placemark.thoroughfare];
            /*address = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                  placemark.subThoroughfare, placemark.thoroughfare,
                                  placemark.postalCode, placemark.locality,
                                  placemark.administrativeArea,
                                  placemark.country];*/
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
/*    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            country = placemark.country;
            state = placemark.administrativeArea;
            zip = placemark.postalCode;
            city = placemark.locality;
            address = [NSString stringWithFormat:@"%@, %@", placemark.subThoroughfare, placemark.thoroughfare];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
*/
    //locationFound = true;
}

- (IBAction)upload:(id)sender {
    NSString *dbUrl = @"mysql2.snhosting.net";
    NSString *loginname = @"kwipp_admin";
    NSString *loginpassword = @"328x4_5y934";
    NSString *db = @"kwipp_echoo";
    
    NSData *file1Data = [[NSData alloc] initWithContentsOfURL:recorder.url];
    NSString *urlString = @"http://kwipp.com/echoo/php/uploadAudio.php";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];

    //setup parms
    NSMutableDictionary *_params = [[NSMutableDictionary alloc] init];
    [_params setObject:loginname forKey:@"loginname"];
    [_params setObject:loginpassword forKey:@"loginpassword"];
    [_params setObject:dbUrl forKey:@"dbUrl"];
    [_params setObject:db forKey:@"db"];
    [_params setObject:userid forKey:@"userid"];
    
    //echoo info
    
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
  
    //audioFilePart
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\r\n",audioFileName]] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:file1Data]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSLog(@"AudioUpload String= %@",returnString);
    
        NSMutableData *body2 = [NSMutableData data];
    
    [_params setObject:latitude forKey:@"latitude"];
    [_params setObject:longitude forKey:@"longitude"];
    [_params setObject:country forKey:@"country"];
    [_params setObject:state forKey:@"state"];
    [_params setObject:zip forKey:@"zip"];
    [_params setObject:city forKey:@"city"];
    [_params setObject:address forKey:@"address"];
    [_params setObject:audioFileName forKey:@"audioFileName"];
    [_params setObject:date forKey:@"date"];
    
    // add params (all params are strings)
    for (NSString *param in _params) {
        [body2 appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body2 appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body2 appendData:[[NSString stringWithFormat:@"%@\r\n", [_params objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //[body2 appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *urlString2 = @"http://kwipp.com/echoo/php/uploadEchoo.php";
    
    NSMutableURLRequest *request2 = [[NSMutableURLRequest alloc] init];
    [request2 setURL:[NSURL URLWithString:urlString2]];
    [request2 setHTTPMethod:@"POST"];
    
    [request2 addValue:contentType forHTTPHeaderField: @"Content-Type"];

    [request2 setHTTPBody:body2];
    
    NSData *returnData2 = [NSURLConnection sendSynchronousRequest:request2 returningResponse:nil error:nil];
    NSString *returnString2 = [[NSString alloc] initWithData:returnData2 encoding:NSUTF8StringEncoding];
    
    NSLog(@"EchooUpload String2= %@",returnString2);
    
    
    //NSString *latitude = [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.latitude];
    //NSString *longitude = [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.longitude];
/*
    NSURL *url2 = [NSURL URLWithString:@"http://kwipp.com/echoo/php/uploadEchoo.php"];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL: url2];
    request2.HTTPMethod = @"POST";
    NSString *post = [NSString stringWithFormat:@"&latitude=%@&longitude=%@", latitude, longitude];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    request2.HTTPBody = postData;
    [NSURLConnection sendAsynchronousRequest: request2
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *r, NSData *data, NSError *error) {
         NSLog(@"response: %@", r);
     }];
 */
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
