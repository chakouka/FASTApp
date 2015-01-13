//
//  GoogleRouteResult.h
//  Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "GoogleUtility.h"

@interface GoogleRouteBound : NSObject
@property (nonatomic, readwrite) CLLocationCoordinate2D southwest;
@property (nonatomic, readwrite) CLLocationCoordinate2D northeast;

- (id)initWithInfo:(NSDictionary *)aInfo;

@end

@interface GoogleRouteLegDuration : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *value;

- (id)initWithInfo:(NSDictionary *)aInfo;

@end

@interface GoogleRouteLegDistance : NSObject
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *value;

- (id)initWithInfo:(NSDictionary *)aInfo;

@end

@interface GoogleRouteLegStep : NSObject
@property (nonatomic, strong) NSString *html_instructions;
@property (nonatomic, strong) GoogleRouteLegDuration *duration;
@property (nonatomic, strong) GoogleRouteLegDistance *distance;
@property (nonatomic, readwrite) CLLocationCoordinate2D start_location;
@property (nonatomic, readwrite) CLLocationCoordinate2D end_location;
@property (nonatomic, strong) NSMutableArray *polyLinePoints;
@property (nonatomic, strong) NSString *travel_mode;

- (id)initWithInfo:(NSDictionary *)aInfo;

@end

@interface GoogleRouteLeg : NSObject
@property (nonatomic, strong) GoogleRouteLegDuration *duration;
@property (nonatomic, strong) GoogleRouteLegDistance *distance;
@property (nonatomic, readwrite) CLLocationCoordinate2D start_location;
@property (nonatomic, readwrite) CLLocationCoordinate2D end_location;
@property (nonatomic, strong) NSString *start_address;
@property (nonatomic, strong) NSString *end_address;
@property (nonatomic, strong) NSMutableArray *via_waypoint;
@property (nonatomic, strong) NSMutableArray *steps;
@property (nonatomic, strong) CLLocation    *relateLocation;    //This is special for Local

- (id)initWithInfo:(NSDictionary *)aInfo;

@end

@interface GoogleRoute : NSObject
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) GoogleRouteBound *bounds;
@property (nonatomic, strong) NSString *copyrights;
@property (nonatomic, strong) NSMutableArray *waypoint_order;
@property (nonatomic, strong) NSMutableArray *legs;
@property (nonatomic, strong) NSMutableArray *warnings;
@property (nonatomic, strong) NSMutableArray *overview_polyLinePoints;

- (id)initWithInfo:(NSDictionary *)aInfo fromPoint:(CLLocationCoordinate2D)origin
           toPoint:(CLLocationCoordinate2D)destination;

@end


@interface GoogleRouteResult : NSObject

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSMutableArray *routes;

- (id)initWithInfo:(NSDictionary *)aInfo
         fromPoint:(CLLocationCoordinate2D)origin
           toPoint:(CLLocationCoordinate2D)destination;

@end
