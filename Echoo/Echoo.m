//
//  Echoo.m
//  Echoo
//
//  Created by Admin on 3/5/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import "Echoo.h"


@implementation Echoo {
    
}

- (id) initWithParams:(NSDictionary*) dic
{
    self = [self init];
    if (self){
        _filepath = (NSString*) [dic objectForKey:@"filepath"];
        _userId = (int) [dic objectForKey:@"userid"];
        _echooId = (int) [dic objectForKey:@"id"];
        _latitude = [[dic objectForKey:@"latitude"] floatValue];
        _longitude = [[dic objectForKey:@"longitude"] floatValue];
        _zipcode = (int)[dic objectForKey:@"zip"];
        _address = (NSString*)[dic objectForKey:@"address"];
        _city = (NSString*)[dic objectForKey:@"city"];
        _state = (NSString*)[dic objectForKey:@"state"];
        _country = (NSString*)[dic objectForKey:@"country"];
        _date = (NSString*)[dic objectForKey:@"date"];
    }
    return self;
}


@end
