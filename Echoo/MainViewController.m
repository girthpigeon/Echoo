//
//  MainViewController.m
//  Echoo
//
//  Created by Admin on 2/18/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize userid;

- (IBAction)ListenButtonPushed:(id)sender {
    //check current gps coords
    [self getCurrentLocation:self];
    longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
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

    
    //fetch the user's nearness settings (for starters just make this constant
    NSMutableArray *echooArray = [self findEchoos];
    
    //if within range, return the audio
    
    //if not within range, return the next closest 3 within a max radius
}

-(NSMutableArray*)findEchoos {
    //float distance = 1.6000000; //1 mile
    float distance = 5.0000000; //a little under 3 miles
    //float distance = 1609.344; //1000 miles for testing
    float radius = distance / 6371; //earths diameter in km (Constant)
    NSLog(@"radius: %.10f", radius);
    float latF = [latitude floatValue];
    float lonF = [longitude floatValue];
    float latMIN = latF - radius;
    float latMAX = latF + radius;
    //float latT = asinf(sinf(latF)/cosf(radius));
    float lonChange = asinf(sinf(radius)/cosf(latF));
    float lonMAX = lonF + lonChange;
    float lonMIN = lonF - lonChange;
    
    NSString *dbUrl = @"mysql2.snhosting.net";
    NSString *loginname = @"kwipp_admin";
    NSString *loginpassword = @"328x4_5y934";
    NSString *db = @"kwipp_echoo";
    
    NSURL *url2 = [NSURL URLWithString:@"http://kwipp.com/echoo/php/findEchoos.php"];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL: url2];
    request2.HTTPMethod = @"POST";
    NSString *post = [NSString stringWithFormat:@"&latitude=%f&longitude=%f&latMIN=%f&latMAX=%f&lonMAX=%f&lonMIN=%f&date=%@&loginname=%@&loginpassword=%@&db=%@&dbUrl=%@&userid=%@", latF, lonF, latMIN, latMAX, lonMAX, lonMIN, date, loginname, loginpassword, db, dbUrl, userid];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    request2.HTTPBody = postData;
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request2 returningResponse: nil error: nil];
    // Log Response
    NSError *error;
    //NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    NSArray *responseArray = [json objectForKey:@"echoos"];
    
    NSLog(@"EchooFind Return: %@", responseArray);
    
    //we now have an array of all the echoos found within the radius. They are sorted by date.
    //we should go through this array and play the one that we are closest to.
    Echoo *closestEchoo;
    float smallestDistance = MAXFLOAT;
    float currentDistance = MAXFLOAT;
    NSMutableArray *echooArray = [[NSMutableArray alloc] init];
    for(NSDictionary * dic in responseArray){
        
        Echoo* tempEchoo = [[Echoo alloc] initWithParams: dic];
        currentDistance = (fabsf(latF - tempEchoo.latitude) + fabsf(lonF - tempEchoo.longitude))/2;
        if(currentDistance < smallestDistance){
            smallestDistance = currentDistance;
            closestEchoo = tempEchoo;
        }
        [echooArray addObject:tempEchoo];
    }
    
   //play audio automatically for the closest echoo.

    NSLog(@"filepath: %@", closestEchoo.filepath);
    [self playEchoo:closestEchoo];
    
    return echooArray;
}

- (void)playEchoo:(Echoo*) tempEchoo {
    
    AVPlayer *songPlayer = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:tempEchoo.filepath]];

    self.echooPlayer = songPlayer;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.echooPlayer currentItem]];
    [self.echooPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
}

-(void)updateProgress {
    //NSLog(@"updating Progress: %ld", (long)self.echooPlayer.currentItem.status);
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.echooPlayer && [keyPath isEqualToString:@"status"]) {
        if (self.echooPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
        } else if (self.echooPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self.echooPlayer play];
            
            
        } else if (self.echooPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    NSLog(@"End of sound file");
    
}


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
    
    audioFileName = [NSString stringWithFormat: @"%@_%@.m4a", userid, date];
    
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
        
        [self getCurrentLocation:self];
            //[NSThread sleepForTimeInterval:5.0];
        longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
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
        
        NSLog(@"longitude: %@",longitude);
        if(country != nil){
            
        }
            [self upload:self];
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
    locationFound = false;
    
    //initialize variables
    //latitude = @"";
    //longitude = @"";
    //country = @"";
    //state = @"";
    //zip = @"";
    //city = @"";
    //address = @"";
    
    
    
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
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *r, NSData *data, NSError *error) {
         NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         NSLog(@"AudioUploadString: %@", returnString);
     }];


    NSURL *url2 = [NSURL URLWithString:@"http://kwipp.com/echoo/php/uploadEchoo.php"];
    NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL: url2];
    request2.HTTPMethod = @"POST";
    NSString *post = [NSString stringWithFormat:@"&latitude=%@&longitude=%@&country=%@&state=%@&city=%@&zip=%@&address=%@&audioFileName=%@&date=%@&loginname=%@&loginpassword=%@&db=%@&dbUrl=%@&userid=%@", latitude, longitude, country, state, city, zip, address, audioFileName, date, loginname, loginpassword, db, dbUrl, userid];
    
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    request2.HTTPBody = postData;

    [NSURLConnection sendAsynchronousRequest: request2
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *r, NSData *data, NSError *error) {
         NSString *returnString2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

         NSLog(@"EchooUpload String: %@", returnString2);
     }];
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
    
    [self getCurrentLocation:self];
    //[NSThread sleepForTimeInterval:5.0];
    longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
    latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
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


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
