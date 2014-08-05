//
//  DetailViewController.h
//  WeatherKit
//
//  Created by Jesse Torres on 8/3/14.
//  Copyright (c) 2014 Jesse Torres. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Weather.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Weather* detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *highTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTempLabel;
@property (weak, nonatomic) IBOutlet UILabel *windLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UILabel *cloudsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;

@end
