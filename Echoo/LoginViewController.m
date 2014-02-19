//
//  ViewController.m
//  Audio Upload Demo
//
//  Created by Admin on 1/16/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

NSString *name = @"user1";
NSString *password = @"password1";
NSString *dbUrl = @"mysql2.snhosting.net";
NSString *loginname = @"kwipp_admin";
NSString *loginpassword = @"328x4_5y934";
NSString *db = @"kwipp_echoo";
KeychainItemWrapper *keychain;
//ViewController *loginViewController = [ViewController animated:YES completion: nil];

- (void)viewDidLoad {
    [super viewDidLoad];
    //LoginViewController *loginViewController = self;
    //create a familiar keychain
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
    
    [keychain resetKeychainItem];
    NSString *tempId = [keychain objectForKey:(__bridge id)(kSecAttrAccount)];
    NSLog(@"length: %lu", (unsigned long)tempId);
    
    //they have previously made a userid
        if([tempId length] > 0){
            userid = tempId;
            //NSLog(@"%@, %@", [keychain objectForKey:(__bridge id)(kSecAttrAccount)], [keychain objectForKey:(__bridge id)(kSecValueData)]);
            NSLog(@"returning user. id: %@", userid);
            
            //redirect to main screen
            //[self performSegueWithIdentifier:@"loginToMain"];
            [self performSegueWithIdentifier:@"ShowMainView" sender:self];
            //NSString *storyboardName = @"MainStoryboard";
            //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
            //UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
            //[self ViewController:vc animated:YES completion:nil];
             
    //first time logging in
    } else {
        userid = [self createNewUser];
        [keychain setObject:userid forKey:(__bridge id)(kSecAttrAccount)];
        [keychain setObject:password forKey:(__bridge id)(kSecValueData)];
        NSLog(@"New user's id: %@", [keychain objectForKey:(__bridge id)(kSecAttrAccount)]);
    }
    
    //change to main screen
    
    //allow them an opportunity to set their username and password in the settings
    
    //NSString *username = self.username_textarea.text;
    //NSString *password = self.password_textarea.text;
    //NSString *password2 = self.password2_textarea.text;
    
    
}

- (NSString*)createNewUser {
   // __block NSString *returnString;
    NSURL *url2 = [NSURL URLWithString:@"http://kwipp.com/echoo/php/register.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url2];
    request.HTTPMethod = @"POST";
    NSString *post = [NSString stringWithFormat:@"&loginname=%@&loginpassword=%@&dbUrl=%@&db=%@&name=%@&password=%@", loginname, loginpassword, dbUrl, db, name, password];
    NSLog(@"post: %@", post);
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    //NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    request.HTTPBody = postData;
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    // Log Response
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    NSLog(@"new response: %@",response);
    return response;
    
    //[NSURLConnection sendAsynchronousRequest: request
    //                                   queue: [NSOperationQueue mainQueue]
    //                       completionHandler:
     //^(NSURLResponse *r, NSData *data, NSError *error) {
     //    returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
     //    [keychain setObject:returnString forKey:(__bridge id)(kSecAttrAccount)];
      //   userid = [returnString copy];
      //  NSLog(@"response: %@", returnString);
     //}];
    NSLog(@"returnString: %@", userid);
    return userid;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Preparing for Segue");
    if ([segue.identifier isEqualToString:@"ShowMainView"]) {
        //NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MainViewController *destViewController = segue.destinationViewController;
        destViewController.userid = userid;
        NSLog(@"Segueing to MainViewController");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
