//
//  RouteMapView.h
//  MapShow
//
//  Created by PwC on 4/21/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapView.h"
#import "CurrentAnnotationView.h"
#import "PointAnnotationView.h"

@protocol RouteMapViewDelegate;

@interface RouteMapView : UIView
{
    AnnotationInfo *currentInCheckoutStatusMapAnnotation;
    AnnotationInfo *currentInCheckinStatusMapAnnotation;
    AnnotationInfo *currentInFinishedStatusMapAnnotation;
	CLLocation *currentLocation;
    MapType mapType;
}

@property (assign, nonatomic) id <RouteMapViewDelegate> delegate;
@property (assign, nonatomic) MapType mapType;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) AnnotationInfo *currentInCheckoutStatusMapAnnotation;
@property (nonatomic, strong) AnnotationInfo *currentInCheckinStatusMapAnnotation;
@property (nonatomic, strong) AnnotationInfo *currentInFinishedStatusMapAnnotation;

/**
 *  Init RouteMapView
 *
 *  @param frame  Frame of new RouteMapView
 *  @param region Region of map in RouteMapView
 *
 *  @return An RouteMapView Object
 */
- (id)initWithFrame:(CGRect)frame Region:(MKCoordinateRegion)region;

/**
 *  Change RouteMapView's Size
 *
 *  @param aFrame Frame of new RouteMapView
 */
- (void)resizeWithFrame:(CGRect)aFrame;

/**
 *  Set Selected Annotation
 *
 *  @param aAnnotationInfo New selected annotation
 */
- (void)selectAnnotationInfo:(AnnotationInfo *)aAnnotationInfo;

/**
 *  Center With Annotation
 *
 *  @param aAnnotationInfo Center annotation
 */
- (void)centerWithAnnotationInfo:(AnnotationInfo *)aAnnotationInfo;

/**
 *  Center with all routes
 */
- (void)centerWithRoutes;

/**
 *  Center with circle
 */
- (void)centerWithCircle;

/**
 *  Center with current Location
 */
- (void)centerWithCurrentLocation;

/**
 *  Center with all annotations
 */
- (void)centerWithAllAnnotations;

/**
 *  Remove all routes from map
 */
- (void)clearRoutes;

/**
 *  Remove Circle
 */
-(void)clearCircle;

/**
 *  Draw circle on map
 *
 *  @param aCenter Circle's center
 *  @param aRadius Circle's radius
 */
- (void)drawCircleWithCenter:(CLLocationCoordinate2D)aCenter radius:(CGFloat )aRadius;

/**
 *  Draw routes on map
 *
 *  @param lines An array with route's line info
 */
- (void)drawRoutesOnMap:(NSArray *)lines;

/**
 *  Refresh all annotations for route type map
 *
 *  @param aAnnotations New annotations
 */
- (void)refreshAnnotations:(NSMutableArray *)aAnnotations;

/**
 *  Refresh all annotations for circle type map
 *
 *  @param aAnnotations New annotations
 */
- (void)refreshNearAnnotations:(NSMutableArray *)aAnnotations;

/**
 *  Show tip info
 *
 *  @param aTip New tip info
 */
- (void)showTip:(NSString *)aTip;

/**
 *  Close tip label
 */
- (void)hiddenTip;

@end


@protocol RouteMapViewDelegate <NSObject>

- (void)routeMapView:(RouteMapView *)aRouteView didTappedPointAnnotationView:(PointAnnotationView *)aPointAnnotationView;  //When click annotation view
- (void)routeMapView:(RouteMapView *)aRouteView didTappedCancelAnnotationView:(PointAnnotationView *)aPointAnnotationView; //When click annotation's cancel button

@end