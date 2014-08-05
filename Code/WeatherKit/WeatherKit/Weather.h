//
//  Weather.h
//  WeatherKit
//
//  Created by Jesse Torres on 8/3/14.
//  Copyright (c) 2014 Jesse Torres. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Weather : NSObject
@property (nonatomic, strong) NSString *dt;
@property (nonatomic, strong) NSString *pressure;
@property (nonatomic, strong) NSString *humidity;
@property (nonatomic, strong) NSString *speed;
@property (nonatomic, strong) NSString *clouds;
@property (nonatomic, strong) NSDictionary *temp;
@end
