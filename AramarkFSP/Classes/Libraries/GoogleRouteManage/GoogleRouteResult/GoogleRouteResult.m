//
//  GoogleRouteResult.m
//  Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import "GoogleRouteResult.h"

@implementation GoogleRouteBound
@synthesize southwest;
@synthesize northeast;

- (id)initWithInfo:(NSDictionary *)aInfo {
	self = [super init];
    
	if (self) {
		CLLocationCoordinate2D southcoords;
		southcoords.latitude = [[[aInfo objectForKey:@"southwest"] objectForKey:@"lat"] floatValue];
		southcoords.longitude = [[[aInfo objectForKey:@"southwest"] objectForKey:@"lng"] floatValue];
		self.southwest = southcoords;
        
		CLLocationCoordinate2D northcoords;
		northcoords.latitude = [[[aInfo objectForKey:@"northeast"] objectForKey:@"lat"] floatValue];
		northcoords.longitude = [[[aInfo objectForKey:@"northeast"] objectForKey:@"lng"] floatValue];
		self.northeast = northcoords;
	}
    
	return self;
}

@end

@implementation GoogleRouteLegDuration
@synthesize text;
@synthesize value;

- (id)initWithInfo:(NSDictionary *)aInfo {
	self = [super init];
    
	if (self) {
		self.text = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"text"]];
		self.value = [aInfo objectForKey:@"value"];
	}
    
	return self;
}

@end

@implementation GoogleRouteLegDistance
@synthesize text;
@synthesize value;

- (id)initWithInfo:(NSDictionary *)aInfo {
	self = [super init];
    
	if (self) {
		self.text = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"text"]];
		self.value = [aInfo objectForKey:@"value"];
	}
    
	return self;
}

- (NSString *)description
{
    return text;
}

@end

@implementation GoogleRouteLegStep
@synthesize html_instructions;
@synthesize duration;
@synthesize distance;
@synthesize start_location;
@synthesize end_location;
@synthesize polyLinePoints;
@synthesize travel_mode;

- (id)initWithInfo:(NSDictionary *)aInfo {
	self = [super init];
    
	if (self) {
		self.html_instructions = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"html_instructions"]];
		self.duration = [[GoogleRouteLegDuration alloc] initWithInfo:[aInfo objectForKey:@"duration"]];
		self.distance = [[GoogleRouteLegDistance alloc] initWithInfo:[aInfo objectForKey:@"distance"]];
        
		CLLocationCoordinate2D start;
		start.latitude = [[[aInfo objectForKey:@"start_location"] objectForKey:@"lat"] floatValue];
		start.longitude = [[[aInfo objectForKey:@"start_location"] objectForKey:@"lng"] floatValue];
		self.start_location = start;
        
		CLLocationCoordinate2D end;
		end.latitude = [[[aInfo objectForKey:@"end_location"] objectForKey:@"lat"] floatValue];
		end.longitude = [[[aInfo objectForKey:@"end_location"] objectForKey:@"lng"] floatValue];
		self.end_location = end;
        
		self.polyLinePoints = [GoogleUtility decodePolyLine:[[aInfo objectForKey:@"polyline"] objectForKey:@"points"] fromPoint:start toPoint:end];
        
		self.travel_mode = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"travel_mode"]];
	}
	return self;
}

@end

@implementation GoogleRouteLeg
@synthesize duration;
@synthesize distance;
@synthesize start_location;
@synthesize end_location;
@synthesize start_address;
@synthesize end_address;
@synthesize via_waypoint;
@synthesize steps;
@synthesize relateLocation;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%f,%f to %f,%f | %@",start_location.latitude,start_location.longitude,end_location.latitude,end_location.longitude, distance];
}

- (id)initWithInfo:(NSDictionary *)aInfo {
	self = [super init];
    
	if (self) {
		self.duration = [[GoogleRouteLegDuration alloc] initWithInfo:[aInfo objectForKey:@"duration"]];
		self.distance = [[GoogleRouteLegDistance alloc] initWithInfo:[aInfo objectForKey:@"distance"]];
        
		CLLocationCoordinate2D start;
		start.latitude = [[[aInfo objectForKey:@"start_location"] objectForKey:@"lat"] floatValue];
		start.longitude = [[[aInfo objectForKey:@"start_location"] objectForKey:@"lng"] floatValue];
		self.start_location = start;
        
		CLLocationCoordinate2D end;
		end.latitude = [[[aInfo objectForKey:@"end_location"] objectForKey:@"lat"] floatValue];
		end.longitude = [[[aInfo objectForKey:@"end_location"] objectForKey:@"lng"] floatValue];
		self.end_location = end;
        
		self.start_address = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"start_address"]];
		self.end_address = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"end_address"]];
        
		self.via_waypoint = [aInfo objectForKey:@"via_waypoint"];
        
		self.steps = [aInfo objectForKey:@"steps"];
        
		self.steps = [[NSMutableArray alloc] initWithCapacity:[[aInfo objectForKey:@"steps"] count]];
        
		for (id step in[aInfo objectForKey:@"steps"]) {
			[self.steps addObject:[[GoogleRouteLegStep alloc] initWithInfo:step]];
		}
        
        //Modify 20140820
        NSMutableArray *arrTemp = [NSMutableArray array];
        for (GoogleRouteLegStep *step in self.steps) {
            [arrTemp addObjectsFromArray:step.polyLinePoints];
        }
        self.via_waypoint = arrTemp;
	}
    
	return self;
}

@end

@implementation GoogleRoute
@synthesize summary;
@synthesize bounds;
@synthesize copyrights;
@synthesize waypoint_order;
@synthesize legs;
@synthesize warnings;
@synthesize overview_polyLinePoints;

- (id)initWithInfo:(NSDictionary *)aInfo
         fromPoint:(CLLocationCoordinate2D)origin
           toPoint:(CLLocationCoordinate2D)destination
{
	self = [super init];
    
	if (self) {
		self.summary = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"summary"]];
		self.bounds = [[GoogleRouteBound alloc] initWithInfo:[aInfo objectForKey:@"bounds"]];
		self.copyrights = [GoogleUtility filterHtmlTag:[aInfo objectForKey:@"copyrights"]];
		self.waypoint_order = [aInfo objectForKey:@"waypoint_order"];
		self.legs = [[NSMutableArray alloc] initWithCapacity:[[aInfo objectForKey:@"legs"] count]];
		for (id leg in[aInfo objectForKey:@"legs"]) {
			[self.legs addObject:[[GoogleRouteLeg alloc] initWithInfo:leg]];
		}
		self.warnings = [aInfo objectForKey:@"warnings"];
		self.overview_polyLinePoints = [GoogleUtility decodePolyLine:[[aInfo objectForKey:@"overview_polyline"] objectForKey:@"points"] fromPoint:origin];
	}
    
	return self;
}

@end

@implementation GoogleRouteResult

@synthesize status;
@synthesize routes;

- (id)initWithInfo:(NSDictionary *)aInfo
         fromPoint:(CLLocationCoordinate2D)origin
           toPoint:(CLLocationCoordinate2D)destination {
	self = [super init];

	if (self) {
		self.status = [aInfo objectForKey:@"status"];
		self.routes = [[NSMutableArray alloc] initWithCapacity:[[aInfo objectForKey:@"routes"] count]];
		for (id route in[aInfo objectForKey:@"routes"]) {
			[self.routes addObject:[[GoogleRoute alloc] initWithInfo:route fromPoint:origin toPoint:destination]];
		}
	}

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@" %@ : %@ ", self.status, self.routes];
}

@end
