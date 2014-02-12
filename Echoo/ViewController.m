//
//  ViewController.m
//  Audio Upload Demo
//
//  Created by Admin on 1/16/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"KeychainTest" accessGroup:nil];
    
    if ([keychain objectForKey:(__bridge id)(kSecAttrAccount)]) {
        // existing value
    } else {
        // no existing value
    int userid = [self createNewUser];
        NSLog(@"new userid is: %ld", (long)userid);
    }
    
    //NSString *username = self.username_textarea.text;
    //NSString *password = self.password_textarea.text;
    //NSString *password2 = self.password2_textarea.text;
    
    //if([password2 isEqualToString:password]){
        //do call  to server
    //}
    
    //if user already has an account remember it
    
    //if not then allow user to create a new account or continue annonymously
    
    //otherwise create new user
    
    
}

- (int)createNewUser {
    //NSString *latitude = [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.latitude];
    //NSString *longitude = [[NSString alloc] initWithFormat:@"%g", currentLocation.coordinate.longitude];
    
    NSURL *url2 = [NSURL URLWithString:@"http://kwipp.com/echoo/php/register.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url2];
    request.HTTPMethod = @"POST";
    NSString *post = [NSString stringWithFormat:@"&loginname=%@&loginpassword=%@&dbUrl=%@&db=%@", loginname, loginpassword, dbUrl, db];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    request.HTTPBody = postData;
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler:
     ^(NSURLResponse *r, NSData *data, NSError *error) {
         NSLog(@"response: %@", r);
     }];
    
    int *userid = 0;
    return *userid;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
