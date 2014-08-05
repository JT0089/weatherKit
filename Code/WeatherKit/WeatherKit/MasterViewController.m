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
#import "Weather.h"

@interface MasterViewController ()
    @property (nonatomic, strong) NSArray *weathers;
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
//    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    
    [self configureRestKit];
    [self loadWeather];
}

// Configure Rest Query
- (void)configureRestKit
{
    // initialize AFNetworking HTTPClient
    NSURL *baseURL = [NSURL URLWithString:@"http://api.openweathermap.org"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    // initialize RestKit
    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    
    // setup object mappings
    RKObjectMapping *weatherMapping = [RKObjectMapping mappingForClass:[Weather class]];
    [weatherMapping addAttributeMappingsFromArray:@[@"dt"]];
    [weatherMapping addAttributeMappingsFromArray:@[@"pressure"]];
    [weatherMapping addAttributeMappingsFromArray:@[@"humidity"]];
    [weatherMapping addAttributeMappingsFromArray:@[@"speed"]];
    [weatherMapping addAttributeMappingsFromArray:@[@"clouds"]];
    [weatherMapping addAttributeMappingsFromArray:@[@"temp"]];
    
    // register mappings with the provider using a response descriptor
    RKResponseDescriptor *responseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:weatherMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"/data/2.5/forecast/daily"
                                                keyPath:@"list"
                                            statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [objectManager addResponseDescriptor:responseDescriptor];
}

// Get Weather Data
- (void)loadWeather
{
    NSString *cityState = @"Wichita,KS";
    NSString *count = @"5";
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
                                                  _weathers = mappingResult.array;
                                                  [self.tableView reloadData];
                                              }
                                              failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                                  NSLog(@"What do you mean by 'there is no coffee?': %@", error);
                                              }];
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
    return _weathers.count;
}

// Fill Row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    Weather *weather = _weathers[indexPath.row];
    NSTimeInterval ticks = [weather.dt doubleValue];
    NSDate *time = [NSDate dateWithTimeIntervalSince1970: ticks];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEEE"];
    NSString *theDate = [dateFormat stringFromDate:time];
    cell.textLabel.text = theDate;
    return cell;
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
        Weather *weather = _weathers[indexPath.row];
        [[segue destinationViewController] setDetailItem:weather];
    }
}

@end
