//
//  ViewController.h
//  Echoo
//
//  Created by Admin on 2/11/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeychainItemWrapper.h"

@interface ViewController : UIViewController
{
    NSString *loginname;
    NSString *loginpassword;
    NSString *dbUrl;
    NSString *db;
}
@property (strong, nonatomic) IBOutlet UITextField *username_textarea;
@property (strong, nonatomic) IBOutlet UITextField *password_textarea;
@property (strong, nonatomic) IBOutlet UITextField *password2_textarea;

@end
