//
//  MasterViewController.m
//  WeatherKit
//
//  Created by Jesse Torres on 8/3/14.
//  Copyright (c) 2014 Jesse Torres. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <RestKit/RestKit.h>
#import "OpenWeather.h"

@interface MasterViewController ()
    @property (nonatomic, strong) NSArray *openWeathers;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureRestKit];
    [self loadWeather];

}

// Configure Rest Query
- (void)configureRestKit
{
    // Setup BaseURL
    NSURL *baseURL = [NSURL URLWithString:@"http://api.openweathermap.org"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // Initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // Setup main mappings
    RKObjectMapping *openWeatherMapping = [RKObjectMapping mappingForClass:[OpenWeather class]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"dt"]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"pressure"]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"humidity"]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"speed"]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"clouds"]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"weather"]];
    [openWeatherMapping addAttributeMappingsFromArray:@[@"temp"]];
    
    // Register mappings with the provider.
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:openWeatherMapping
                                                method:RKRequestMethodGET
                                                pathPattern:@"/data/2.5/forecast/daily"
                                                keyPath:@"list"
                                                statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

// Get Weather Data
- (void)loadWeather
{
    NSString *cityState = @"Irvine,CA";
    NSString *count = @"7";
    NSString *units = @"imperial";
    NSString *mode = @"json";
    NSDictionary *queryParams = @{@"q" : cityState,
                                  @"cnt" : count,
                                  @"units" : units,
                                  @"mode" : mode
                                  };
    
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/data/2.5/forecast/daily"
                                           parameters:queryParams
                                              success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                                  _openWeathers = mappingResult.array;
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"No weather found: %@", error);
                                              }];
    // Get City from lookup
    NSString *title = [NSString stringWithFormat:@"%s Forecast", "Irvine, CA"];
    self.navigationItem.title = title;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _openWeathers.count;
}

// Fill Row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    // Remove > from right side of cell
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    OpenWeather *openWeather = _openWeathers[indexPath.row];
    
    // Initialize Labels
    // Day of Week
    NSTimeInterval ticks = [openWeather.dt doubleValue];
    NSDate *time = [NSDate dateWithTimeIntervalSince1970: ticks];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE"];
    NSString *dayOfWeek = [dateFormat stringFromDate:time];
    UILabel *lblDayOfWeek = [[UILabel alloc]initWithFrame:CGRectMake(20,0,cell.frame.size.width,cell.frame.size.height)];
    lblDayOfWeek.font = [UIFont systemFontOfSize:20];
    lblDayOfWeek.text = dayOfWeek;
    [cell addSubview:lblDayOfWeek];
    
    // High & Low Temp
    int highTemp = [self convertStringToRoundedInt:[openWeather.temp objectForKey:@"max"]];
    int lowTemp = [self convertStringToRoundedInt:[openWeather.temp objectForKey:@"min"]];
    NSString* tempText = [NSString stringWithFormat:@"%i\u00B0 \\ %i\u00B0", highTemp, lowTemp];

    UILabel *lblTemps = [[UILabel alloc]initWithFrame:CGRectMake(cell.frame.size.width - 100,0,100,cell.frame.size.height)];
    lblTemps.textAlignment = NSTextAlignmentCenter;
    lblTemps.font = [UIFont systemFontOfSize:20];
    lblTemps.text = tempText;
    [cell addSubview:lblTemps];
    
    // Weather Image
    NSDictionary* weatherInfo = openWeather.weather[0];
    NSString *weatherImageURL = [NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png", [weatherInfo objectForKey:@"icon"]];
    UIImageView *imgWeatherIcon = [[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.size.width - 180,0,50,cell.frame.size.height)];
    
    // Set Weather Image Asynchronous so it does not block the UI thread.
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: weatherImageURL]];
        if ( imageData == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage * image = [[UIImage alloc] initWithData:imageData];
            [imgWeatherIcon setImage:image];
        });
    });
    [cell addSubview:imgWeatherIcon];
    return cell;
}

- (int)convertStringToRoundedInt: (NSString*) value
{
    int highTempRounded = 0;
    double highTemp = [value doubleValue];
    highTempRounded = (int)(highTemp + (highTemp>0 ? 0.5 : -0.5));
    
    return highTempRounded;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        OpenWeather *weather = _openWeathers[indexPath.row];
        [[segue destinationViewController] setDetailItem:weather];
    }
}

@end
