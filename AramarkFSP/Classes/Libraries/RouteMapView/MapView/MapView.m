//
//   MapView.m
//   Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import "MapView.h"

@implementation  MapView
@synthesize routes;
@synthesize type;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.centerCoordinate radius:1000];
        [self addOverlay:circle];
	}
	return self;
}

- (void)centerMapWithCoordinate:(CLLocationCoordinate2D)aCoordinate; {
	MKCoordinateSpan span;
	span.latitudeDelta = 0.05;
	span.longitudeDelta = 0.05;
	MKCoordinateRegion region;
	region.center = aCoordinate;
	region.span = span;

	[self setRegion:region animated:YES];
}

- (void)centerMapWithRoutes {
	if ([routes count] == 0) {
		return;
	}
	[self centerWithPoints:routes];
}

- (void)centerMapWithAnnotations {
	if ([self.annotations count] < 2) {
		return;
	}

	[self centerWithPoints:self.annotations];
}

- (void)centerWithPoints:(NSArray *)aPoints {
    NSArray *arrTemps = [NSArray arrayWithArray:aPoints];
	MKCoordinateRegion region;

	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for (int idx = 0; idx < arrTemps.count; idx++) {
		CLLocation *currentLocation = [arrTemps objectAtIndex:idx];
		if (currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if (currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if (currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if (currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;

	region.span.latitudeDelta  = maxLat - minLat + 0.3;
	region.span.longitudeDelta = maxLon - minLon + 0.3;

	[self setRegion:region animated:YES];
}

- (void)centerWithCircleOverlays
{
    MKCoordinateRegion region;
    
	for (id obj in self.overlays) {
        if ([obj isKindOfClass:[MKCircle class]]) {
            MKCircle *currentLocation = (MKCircle *)obj;
            region = MKCoordinateRegionForMapRect(currentLocation.boundingMapRect);
            break;
        }
	}
    
    region.span.latitudeDelta  += 0.1;
	region.span.longitudeDelta += 0.1;
    
    [self setRegion:region animated:YES];
}

- (void)updateRouteView
{
    NSMutableArray *arrTemp = [NSMutableArray arrayWithArray:routes];
	CLLocationCoordinate2D pointsToUse[[arrTemp count]];
	for (int i = 0; i < [arrTemp count]; i++) {
		CLLocationCoordinate2D coords;
		CLLocation *loc = [arrTemp objectAtIndex:i];
		coords.latitude = loc.coordinate.latitude;
		coords.longitude = loc.coordinate.longitude;
		pointsToUse[i] = coords;
	}

	MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:[routes count]];
	[self addOverlay:lineOne];
}

- (void)clearRoutes
{
    for (id obj in self.overlays) {
        if ([obj isKindOfClass:[MKPolyline class]]) {
            [self removeOverlay:obj];
        }
    }
}

- (void)clearCircle
{
    for (id obj in self.overlays) {
        if ([obj isKindOfClass:[MKCircle class]]) {
            [self removeOverlay:obj];
        }
    }
}

@end
