//
//  Echoo.h
//  Echoo
//
//  Created by Admin on 3/5/14.
//  Copyright (c) 2014 Echoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Echoo : NSObject

@property (nonatomic,assign) int echooId;
@property (nonatomic,assign) int userId;
@property (nonatomic,strong) NSString* address;
@property (nonatomic,strong) NSString* city;
@property (nonatomic,strong) NSString* country;
@property (nonatomic,strong) NSString* state;
@property (nonatomic,assign) int zipcode;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString* filepath;
@property (nonatomic,assign) float latitude;
@property (nonatomic,assign) float longitude;
@property (nonatomic,strong) NSString* PhoneNumber;

- (id)initWithParams:(NSDictionary *) dic;

@end
