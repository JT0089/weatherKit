//
//  DetailViewController.m
//  WeatherKit
//
//  Created by Jesse Torres on 8/3/14.
//  Copyright (c) 2014 Jesse Torres. All rights reserved.
//

#import "DetailViewController.h"
#import "Weather.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(Weather *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        // image http://openweathermap.org/img/w/10d.png
        NSString * description = [NSString stringWithFormat:@"Pressure: %@\r Humidity: %f%%\r Max: %@",
                                  self.detailItem.pressure,
                                  [self.detailItem.humidity doubleValue],
                                  [self.detailItem.temp objectForKey:@"max"]
                                  ];
        self.detailDescriptionLabel.numberOfLines = 0;
        self.detailDescriptionLabel.text = description;
        self.highTempLabel.text = [self.detailItem.temp objectForKey:@"max"];
        self.lowTempLabel.text = [self.detailItem.temp objectForKey:@"min"];
        self.windLabel.text = self.detailItem.speed;
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
