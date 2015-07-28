//
//  JourneyRecordTVC.h
//  LBSMuseumGuide
//
//  Created by CReW on 2014/8/6.
//  Copyright (c) 2014年 udndigital. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface JourneyRecordTVC : UITableViewController<CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *journeyRecordList;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end
