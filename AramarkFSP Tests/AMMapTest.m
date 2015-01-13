//
//  AMMapTest.m
//  AramarkFSP
//
//  Created by FYH on 8/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MapTool.h"

@interface AMMapTest : XCTestCase

@end

@implementation AMMapTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1
{
    float ilant = (((arc4random() % 100) >= 50) ? (INITLatitude + ((arc4random() % 1000) / 1000.0)) : (INITLatitude - ((arc4random() % 1000) / 1000.0)));
	float ilong = (((arc4random() % 100) >= 50) ? (INITLongitude + ((arc4random() % 1000) / 1000.0)) : (INITLongitude - ((arc4random() % 1000) / 1000.0)));
    
	CLLocation *location = [[CLLocation alloc] initWithLatitude:ilant longitude:ilong];
    
      NSLog(@"%f ... %f",INITLatitude,INITLongitude);
    
    for (NSInteger i = 0; i < 10; i ++) {
        CLLocationCoordinate2D coor = [[MapTool sharedInstance] coordinateFromCoord:location.coordinate atDistanceKm:1 atBearingDegrees:0.5];
        NSLog(@"%f ... %f",coor.latitude,coor.longitude);
    }
   
    NSLog(@"End");
}

@end
