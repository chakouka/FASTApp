//
//  JumpMapApp.h
//  AramarkFSP
//
//  Created by FYH on 9/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JumpMapApp : NSObject

+ (BOOL)isInstalledGoogleMapApp;

+ (void)jumpToGoogleMapAppFromOriginLocation:(CLLocationCoordinate2D)aOriginLocation
                       toDestinationLocation:(CLLocationCoordinate2D)aDestinationLocation;

+ (void)jumpToGoogleMapAppToDestinationLocation:(CLLocationCoordinate2D)aDestinationLocation;

+ (void)jumpToAppleMapAppFromOriginLocation:(CLLocationCoordinate2D)aOriginLocation
                      toDestinationLocation:(CLLocationCoordinate2D)aDestinationLocation;

@end
