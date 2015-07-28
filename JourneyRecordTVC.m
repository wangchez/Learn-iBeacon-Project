//
//  JourneyRecordTVC.m
//  LBSMuseumGuide
//
//  Created by CReW on 2014/8/6.
//  Copyright (c) 2014年 udndigital. All rights reserved.
//

#import "JourneyRecordTVC.h"
#import <Parse/Parse.h>
#import "MessageDetailVC.h"

@interface JourneyRecordTVC ()

@property (nonatomic, strong) CLBeacon *temporarilyBeacon;

@property (nonatomic, strong) NSDictionary *imageDic;

@end

@implementation JourneyRecordTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageDic =
    @{
      @"Il Cenacolo or L'Ultima Cena":[UIImage imageNamed:@"Cenacolo.jpeg"],
      @"La Gioconda":[UIImage imageNamed:@"Gioconda.jpeg"],
      @"Uomo vitruviano":[UIImage imageNamed:@"Vitruviano.jpeg"],
      @"Ginevra de' Benci":[UIImage imageNamed:@"Ginevra.jpeg"],
      @"Adorazione dei Magi":[UIImage imageNamed:@"Adorazione.jpeg"],
      @"Madonna del Garofano":[UIImage imageNamed:@"Madonna.jpeg"],
      @"La belle Ferronière":[UIImage imageNamed:@"belle.jpeg"]
      };
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"louvre.jpg"]];
    self.journeyRecordList = [NSMutableArray new];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self initRegion];
    [self locationManager:self.locationManager didStartMonitoringForRegion:self.beaconRegion];
}

- (void)initRegion {
    //
    
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"com.udndigital.searchRegion"];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Left Region");
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}


- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"detect beacons, %lu", (unsigned long)[beacons count]);
    
    NSPredicate *predicateIrrelevantBeacons = [NSPredicate predicateWithFormat:@"(self.accuracy != -1) AND ((self.proximity != %d) OR (self.proximity != %d))", CLProximityFar, CLProximityUnknown];
    NSArray *relevantsBeacons = [beacons filteredArrayUsingPredicate: predicateIrrelevantBeacons];
    NSPredicate *predicateMin = [NSPredicate predicateWithFormat:@"self.accuracy == %@.@min.accuracy", relevantsBeacons];
    
    CLBeacon *closestBeacon = nil;
    NSArray *closestArray = [relevantsBeacons filteredArrayUsingPredicate:predicateMin];
    if ([closestArray count] > 0)
    {
        closestBeacon = [closestArray objectAtIndex:0];
        
        NSLog(@"x= %d, y= %d", [closestBeacon.major intValue], [closestBeacon.minor intValue]);
        
        NSLog(@"rssi= %ld", (long)closestBeacon.rssi);
        
        NSLog(@"accuracy= %f", closestBeacon.accuracy);
        
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
        
        if (closestBeacon.proximity == CLProximityImmediate)
        {
            [self searchingExhibitInParse:closestBeacon];
        }
        else
        {
            NSLog(@"No near beacon.");
            
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
        }
    }
    else
    {
        NSLog(@"No closest beacon.");
    }
}

- (void)searchingExhibitInParse:(CLBeacon *)closeBeacon
{
    NSPredicate *queryPredicate = [NSPredicate predicateWithFormat:@"Major == %@ AND Minor == %@", closeBeacon.major, closeBeacon.minor];
    
    PFQuery *query = [PFQuery queryWithClassName:@"BeaconCollection" predicate:queryPredicate];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu reslut.", (unsigned long)objects.count);
            
            if (self.temporarilyBeacon == nil || ([self.temporarilyBeacon.major intValue] != [closeBeacon.major intValue] && [self.temporarilyBeacon.minor intValue] != [closeBeacon.minor intValue]))
            {
                self.temporarilyBeacon = closeBeacon;
                
                [self recordJourneyPath:[objects firstObject]];
            }
            
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void)recordJourneyPath:(PFObject *)targetObj
{
    [self.journeyRecordList addObject:targetObj];
    
    NSIndexPath *dataIndex = [NSIndexPath indexPathForRow:[self.journeyRecordList count]-1 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[dataIndex] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.journeyRecordList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"recordInfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    
    // Configure the cell...
    PFObject *tagetObj = self.journeyRecordList[indexPath.row];
    cell.textLabel.text = tagetObj[@"Exhibit"];
    cell.imageView.image = self.imageDic[cell.textLabel.text];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *cellPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
    
    MessageDetailVC *desVC = segue.destinationViewController;
    desVC.targetObj = self.journeyRecordList[cellPath.row];
}


@end
