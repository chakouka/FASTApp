//
//  AMNearMeViewController.m
//  AramarkFSP
//
//  Created by FYH on 9/1/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNearMeViewController.h"
#import "GoogleUtility.h"
#import "GoogleRouteManage.h"
#import "RouteMapView.h"
#import "AMNearOrderListViewController.h"

#define FRAME_OF_DETAILPANEL_NORMAL_HALF    CGRectMake(300, 250, 630, 716)
#define FRAME_OF_DETAILPANEL_NORMAL_TOP     CGRectMake(300, 0, 630, 716)
#define FRAME_OF_DETAILPANEL_NORMAL_BOTTON  CGRectMake(300, 716, 630, 716)
#define FRAME_OF_DETAILPANEL_FULL_HALF      CGRectMake(0, 250, 930, 716)
#define FRAME_OF_DETAILPANEL_FULL_TOP       CGRectMake(0, 0, 930, 716)
#define FRAME_OF_DETAILPANEL_FULL_BOTTON    CGRectMake(0, 716, 930, 716)
#define FRAME_OF_ROUTE_FULL                 FRAME_OF_DETAILPANEL_FULL_TOP
#define FRAME_OF_ROUTE_RIGHT_BIG            FRAME_OF_DETAILPANEL_NORMAL_TOP
#define FRAME_OF_ROUTE_RIGHT_SMALL          CGRectMake(300, 0, 630, 250)
#define FRAME_OF_WORKORDERLISTVIEW_HIDDEN   CGRectMake(-300.0, 0.0, 300.0, 716.0)
#define FRAME_OF_WORKORDERLISTVIEW_SHOW     CGRectMake(0.0, 0.0, 300.0, 716.0)

typedef NS_ENUM (NSInteger, PositionRouteView) {
	PositionRouteView_Small = 0,
	PositionRouteView_Half,
	PositionRouteView_Full,
};

@interface AMNearMeViewController ()
<
RouteMapViewDelegate
>
{
    AMNearOrderListViewController *nearOrderListVC;
	RouteMapView *routeView;
    AnnotationInfo *selectedAnnotationInfo;
    PositionRouteView routeViewPosition;
    CGFloat currentRadius;
}

@property (nonatomic, strong) RouteMapView *routeView;
@property (nonatomic, strong) AMNearOrderListViewController *nearOrderListVC;

@end

@implementation AMNearMeViewController
@synthesize routeView;
@synthesize nearOrderListVC;
@synthesize show;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_MAPVIEW object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.show = NO;
        currentRadius = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.screenName = @"Near Me Screen";
    
    [self viewInitialization];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromMapView:) name:NOTIFICATION_FROM_MAPVIEW object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromNearOrderListViewController:) name:NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View

- (void)viewInitialization {
    
	CLLocationCoordinate2D centerCoordinate;
	centerCoordinate.latitude = INITLatitude;
	centerCoordinate.longitude = INITLongitude;
    
	routeView = [[RouteMapView alloc] initWithFrame:FRAME_OF_ROUTE_FULL Region:[AMUtilities regionWithCenterCoordinate:centerCoordinate]];
	routeView.delegate = self;
    routeView.mapType = MapType_Circle;
	[self.viewMainPanel insertSubview:routeView atIndex:0];
    [self.viewLeftListPanel addSubview:self.nearOrderListVC.view];
    
	self.viewLeftListPanel.layer.borderWidth = 1.0;
	self.viewLeftListPanel.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(void)refreshdata
{
    BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
    
    if (!isNetworkReachable) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
        return;
    }
    
    [self requestForCenter:self.routeView.currentLocation andRadius:currentRadius];
}

#pragma mark -

- (AMNearOrderListViewController *)nearOrderListVC {
	if (!nearOrderListVC) {
		nearOrderListVC = [[AMNearOrderListViewController alloc] initWithNibName:@"AMNearOrderListViewController" bundle:nil];
	}
    
	return nearOrderListVC;
}

#pragma mark - Near Me List

- (void)refreshList
{
    
}

- (void)assignWorkorder:(NSString *)aWoId
{
    [self.nearOrderListVC removeWorkOrder:aWoId];
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    for (NSInteger i = 0; i < [self.nearOrderListVC.localWorkOrders count]; i++) {
        AnnotationInfo *info = [[AMInfoManage sharedInstance] covertAnnotationInfoFromNearWorkOrderInfo:[self.nearOrderListVC.localWorkOrders objectAtIndex:i] withIndex:(i + 1)];
        if (info) {
            [annotations addObject:info];
        }
    }
    
    [self.routeView refreshNearAnnotations:annotations];
    //    [self.routeView centerWithCircle];
}

#pragma mark - Layout Change

- (void)changeLeftListPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
    
    self.show = !isHidden;
    
	[self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         if (isHidden) {
                             [self.viewLeftListPanel setFrame:CGRectMake(-300,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             
                             [self changeRouteViewWithPosition:PositionRouteView_Full animation:aAnimation];
                             
                             [self.nearOrderListVC viewWillDisappear:YES];
                         }
                         else {
                             [self.viewLeftListPanel setFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             
                             [self changeRouteViewWithPosition:PositionRouteView_Half animation:aAnimation];
                             
                             [self.nearOrderListVC viewWillAppear:YES];
                         }
                     }
     
	                 completion: ^(BOOL finished)
     {
         self.nearOrderListVC.show = !isHidden;
     }];
}

- (void)changeRouteViewWithPosition:(PositionRouteView)aPosition animation:(BOOL)aAnimation {
	routeViewPosition = aPosition;
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         switch (routeViewPosition) {
                             case PositionRouteView_Full:
                             {
                                 [self.routeView resizeWithFrame:FRAME_OF_ROUTE_FULL];
                             }
                                 break;
                                 
                             case PositionRouteView_Half:
                             {
                                 [self.routeView resizeWithFrame:FRAME_OF_ROUTE_RIGHT_BIG];
                             }
                                 break;
                                 
                             case PositionRouteView_Small:
                             {
                                 [self.routeView resizeWithFrame:FRAME_OF_ROUTE_RIGHT_SMALL];
                             }
                                 break;
                         }
                     } completion:NULL];
}

#pragma mark -

- (void)routeMapView:(RouteMapView *)aRouteView didTappedPointAnnotationView:(PointAnnotationView *)aPointAnnotationView
{
    
}

- (void)routeMapView:(RouteMapView *)aRouteView didTappedCancelAnnotationView:(PointAnnotationView *)aPointAnnotationView
{
    
}

#pragma mark -
- (void)dealWithNotiFromNearOrderListViewController:(NSNotification *)notification {
    if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_CELL_SELECTED]) {
		AMWorkOrder *workOrderInfo = [[notification object] objectForKey:KEY_OF_INFO];
		selectedAnnotationInfo = [[AMInfoManage sharedInstance] covertAnnotationInfoFromNearWorkOrderInfo:workOrderInfo withIndex:999];
		[self.routeView centerWithAnnotationInfo:selectedAnnotationInfo];
		[self.routeView selectAnnotationInfo:selectedAnnotationInfo];
	}
    else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_RADIUS_SELECTED]) {
		currentRadius = [[[notification object] objectForKey:KEY_OF_INFO] floatValue];
        [self.routeView centerWithAllAnnotations];
        [self requestForCenter:self.routeView.currentLocation andRadius:currentRadius];
	}
    else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_WORK_ORDER_LIST_CHANGE]) {
		NSMutableArray *arrTemp = [[[notification object] objectForKey:KEY_OF_INFO] mutableCopy];
        
		NSMutableArray *annotations = [NSMutableArray array];
        
		for (NSInteger i = 0; i < [arrTemp count]; i++) {
            AMWorkOrder *workorder = [arrTemp objectAtIndex:i];
            workorder.status = @"Queued";
            AnnotationInfo *info = [[AMInfoManage sharedInstance] covertAnnotationInfoFromLocalWorkOrderInfo:workorder withIndex:(i + 1)];
            if (info) {
                info.accountName = workorder.accountName;
                [annotations addObject:info];
            }
		}
        
        [self.routeView refreshNearAnnotations:annotations];
	}
}

- (void)dealWithNotiFromMapView:(NSNotification *)notification {
    if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_ASSIGN_NEAR_WORKORDER]) {
        [self assignWorkorder:[[notification object] objectForKey:KEY_OF_INFO]];
	}
}

#pragma mark -

-(void)requestForCenter:(CLLocation *)center andRadius:(CGFloat)aRadius
{
    //TODO:: Need add Queue
    
    [SVProgressHUD show];
    
    [self.routeView drawCircleWithCenter:center.coordinate radius:aRadius*kMile];
    
    BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
    if (!isNetworkReachable) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
        return;
    }

     NSMutableArray *annotations = [NSMutableArray array];
    
    [[AMLogicCore sharedInstance] searchNearByWorkOrders:center.coordinate distance:aRadius withCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        MAIN ( ^{
            if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
            }
            else
            {
                for (NSInteger i = 0; i < [responseData count]; i++) {
                    AnnotationInfo *info = [[AMInfoManage sharedInstance] covertAnnotationInfoFromNearWorkOrderInfo:[responseData objectAtIndex:i] withIndex:(i + 1)];
                    if (info) {
                        [annotations addObject:info];
                    }
                }
                NSLog(@"response data = %@", responseData);
                [self.nearOrderListVC refreshOrderList:responseData];
                [self.routeView refreshNearAnnotations:annotations];
                [self requestNearRoutesTimeDistanceWithList:self.nearOrderListVC.localWorkOrders];
            }
            
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)requestNearRoutesTimeDistanceWithList:(NSMutableArray *)aList
{
    NSMutableArray *arrInfos = [NSMutableArray array];
    for (NSInteger i = 0; i < [aList count]; i++) {
        AMWorkOrder *workorderTo = [aList objectAtIndex:i];
        GoogleRouteInfo *routeInfo = [[GoogleRouteInfo alloc] init];
        routeInfo.gId = workorderTo.woID;
        routeInfo.gFrom = [AMUtilities currentLocation];
        routeInfo.gTo = [[CLLocation alloc] initWithLatitude:[workorderTo.latitude floatValue] longitude:[workorderTo.longitude floatValue]];
        routeInfo.gMode = @"driving";
        [arrInfos addObject:routeInfo];
    }
    
    [[GoogleRouteManage sharedInstance] fetchRoutes:arrInfos completion:^(NSInteger type, id result, NSError *error) {
        MAIN(^{
            [self.nearOrderListVC refreshTimeAndDistanceBySingleRequest:result];
        });
    }];
}

@end
