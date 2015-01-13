//
//  RouteMapView.m
//  MapShow
//
//  Created by PwC on 4/21/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//
/*************************************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM000118: iPad Beep on Sync with new WO. By Hari Kolasani. 12/9/2014
 *************************************************************************************************/

#import "RouteMapView.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

//#define TESTMODEL   1   //Use for test
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define HEIGHT_OF_CLOSE_TIP_BTN 35.0
#define TIME_OF_MAP_CURRENT_POINT_REFRESH   3.0

#define HEIGHT_OF_TIP_VIEW  35.0
#define WIDTH_OF_TIP_VIEW   400.0


@interface  RouteMapView ()
<
MKMapViewDelegate,
PointAnnotationViewDelegate,
CLLocationManagerDelegate
>
{
    NSMutableArray *mapAnnotations;
    NSMutableArray *arrAnnotationViews;
    CLLocationManager *locationManager;
    NSTimer *lcoationRepeatTimer;
    UILabel *labelTips;
    UIView *viewTips;
    UIButton *btnCloseTips;
    BOOL showTips;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) UILabel *labelTips;
@property (nonatomic, strong) UIView *viewTips;
@property (nonatomic, strong) UIButton *btnCloseTips;
@property (strong, nonatomic) NSMutableArray *arrAnnotationViews;
@property (nonatomic, strong) NSMutableArray *mapAnnotations;
@property (nonatomic, strong) MapView *mapShowView;

@end

@implementation RouteMapView
@synthesize mapType;
@synthesize labelTips;
@synthesize viewTips;
@synthesize btnCloseTips;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize mapAnnotations;
@synthesize mapShowView;
@synthesize delegate;
@synthesize arrAnnotationViews;
@synthesize currentInCheckinStatusMapAnnotation;
@synthesize currentInCheckoutStatusMapAnnotation;
@synthesize currentInFinishedStatusMapAnnotation;

- (id)initWithFrame:(CGRect)frame Region:(MKCoordinateRegion)region{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        mapShowView = [[MapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        mapShowView.mapType = MKMapTypeStandard;
        [mapShowView setRegion:region animated:YES];
        [mapShowView setDelegate:self];
        [self addSubview:mapShowView];
        arrAnnotationViews = [NSMutableArray array];
        
        labelTips = [[UILabel alloc] initWithFrame:CGRectMake(HEIGHT_OF_CLOSE_TIP_BTN, 0, WIDTH_OF_TIP_VIEW - HEIGHT_OF_CLOSE_TIP_BTN, HEIGHT_OF_TIP_VIEW)];
        labelTips.backgroundColor = [UIColor clearColor];
        labelTips.textAlignment = NSTextAlignmentCenter;
        labelTips.textColor = [UIColor whiteColor];
        labelTips.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon];
        
        viewTips = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - HEIGHT_OF_CLOSE_TIP_BTN, 10, WIDTH_OF_TIP_VIEW, HEIGHT_OF_TIP_VIEW)];
        viewTips.alpha = 0.7;
        viewTips.backgroundColor = [UIColor blackColor];
        [viewTips addSubview:labelTips];
        
        UIButton *btnOpenTips = [UIButton buttonWithType:UIButtonTypeInfoLight];
        btnOpenTips.tintColor = [UIColor whiteColor];
        btnOpenTips.frame = CGRectMake(0, 0, HEIGHT_OF_CLOSE_TIP_BTN, HEIGHT_OF_CLOSE_TIP_BTN);
        [viewTips addSubview:btnOpenTips];
        
        btnCloseTips = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCloseTips.frame = CGRectMake(0, 0, WIDTH_OF_TIP_VIEW, HEIGHT_OF_CLOSE_TIP_BTN);
        [btnCloseTips addTarget:self action:@selector(operationTips) forControlEvents:UIControlEventTouchUpInside];
        [viewTips addSubview:btnCloseTips];
        showTips = NO;
        
        [self addSubview:viewTips];
        
        viewTips.hidden = YES;
        
        mapType = MapType_Route;
        
        self.currentLocation = [[CLLocation alloc] init];
        
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //        [locationManager setDistanceFilter:kCLDistanceFilterNone];
        [locationManager startUpdatingLocation];
        
        [self startAutoRefreshCurrentAnnotation];
        
#ifdef TARGET_IPHONE_SIMULATOR
        [self refreshCurrentAnnotationWithLocation:nil];
#endif
        
    }
    
    return self;
}

- (void)setMapType:(MapType)aMapType
{
    mapType = aMapType;
    
    if (aMapType == MapType_Route) {
        [self.mapShowView clearCircle];
    }
    
    if (aMapType == MapType_Circle) {
        [self.mapShowView clearRoutes];
    }
    
    self.mapShowView.type = aMapType;
}

- (void)resizeWithFrame:(CGRect)aFrame {
    
    if (CGRectEqualToRect(self.frame, aFrame)) {
        return;
    }
    
    self.frame = aFrame;
    self.mapShowView.frame = CGRectMake(0, 0, CGRectGetWidth(aFrame), CGRectGetHeight(aFrame));
    
    if (showTips) {
        viewTips.frame = CGRectMake(CGRectGetWidth(self.frame) - WIDTH_OF_TIP_VIEW, 10, WIDTH_OF_TIP_VIEW, HEIGHT_OF_TIP_VIEW);
    }
    else
    {
        viewTips.frame = CGRectMake(CGRectGetWidth(self.frame) - HEIGHT_OF_CLOSE_TIP_BTN, 10, WIDTH_OF_TIP_VIEW, HEIGHT_OF_TIP_VIEW);
    }
}

- (CGSize)sizeLabelInfoWith:(NSString *)aInfo
{
    NSDictionary *attribute = @{NSFontAttributeName: [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]};
    
    return [aInfo boundingRectWithSize:CGSizeMake(MAXFLOAT, 35.0)
                               options: NSStringDrawingUsesDeviceMetrics
                            attributes:attribute
                               context:nil].size;
}

#pragma mark -

//Refresh Tip Label's info and Tip View's frame
- (void)showTip:(NSString *)aTip
{
    labelTips.text = aTip;
    
    if (viewTips.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            viewTips.hidden = NO;
        } completion:^(BOOL finished) {
            [self openTip];
        }];
    }
}

- (void)hiddenTip
{
    if (!viewTips.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
             viewTips.hidden = YES;
        }];
    }
}

//close Tip
- (void)closeTip
{
    if (!showTips) {
        return;
    }
    
    showTips = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        viewTips.frame = CGRectMake(CGRectGetWidth(self.frame) - HEIGHT_OF_CLOSE_TIP_BTN, 10, WIDTH_OF_TIP_VIEW, HEIGHT_OF_TIP_VIEW);
    }];
}

//Open Tip
- (void)openTip
{
    if (showTips) {
        return;
    }
    
    showTips = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        viewTips.frame = CGRectMake(CGRectGetWidth(self.frame) - WIDTH_OF_TIP_VIEW, 10, WIDTH_OF_TIP_VIEW, HEIGHT_OF_TIP_VIEW);
    }];
}

- (void)operationTips
{
    if (showTips) {
        [self closeTip];
    }
    else
    {
        [self openTip];
    }
}

#pragma mark -

- (void)selectAnnotationInfo:(AnnotationInfo *)aAnnotationInfo {
    [self.mapShowView selectAnnotation:[self pointAnnotationWithId:aAnnotationInfo.woID] animated:NO];
}

#pragma mark -

- (void)centerWithAnnotationInfo:(AnnotationInfo *)aAnnotationInfo {
    [self.mapShowView centerMapWithCoordinate:aAnnotationInfo.location.coordinate];
}

- (void)centerWithRoutes {
    [self.mapShowView centerMapWithRoutes];
}

- (void)centerWithAllAnnotations {
    [self.mapShowView centerMapWithAnnotations];
}

- (void)centerWithCurrentLocation {
    [self.mapShowView centerMapWithCoordinate:self.currentLocation.coordinate];
}

- (void)centerWithCircle
{
    [self.mapShowView centerWithCircleOverlays];
}

#pragma mark -

- (void)addBounceAnnimationToView:(UIView *)view {
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];
    
    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (id mkView in views) {
        [self addBounceAnnimationToView:mkView];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view isKindOfClass:[PointAnnotationView class]]) {
        
        PointAnnotationView *selectedPointView = (PointAnnotationView *)view;
        
        switch (selectedPointView.mapAnnotation.viewType) {
            case AnnotationViewType_Finished:
            {
                [selectedPointView clickCheckInBtn:nil];
            }
                break;
            default:
                break;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
    if ([annotation isKindOfClass:[AnnotationInfo class]])
    {
        AnnotationInfo *mapAnnotation = (AnnotationInfo *)annotation;
        
        switch (mapAnnotation.partType)
        {
            case MapLocationType_CurrentPoint:
            {
                static NSString *CurrentPoint = @"CurrentPoint";
                CurrentAnnotationView *pulsingView = (CurrentAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CurrentPoint];
                
                if (!pulsingView)
                {
                    pulsingView = [[CurrentAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:CurrentPoint];
                    
                    pulsingView.annotationColor = [UIColor colorWithRed:0.678431 green:0 blue:0 alpha:1];
                    
                    pulsingView.canShowCallout = NO;
                }
                
                pulsingView.mapAnnotation = mapAnnotation;
                
                return pulsingView;
            }
                break;
                
            default:
            {
                static NSString *const TargetPoint = @"TargetPoint1";
                
                PointAnnotationView *annotationView = [[PointAnnotationView alloc] initWithAnnotation:mapAnnotation reuseIdentifier:TargetPoint];
                
                annotationView.canShowCallout = NO;
                
                annotationView.mapAnnotation = mapAnnotation;
                
                annotationView.delegate = self;
                
                [self.arrAnnotationViews addObject:annotationView];
                
                return annotationView;
            }
                break;
        }
    }
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay> )overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *lineview = [[MKPolylineView alloc] initWithOverlay:overlay];
        lineview.strokeColor = RouteLineColor;
        lineview.lineWidth = RouteLineWidth;
        return lineview;
    }
    else if([overlay isKindOfClass:[MKCircle class]]) {
        // Create the view for the radius overlay.
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [UIColor redColor];
        circleView.fillColor = [UIColor clearColor];
        circleView.lineWidth = 3.0;
        return circleView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self closeTip];
}

#pragma mark -

-(void)didTappedCancelAnnotationView:(PointAnnotationView *)aPointAnnotationView{
    
    AMWorkOrder *workorder = [[AMLogicCore sharedInstance] getWorkOrderInfoByID:aPointAnnotationView.mapAnnotation.woID];
    
    AMUser *user = [[AMLogicCore sharedInstance] getSelfUserInfo];
    if (![workorder.ownerID isEqualToString:user.userID]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"You are not the primary person of this work order")];
        return;
    }
    
    [UIAlertView showWithTitle:@""
                       message:[NSString stringWithFormat:@"%@ %@ ?",MyLocal(@"Cancel check in"),workorder.accountName]
             cancelButtonTitle:MyLocal(@"NO")
             otherButtonTitles:@[MyLocal(@"YES")]
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              return;
                          }
                          else
                          {
                              DLog(@"didTappedCancelAnnotationView : %@",aPointAnnotationView.mapAnnotation.woID);
                              MAIN((^{
                                  [[AMLogicCore sharedInstance] cancelCheckInWorkOrder:workorder completionBlock:^(NSInteger type, NSError *error) {
                                      if (error) {
                                          [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                          return ;
                                      }
                                      else
                                      {
                                          self.currentInCheckoutStatusMapAnnotation = nil;
                                          self.currentInCheckinStatusMapAnnotation = nil;
                                          [self changePointAnnotation:aPointAnnotationView.mapAnnotation withType:AnnotationViewType_CheckIn animation:YES];
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_MAPVIEW object:@{
                                                                                                                                        KEY_OF_TYPE:TYPE_OF_LIST_REFRESH,
                                                                                                                                        KEY_OF_INFO:@"",}];
                                          
                                          if (delegate && [delegate respondsToSelector:@selector(routeMapView:didTappedPointAnnotationView:)]) {
                                              [delegate routeMapView:self didTappedCancelAnnotationView:aPointAnnotationView];
                                          }
                                      }
                                  }];
                              }));
                          }
                      }];
    
}

- (void)didTappedPointAnnotationView:(PointAnnotationView *)aPointAnnotationView{
    
    AMWorkOrder *workorder = [[AMLogicCore sharedInstance] getWorkOrderInfoByID:aPointAnnotationView.mapAnnotation.woID];
    AMUser *user = [[AMLogicCore sharedInstance] getSelfUserInfo];
    
    switch (aPointAnnotationView.mapAnnotation.viewType) {
        case AnnotationViewType_CheckIn:
        {
            if (![workorder.ownerID isEqualToString:user.userID]) {
                [AMUtilities showAlertWithInfo:MyLocal(@"You are not the primary person of this work order")];
                return;
            }
            
            NSArray *todayCheckInWOList = [[AMDBManager sharedInstance] getSelfOwnedTodayCheckInWorkOrders];
            
            if ([todayCheckInWOList count] > 0) {
                AMWorkOrder *currentWO = [todayCheckInWOList firstObject];
                [AMUtilities showAlertWithInfo:[NSString stringWithFormat:@"%@\n %@ : %@ \n %@ : %@", MyLocal(@"Please complete check out."),MyLocal(@"WO #"),currentWO.woNumber,MyLocal(@"Account Name"),currentWO.accountName]];
                return;
            }
            else
            {
                //TODO::Enhancement140929
                NSArray *openWO = [[AMLogicCore sharedInstance] getCaseOpenWorkOrderList:workorder.caseID];
                if ([openWO count] > 1) {
                    [UIAlertView showWithTitle:@""
                                       message:MyLocal(@"There is more than one open Work Order associated to this Case")
                             cancelButtonTitle:MyLocal(@"Continue")
                             otherButtonTitles:nil
                                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                          if (buttonIndex == [alertView cancelButtonIndex]) {
                                              [self showCheckInAlert:workorder annotationView:aPointAnnotationView];
                                          }
                                      }];
                } else {
                    [self showCheckInAlert:workorder annotationView:aPointAnnotationView];
                }
                
            }
        }
            break;
            
        case AnnotationViewType_CheckOut:
        {
            if (![workorder.ownerID isEqualToString:user.userID]) {
                [AMUtilities showAlertWithInfo:MyLocal(@"You are not the primary person of this work order")];
                return;
            }
            NSString *message = MyLocal(@"Are you sure you want to check out?");
            if (
                !workorder.assetID
                && ![workorder.recordTypeName isEqualToLocalizedString:kAMWORK_ORDER_TYPE_EXCHANGE]
                && ![workorder.recordTypeName isEqualToLocalizedString:kAMWORK_ORDER_TYPE_SITESURVEY]
                && ![workorder.recordTypeName isEqualToLocalizedString:kAMWORK_ORDER_TYPE_INSTALL]
                )
            {
                message = MyLocal(@"Please select an asset before checking out. Are you sure you want to continue?");
            }
            [UIAlertView showWithTitle:@""
                               message:message
                     cancelButtonTitle:MyLocal(@"NO")
                     otherButtonTitles:@[MyLocal(@"YES")]
                              tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      return;
                                  }
                                  else
                                  {
                                      self.currentInCheckoutStatusMapAnnotation = nil;
                                      self.currentInFinishedStatusMapAnnotation = aPointAnnotationView.mapAnnotation;
                                      [self changePointAnnotation:currentInFinishedStatusMapAnnotation withType:AnnotationViewType_Finished animation:YES];
                                      
                                      [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_MAPVIEW object:@{
                                                                                                                                    KEY_OF_TYPE:TYPE_OF_LIST_REFRESH,
                                                                                                                                    KEY_OF_INFO:@"",}];
                                      
                                      if (delegate && [delegate respondsToSelector:@selector(routeMapView:didTappedPointAnnotationView:)]) {
                                          [delegate routeMapView:self didTappedPointAnnotationView:aPointAnnotationView];
                                      }
                                  }
                              }];
        }
            break;
        case AnnotationViewType_Finished:
        {
            if (![workorder.ownerID isEqualToString:user.userID]) {
                [AMUtilities showAlertWithInfo:MyLocal(@"You are not the primary person of this work order")];
                return;
            }
            
            if (currentInCheckinStatusMapAnnotation) {
                [self changePointAnnotation:currentInCheckinStatusMapAnnotation withType:AnnotationViewType_CheckIn animation:YES];
                self.currentInCheckinStatusMapAnnotation = nil;
            }
            
            if (delegate && [delegate respondsToSelector:@selector(routeMapView:didTappedPointAnnotationView:)]) {
                [delegate routeMapView:self didTappedPointAnnotationView:aPointAnnotationView];
            }
        }
            break;
        case AnnotationViewType_NearMe:
        {
            BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
            if (!isNetworkReachable) {
                [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
                return;
            }
            
            [UIAlertView showWithTitle:@""
                               message:MyLocal(@"Are you sure you want to assign this work order to your today's WO list?")
                     cancelButtonTitle:MyLocal(@"NO")
                     otherButtonTitles:@[MyLocal(@"YES")]
                              tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      return;
                                  }
                                  else
                                  {
                                      [SVProgressHUD show];
                                      self.userInteractionEnabled = NO;
                                      
                                      [[AMLogicCore sharedInstance] assignWorkOrderToSelfInNearMe:aPointAnnotationView.mapAnnotation.woID completionBlock:^(NSInteger type, NSError *error) {
                                          
                                          [SVProgressHUD dismiss];
                                          self.userInteractionEnabled = YES;
                                          
                                          if (error) {
                                              [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                              return ;
                                          }
                                          else
                                          {
                                              MAIN((^{
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_MAPVIEW object:@{
                                                                                                                                                KEY_OF_TYPE:TYPE_OF_ASSIGN_NEAR_WORKORDER,
                                                                                                                                                KEY_OF_INFO:aPointAnnotationView.mapAnnotation.woID,}];
                                                  
                                                  if (delegate && [delegate respondsToSelector:@selector(routeMapView:didTappedPointAnnotationView:)]) {
                                                      [delegate routeMapView:self didTappedPointAnnotationView:aPointAnnotationView];
                                                      
                                                  }
                                              }));
                                          }
                                      }];
                                      
                                  }
                              }];
            NSLog(@"AnnotationViewType_NearMe");
        }
            break;
        default:
            break;
    }
}

- (void)showCheckInAlert:(AMWorkOrder *)workorder annotationView:(PointAnnotationView *)aPointAnnotationView {
    [UIAlertView showWithTitle:@""
                       message:MyLocal(@"Are you sure you want to Check In ?")
             cancelButtonTitle:MyLocal(@"NO")
             otherButtonTitles:@[MyLocal(@"YES")]
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              return;
                          }
                          else
                          {
                              [[AMLogicCore sharedInstance] checkInWorkOrder:workorder completionBlock:^(NSInteger type, NSError *error) {
                                  if (error) {
                                      [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                      return ;
                                  }
                                  else
                                  {
                                      MAIN((^{
                                          self.currentInCheckinStatusMapAnnotation = nil;
                                          self.currentInCheckoutStatusMapAnnotation = aPointAnnotationView.mapAnnotation;
                                          [self changePointAnnotation:currentInCheckoutStatusMapAnnotation withType:AnnotationViewType_CheckOut animation:YES];
                                          
                                          [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_MAPVIEW object:@{
                                                                                                                                        KEY_OF_TYPE:TYPE_OF_LIST_REFRESH,
                                                                                                                                        KEY_OF_INFO:@"",}];
                                          
                                          if (delegate && [delegate respondsToSelector:@selector(routeMapView:didTappedPointAnnotationView:)]) {
                                              [delegate routeMapView:self didTappedPointAnnotationView:aPointAnnotationView];
                                              
                                          }
                                      }));
                                  }
                              }];
                              
                          }
                      }];
}

#pragma mark -

- (AnnotationInfo *)pointAnnotationWithId:(NSString *)aId
{
    AnnotationInfo *aPoint = nil;
    for (AnnotationInfo *point in self.mapAnnotations) {
        if ([point.woID isEqualToString:aId]) {
            aPoint = point;
            break;
        }
    }
    
    return aPoint;
}

- (void)changePointAnnotation:(AnnotationInfo *)aAnnotation withType:(AnnotationViewType)aType animation:(BOOL)aAnimation
{
    AnnotationInfo *aMapAnnotation = nil;
    
    NSMutableArray *arrTemp = [mapAnnotations mutableCopy];
    
    for (AnnotationInfo *aMap in arrTemp) {
        if ([aMap.woID isEqualToString:aAnnotation.woID]) {
            aMap.viewType = aType;
            aMapAnnotation = aMap;
            break;
        }
    }
    
    aAnnotation.viewType = aType;
    
    PointAnnotationView *aPointView = (PointAnnotationView *)[self.mapShowView viewForAnnotation:aMapAnnotation];
    aPointView.mapAnnotation.viewType = aType;
    [aPointView changeType:aType withInfo:nil];
}

#pragma mark - Refresh Current Location

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation* newLocation = [locations lastObject];
    if(newLocation.horizontalAccuracy < kCLLocationAccuracyHundredMeters)
    {
        if(self.currentLocation)
        {
            CGFloat distance = [newLocation
                                distanceFromLocation:self.currentLocation];
            
            if(distance < 1.0f)
            {
                return;
            }
        }
    }
    
    [self refreshCurrentAnnotationWithLocation:newLocation];
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [manager stopUpdatingLocation];
    switch([error code]) {
        case kCLErrorDenied:
            [self stopAutoRefreshCurrentAnnotation];
            [self openGPSTips];
            break;
        case kCLErrorLocationUnknown:
            break;
        default:
            break;
    }
}

-(void)openGPSTips{
    UIAlertView *alet = [[UIAlertView alloc] initWithTitle:MyLocal(@"Location Services disabled") message:MyLocal(@"Google Maps needs access to your location. Please turn on Location Services in your device settings.") delegate:self cancelButtonTitle:nil otherButtonTitles:MyLocal(@"OK"), nil];
    [alet show];
}

#pragma mark -

- (void)refreshCurrentAnnotationWithLocation:(CLLocation *)aLocation
{
    
#if TARGET_IPHONE_SIMULATOR
    //    aLocation = [[CLLocation alloc] initWithLatitude:(INITLatitude + random() % 100 / 10000.0) longitude:(INITLongitude + random() % 100 / 10000.0)];
    //    aLocation = [[CLLocation alloc] initWithLatitude:INITLatitude longitude:INITLongitude];
#endif
    
#if TEST_FOR_GOOGLE_MAP
    //    aLocation = [[CLLocation alloc] initWithLatitude:(INITLatitude + random() % 100 / 10000.0) longitude:(INITLongitude + random() % 100 / 10000.0)];
    aLocation = [[CLLocation alloc] initWithLatitude:INITLatitude longitude:INITLongitude];
#endif
    
    AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if([mapAnnotations count] > appdelegate.woCount) {
        //CHANGE:ITEM-000118
        [self beep];
        appdelegate.woCount = [mapAnnotations count];
    }

    
    [[AMLogicCore sharedInstance] updateUserLocationWithLongitude:[NSNumber numberWithDouble:aLocation.coordinate.longitude] andLatitude:[NSNumber numberWithDouble:aLocation.coordinate.latitude]];
    
    self.currentLocation = aLocation;
    
    [AMUtilities saveCurrentLongitude:[NSNumber numberWithDouble:aLocation.coordinate.longitude] andLatitude:[NSNumber numberWithDouble:aLocation.coordinate.latitude]];
    
    AnnotationInfo *info = [[AnnotationInfo alloc] init];
    info.partType = MapLocationType_CurrentPoint;
    info.location = aLocation;
    
    if (mapAnnotations && [mapAnnotations count] > 0) {
        
        NSInteger iIndex = [self.mapAnnotations count];
        
        for (AnnotationInfo *aMapAnnotation in self.mapAnnotations) {
            if (aMapAnnotation.partType == MapLocationType_CurrentPoint) {
                iIndex = [mapAnnotations indexOfObject:aMapAnnotation];
                break;
            }
        }
        
        if (iIndex < [self.mapAnnotations count]) {
            [self.mapShowView removeAnnotation:[self.mapAnnotations objectAtIndex:iIndex]];
            [self.mapAnnotations replaceObjectAtIndex:iIndex withObject:info];
            [self.mapShowView addAnnotations:mapAnnotations];
            return;
        }
    }
    
    self.mapAnnotations = [NSMutableArray array];
    [self.mapAnnotations addObject:info];
    [self.mapShowView addAnnotations:mapAnnotations];
}

//CHANGE:ITEM-000118
- (void) beep {

    AudioServicesPlaySystemSound(1007);
    //NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
    //SystemSoundID soundID;
    //AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    //AudioServicesPlaySystemSound (soundID);
}

#pragma mark - Draw Routes or Points

-(void)clearRoutes
{
    [self.mapShowView clearRoutes];
}

-(void)clearCircle
{
    [self.mapShowView clearCircle];
}

- (void)drawCircleWithCenter:(CLLocationCoordinate2D)aCenter radius:(CGFloat )aRadius
{
    [self.mapShowView clearCircle];
    
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:self.currentLocation.coordinate radius:aRadius];
    [self.mapShowView addOverlay: circle];
    [self centerWithCircle];
}

//绘制路线
- (void)drawRoutesOnMap:(NSArray *)lines
{
    self.mapShowView.routes = lines;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapShowView clearRoutes];
        [self.mapShowView updateRouteView];
    });
}

//绘制坐标
- (void)refreshAnnotations:(NSMutableArray *)aAnnotations
{
    [self.mapShowView removeAnnotations:mapAnnotations];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        if (self.mapAnnotations && [self.mapAnnotations count] > 0) {
            NSMutableArray *arrTemp = [self.mapAnnotations mutableCopy];
            for (AnnotationInfo *aMapAnnotation in self.mapAnnotations) {
                if (aMapAnnotation.partType == MapLocationType_TargetPoint) {
                    [arrTemp removeObject:aMapAnnotation];
                }
            }
            self.mapAnnotations = arrTemp;
        }
        else {
            self.mapAnnotations = [NSMutableArray array];
        }
        
        NSMutableArray *arrAnnotations = [aAnnotations mutableCopy];
        for (AnnotationInfo *info in arrAnnotations) {
            [self.mapAnnotations addObject:info];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.arrAnnotationViews removeAllObjects];
            [self.mapShowView addAnnotations:mapAnnotations];
            
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.mapShowView centerMapWithAnnotations];
            });
        });
    });
}

- (void)refreshNearAnnotations:(NSMutableArray *)aAnnotations
{
    [self.mapShowView removeAnnotations:mapAnnotations];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        if (self.mapAnnotations && [self.mapAnnotations count] > 0) {
            NSMutableArray *arrTemp = [self.mapAnnotations mutableCopy];
            for (AnnotationInfo *aMapAnnotation in self.mapAnnotations) {
                if (aMapAnnotation.partType == MapLocationType_TargetPoint) {
                    [arrTemp removeObject:aMapAnnotation];
                }
            }
            self.mapAnnotations = arrTemp;
        }
        else {
            self.mapAnnotations = [NSMutableArray array];
        }
        
        NSMutableArray *arrAnnotations = [aAnnotations mutableCopy];
        for (AnnotationInfo *info in arrAnnotations) {
            [self.mapAnnotations addObject:info];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.arrAnnotationViews removeAllObjects];
            [self.mapShowView addAnnotations:mapAnnotations];
        });
    });
}

#pragma mark - Auto Update Current Location

- (void)start
{
    if (IS_OS_8_OR_LATER) {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager performSelector:@selector(requestWhenInUseAuthorization) withObject:nil];
        }
    }
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startUpdatingLocation];
}

- (void)stop
{
    [self.locationManager stopUpdatingLocation];
}

- (void)startAutoRefreshCurrentAnnotation
{
    if (!lcoationRepeatTimer) {
        lcoationRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:TIME_OF_MAP_CURRENT_POINT_REFRESH target:self selector:@selector(start) userInfo:nil repeats:YES];
    }
    
    [lcoationRepeatTimer fire];
}

- (void)stopAutoRefreshCurrentAnnotation
{
    [self stop];
    
    if(lcoationRepeatTimer != nil){
        [lcoationRepeatTimer invalidate];
        lcoationRepeatTimer = nil;
    }
}
@end
