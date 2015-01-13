//
//   MapView.h
//   Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef NS_ENUM(NSInteger, MapType) {
    MapType_Route = 0,
    MapType_Circle,
};

@interface  MapView : MKMapView{
	NSArray *routes;
    MapType type;
}

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, assign) MapType type;

- (void)centerMapWithCoordinate:(CLLocationCoordinate2D)aCoordinate;

- (void)centerWithCircleOverlays;
- (void)centerMapWithRoutes;
- (void)centerMapWithAnnotations;

- (void)updateRouteView;

- (void)clearRoutes;
- (void)clearCircle;

@end
