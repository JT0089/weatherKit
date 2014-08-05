//
//  DetailViewController.m
//  WeatherKit
//
//  Created by Jesse Torres on 8/3/14.
//  Copyright (c) 2014 Jesse Torres. All rights reserved.
//

#import "DetailViewController.h"
#import "OpenWeather.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(OpenWeather *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

// Update the user interface for the detail item.
- (void)configureView
{
    if (self.detailItem) {
        
        NSDictionary* weatherInfo = self.detailItem.weather[0];

        // Weather Image
        NSString *weatherImageURL = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", [weatherInfo objectForKey:@"icon"]];
        
        // Asynchronous so it does not block the UI thread.
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: weatherImageURL]];
            if ( imageData == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage * image = [[UIImage alloc] initWithData:imageData];
                [self.weatherImage setImage:image];
            });
        });
        
        // Description
        NSString* description = [NSString stringWithFormat:@"%@", [weatherInfo objectForKey:@"description"]];
        self.descriptionLabel.text = [description capitalizedString];
        
        // High Temp
        int highTemp = (int)([[self.detailItem.temp objectForKey:@"max"] doubleValue] + 0.5);
        NSString* highTempText = [NSString stringWithFormat:@"%i\u00B0", highTemp];
        self.highTempLabel.text = highTempText;

        // Low Temp
        int lowTemp = (int)([[self.detailItem.temp objectForKey:@"min"] doubleValue] + 0.5);
        NSString* lowTempText = [NSString stringWithFormat:@"%i\u00B0", lowTemp];
        self.lowTempLabel.text = lowTempText;
        
        // Wind MPH
        int wind = (int)([self.detailItem.speed doubleValue] + 0.5);
        self.windLabel.text = [NSString stringWithFormat:@"%i mph",wind];

        // Humidity %
        int humidity = (int)([self.detailItem.humidity doubleValue] + 0.5);
        self.humidityLabel.text = [NSString stringWithFormat:@"%d%%", humidity];
        
        // Clouds %
        int clouds = (int)([self.detailItem.clouds doubleValue] + 0.5);
        self.cloudsLabel.text = [NSString stringWithFormat:@"%d%%", clouds];
        
        // Pressure mmHg
        int pressure = (int)([self.detailItem.pressure doubleValue] + 0.5);
        self.pressureLabel.text = [NSString stringWithFormat:@"%i mmHg", pressure];
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
