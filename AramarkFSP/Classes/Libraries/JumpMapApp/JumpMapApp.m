//
//  JumpMapApp.m
//  AramarkFSP
//
//  Created by FYH on 9/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "JumpMapApp.h"

@implementation JumpMapApp

+(BOOL)isInstalledGoogleMapApp
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]];
}

+ (void)jumpToGoogleMapAppFromOriginLocation:(CLLocationCoordinate2D)aOriginLocation
                       toDestinationLocation:(CLLocationCoordinate2D)aDestinationLocation
{
    NSString *saddr = [NSString stringWithFormat:@"%f,%f", aOriginLocation.latitude, aOriginLocation.longitude];
    NSString *daddr = [NSString stringWithFormat:@"%f,%f", aDestinationLocation.latitude, aDestinationLocation.longitude];
    
    NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@&directionsmode=driving",saddr,daddr];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

+ (void)jumpToGoogleMapAppToDestinationLocation:(CLLocationCoordinate2D)aDestinationLocation
{
    NSString *daddr = [NSString stringWithFormat:@"%f,%f", aDestinationLocation.latitude, aDestinationLocation.longitude];
    
    NSString *urlStr = [NSString stringWithFormat:@"comgooglemaps://?daddr=%@&directionsmode=driving",daddr];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

+ (void)jumpToAppleMapAppFromOriginLocation:(CLLocationCoordinate2D)aOriginLocation
                      toDestinationLocation:(CLLocationCoordinate2D)aDestinationLocation
{
    MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:aOriginLocation addressDictionary:nil]];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:aDestinationLocation addressDictionary:nil]];
    
    [MKMapItem openMapsWithItems:[NSArray arrayWithObjects:currentLocation, toLocation, nil]
                   launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving,
                                                                      [NSNumber numberWithBool:YES], nil]
                                                             forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey,
                                                                      MKLaunchOptionsShowsTrafficKey, nil]]];
}

@end
