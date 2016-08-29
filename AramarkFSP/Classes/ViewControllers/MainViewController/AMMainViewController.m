//
//  MainViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMMainViewController.h"
#import "AMLeftBarViewController.h"
#import "AMOrderListViewController.h"
#import "AMDetailPanelViewController.h"
#import "AMNewCaseViewController.h"
#import "AMNewLeadViewController.h"
#import "SFAuthenticationManager.h"
#import "AMSyncingManager.h"
#import "AnnotationInfo.h"
#import "RouteMapView.h"
#import "GoogleRouteResult.h"
#import "GoogleUtility.h"
#import "AMInfoManage.h"
#import "AMWorkOrder.h"
#import "AMLogicCore.h"
#import "PointAnnotationView.h"
#import "SVProgressHUD.h"
#import "AMCheckoutPanelViewController.h"
#import "TestManage.h"
#import "AMSignViewController.h"
#import "AMReportViewController.h"
#import "AMSummaryViewController.h"
#import "GoogleRouteManage.h"
#import "GoogleRouteInfo.h"
#import "AMNearMeViewController.h"
#import "AMBenchListViewController.h"
#import "AMBenchActiveListViewController.h"
#import "LanguageConfig.h"

typedef NS_ENUM (NSInteger, MainViewLayoutType) {
	MainViewLayoutType_MapOnly = 0,
	MainViewLayoutType_LeftListShow,
	MainViewLayoutType_LeftListShow_DetailPanel_Half,
	MainViewLayoutType_LeftListShow_DetailPanel_Top,
	MainViewLayoutType_LeftListShow_DetailPanel_Full,
	MainViewLayoutType_LeftListShow_CheckoutPanel_Half,
	MainViewLayoutType_LeftListShow_CheckoutPanel_Top,
	MainViewLayoutType_LeftListShow_CheckoutPanel_Full,
};

typedef NS_ENUM (NSInteger, PositionDetailPanel) {
	PositionDetailPanel_Bottom = 0,
	PositionDetailPanel_Half,
	PositionDetailPanel_Top,
	PositionDetailPanel_Full,
};

typedef NS_ENUM (NSInteger, PositionRouteView) {
	PositionRouteView_Small = 0,
	PositionRouteView_Half,
	PositionRouteView_Full,
};

typedef NS_ENUM (NSInteger, PositionBenchView) {
    PositionBenchView_Small = 0,
    PositionBenchView_Half,
    PositionBenchView_Full,
};

typedef NS_ENUM (NSInteger, PanelType) {
	PanelType_Main = 0,
	PanelType_Report,
	PanelType_Summary,
    PanelType_Case,
    PanelType_Lead,
    PanelType_NearMe,
    PanelType_Bench,
    PanelType_ActiveBench,
};


//#define TESTMODEL   1   //Use for test

#define ORIGINAL_Y_OF_DETAIL_HALF    250.0
#define OFFSET_OF_MAIN_TO_LOGOUT     200.0

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

@interface AMMainViewController ()
<
AMDetailPanelViewDelegate,
RouteMapViewDelegate,
AMCheckoutPanelViewControllerDelegate,
AMSignViewControllerDelegate,
UIGestureRecognizerDelegate
>
{
	AMOrderListViewController *orderListVC;
	AMLeftBarViewController *leftVC;
	AMDetailPanelViewController *detailVC;
	AMCheckoutPanelViewController *checkoutVC;
	AMSummaryViewController *summaryVC;
	AMReportViewController *reportVC;
    AMNewCaseViewController *caseVC;
    AMNewLeadViewController *leadVC;
    AMNearMeViewController *nearMeVC;
    AMBenchListViewController *benchListVC;
    AMBenchActiveListViewController *benchActiveListVC;
    
	PositionDetailPanel detailPanelPosition;
	PositionDetailPanel checkoutPanelPosition;
	PositionDetailPanel beforeDetailPanelPosition;
	PositionDetailPanel beforeCheckoutPanelPosition;
    
	PositionRouteView routeViewPosition;
    PositionBenchView benchViewPosition;
    PositionBenchView benchActiveViewPosition;
	BOOL isFullScreen;
	BOOL isLogOutViewShow;
    BOOL shouldDisappearDetailVC;
    
    BOOL willSwitchLanguage; //if user switch language from setting but tap No to ignore language switched.
    
	RouteMapView *routeView;
    
	AnnotationInfo *selectedAnnotationInfo;
	AMSignViewController *signVC;
	PanelType currentShowPanel;
    
    UIPanGestureRecognizer *panRecognizer;
}

@property (nonatomic, assign) BOOL isFullScreen;    //Default is NO
@property (nonatomic, assign) BOOL isLogOutViewShow;  //Default is NO
@property (nonatomic, assign) PositionDetailPanel detailPanelPosition;
@property (nonatomic, assign) PositionDetailPanel checkoutPanelPosition;
@property (nonatomic, assign) PositionDetailPanel beforeDetailPanelPosition;
@property (nonatomic, assign) PositionDetailPanel beforeCheckoutPanelPosition;
@property (nonatomic, assign) PositionRouteView routeViewPosition;
@property (nonatomic, assign) PanelType currentShowPanel;
@property (nonatomic, strong) AMOrderListViewController *orderListVC;
@property (nonatomic, strong) AMLeftBarViewController *leftVC;
@property (nonatomic, strong) AMDetailPanelViewController *detailVC;
@property (nonatomic, strong) AMCheckoutPanelViewController *checkoutVC;
@property (nonatomic, strong) AMReportViewController *reportVC;
@property (nonatomic, strong) AMNewCaseViewController *caseVC;
@property (nonatomic, strong) AMNewLeadViewController *leadVC;
@property (nonatomic, strong) AMNearMeViewController *nearMeVC;
@property (nonatomic, strong) AMBenchListViewController *benchListVC;
@property (nonatomic, strong) AMBenchActiveListViewController *benchActiveListVC;
@property (nonatomic, strong) RouteMapView *routeView;
@property (nonatomic, strong) UIView *benchView;
@property (nonatomic, strong) UIView *benchActiveView;
@property (nonatomic, strong) AMSignViewController *signVC;
@property (nonatomic, strong) AMSummaryViewController *summaryVC;
@property (strong, nonatomic) NSOperationQueue *requestQueue;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UILabel *labelTHello;
@property (weak, nonatomic) IBOutlet UIButton *btnClearCache;

@end

@implementation AMMainViewController
@synthesize requestQueue;
@synthesize currentShowPanel;
@synthesize summaryVC;
@synthesize signVC;
@synthesize isFullScreen;
@synthesize isLogOutViewShow;
@synthesize detailPanelPosition;
@synthesize checkoutPanelPosition;
@synthesize beforeCheckoutPanelPosition;
@synthesize beforeDetailPanelPosition;
@synthesize routeViewPosition;
@synthesize orderListVC;
@synthesize leftVC;
@synthesize detailVC;
@synthesize checkoutVC;
@synthesize reportVC;
@synthesize caseVC;
@synthesize leadVC;
@synthesize routeView;
@synthesize benchView;
@synthesize benchActiveView;
@synthesize nearMeVC;
@synthesize benchListVC;
@synthesize benchActiveListVC;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMBENCHLISTVIEWCONTROLLER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMBENCHACTIVELISTVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_CHECKOUTPANELVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_MAPVIEW object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_STARTING_EDITING_MODE object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_LOGICCORE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RELOAD_RELATED_WORKORDER_LIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WORK_ORDER_STATUS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_WORK_ORDER_NEED_REFRESH object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
//    [USER_DEFAULT removeObserver:self forKeyPath:kAMAPPLICATION_CURRENT_LANGUAGE_KEY];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		detailPanelPosition = PositionDetailPanel_Bottom;
		checkoutPanelPosition = PositionDetailPanel_Bottom;
		routeViewPosition = PositionRouteView_Full;
		beforeDetailPanelPosition = detailPanelPosition;
		beforeCheckoutPanelPosition = checkoutPanelPosition;
        requestQueue = [[NSOperationQueue alloc] init];
        [requestQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    //To indicate that this view is displayed in Google Analytics View Report
    self.screenName = @"Home Screen";
    
    willSwitchLanguage = YES;
    
    DLog(@"File Path : %@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    
	[self viewInitialization];
    [self.labelWelcome setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromLeftViewController:) name:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromOrderListViewController:) name:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromBenchListViewController:) name:NOTIFICATION_FROM_AMBENCHLISTVIEWCONTROLLER object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromBenchActiveListViewController:) name:NOTIFICATION_FROM_AMBENCHACTIVELISTVIEWCONTROLLER object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromDetailPanelViewController:) name:NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromCheckoutPanelViewController:) name:NOTIFICATION_FROM_CHECKOUTPANELVIEWCONTROLLER object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromMapView:) name:NOTIFICATION_FROM_MAPVIEW object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotificationToMoveUpView) name:NOTIFICATION_STARTING_EDITING_MODE object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromLogiccore:) name:NOTIFICATION_FROM_LOGICCORE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderListLoadData) name:NOTIFICATION_RELOAD_RELATED_WORKORDER_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderListLoadData) name:NOTIFICATION_WORK_ORDER_STATUS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCurrentWorkOrder) name:NOTIFICATION_WORK_ORDER_NEED_REFRESH object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultValueChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
//    [USER_DEFAULT addObserver:self forKeyPath:kAMAPPLICATION_CURRENT_LANGUAGE_KEY options:NSKeyValueObservingOptionNew context:NULL];
    
    [AMUtilities refreshFontInView:self.viewLogOut];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self userInteractionEnabled:YES];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - TEST

- (NSMutableArray *)addWorkOrder:(AMWorkOrder *)aWorkOrder toList:(NSMutableArray *)aList {
	NSMutableArray *arrList = [aList mutableCopy];
    
	if ([arrList count] == 0) {
		[arrList addObject:aWorkOrder];
		return arrList;
	}
    
	BOOL needAdd = YES;
    
	for (AMWorkOrder *aInfo in arrList) {
		if ([aInfo isEqual:aWorkOrder]) {
			needAdd = NO;
			break;
		}
	}
    
	if (needAdd) {
		[arrList addObject:aWorkOrder];
	}
    
	return arrList;
}

#pragma mark - View

- (void)viewInitialization {
   
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBarHidden = YES;
    [self.viewLogin setBackgroundColor:UIColor_BLACK];
    [self.viewMainPanel setBackgroundColor:UIColor_BACKGROUND];
    [self.viewLeftPanel setBackgroundColor:UIColor_RED];
    [self.viewTitle setBackgroundColor:UIColor_BLACK];
    
    [self.viewLeftPanel addSubview:self.leftVC.view];
    
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = INITLatitude;
    centerCoordinate.longitude = INITLongitude;
    
    routeView = [[RouteMapView alloc] initWithFrame:FRAME_OF_ROUTE_FULL Region:[AMUtilities regionWithCenterCoordinate:centerCoordinate]];
    routeView.delegate = self;
    routeView.mapType = MapType_Route;
    [self.viewMainPanel insertSubview:routeView atIndex:0];
    
#ifdef TESTMODEL
	[self dataInitialization];
	[SVProgressHUD dismiss];
	[self.view setUserInteractionEnabled:YES];
#else
    BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
//    BOOL isReachable = [[[MKNetworkEngine alloc] initWithHostName:@""] isReachable];
    if (isNetworkReachable) {
        DLog(@"The application is working with online Mode");
    #ifdef TEST_FOR_SVPROGRESSHUD
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%s", __FUNCTION__]];
    #else
        [SVProgressHUD show];
    #endif
        [self.view setUserInteractionEnabled:NO];
        [[AMLogicCore sharedInstance] startInitialization: ^(NSInteger type, NSError *error) {
            NSLog(@"MainViewController viewDidLoad initialCompletionHandler");
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:USER_DEFAULT_IN_INITIALIZATION];
                [SVProgressHUD dismiss];
                [self.view setUserInteractionEnabled:YES];
                
                [self setupView];
                [self dataInitialization];
                
                if (error) {
                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                    return ;
                }
            });
            
        }];
    } else {
        DLog(@"The application is working with offline Mode");
        [self setupView];
        [self dataInitialization];
    }
	
#endif
}

-(void)setupView
{
    [self.viewCheckoutPanel addSubview:self.checkoutVC.view];
//    [self.viewReportPanel addSubview:self.reportVC.view];
//    [self.viewSummaryPanel addSubview:self.summaryVC.view];
//    [self.viewCasePanel addSubview:self.caseVC.view];
//    [self.viewLeadPanel addSubview:self.leadVC.view];
//    [self.viewNearMePanel addSubview:self.nearMeVC.view];
    
    [self changePanelWithType:PanelType_Main];
    
    self.viewLeftListPanel.layer.borderWidth = 1.0;
    self.viewLeftListPanel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    signVC = [[AMSignViewController alloc] initWithNibName:@"AMSignViewController" bundle:nil];
    [self.viewMain addSubview:signVC.view];
    signVC.delegate = self;
    signVC.view.hidden = YES;
    
    self.labelWelcome.text = MyLocal(@"Welcome");
    self.labelTHello.text = MyLocal(@"Hello");
    
    [self.btnLogout setTitle:MyLocal(@"Log Out") forState:UIControlStateNormal];
    [self.btnLogout setTitle:MyLocal(@"Log Out") forState:UIControlStateHighlighted];
    
    [self.btnClearCache setTitle:MyLocal(@"Clear Cache") forState:UIControlStateNormal];
    [self.btnClearCache setTitle:MyLocal(@"Clear Cache") forState:UIControlStateHighlighted];
    
//    [self.viewLeftListPanel addSubview:self.orderListVC.view];
//    [self.viewDetailPanel addSubview:self.detailVC.view];
}

- (void)dataInitialization {
    BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
    if (!isNetworkReachable) {//if re-init the application, need to setup uesr data from User Default, to be able to call local database or furture sync once network available
        [[AMLogicCore sharedInstance] setupOfflineData];
    }
    AMUser *user = [[AMLogicCore sharedInstance] getSelfUserInfo];
    if (!user) {
        self.labelName.text = [USER_DEFAULT objectForKey:kAMLoggedUserNameKey];
        self.labelWelcome.text = [NSString stringWithFormat:@"%@ %@",MyLocal(@"Welcome"), [USER_DEFAULT objectForKey:kAMLoggedUserNameKey] ? [USER_DEFAULT objectForKey:kAMLoggedUserNameKey] : @""];
    } else {
        self.labelName.text = user.displayName;
        self.labelWelcome.text = [NSString stringWithFormat:@"%@ %@",MyLocal(@"Welcome"), user.displayName ? user.displayName : @""];
    }
//    [USER_DEFAULT setObject:user.userID forKey:USRDFTSELFUID];
//    [USER_DEFAULT setObject:user.displayName forKey:kAMLoggedUserNameKey];
//    [USER_DEFAULT synchronize];
	
	self.imageHead.image = [UIImage imageWithData:[[AMLogicCore sharedInstance] getPhotoDataByName:user.photoUrl]];
	self.imageHead.layer.masksToBounds = YES;
	self.imageHead.layer.cornerRadius = 50;
	self.imageHead.layer.borderWidth = 5.0;
	self.imageHead.layer.borderColor = UIColor_RED.CGColor;
    
	[self orderListLoadData];
}

- (void)refreshOrderListStatus
{
#ifdef TESTMODEL
    NSArray *arrResult = [[TestManage sharedInstance] arrLocalList];
#else
    NSArray *arrResult = [[AMLogicCore sharedInstance] getTodayWorkOrderList];
#endif
    
    DLog(@"arrResult : %@",arrResult);
    
    [self.orderListVC refreshWorkOrderStatus:[NSMutableArray arrayWithArray:arrResult]];
}

- (void)orderListLoadData {
    
    MAIN(^{
    
#ifdef TESTMODEL
        NSArray *arrResult = [[TestManage sharedInstance] arrLocalList];
#else
        NSArray *arrResult = [[AMLogicCore sharedInstance] getTodayWorkOrderList];
#endif
        
        DLog(@"arrResult : %@",arrResult);
        
        [self.orderListVC refreshOrderList:[NSMutableArray arrayWithArray:arrResult]];
        
         [self requestRoutesTimeDistanceWithList:self.orderListVC.localWorkOrders];
        
        if ([self.orderListVC.localWorkOrders count] == 0) {
            [self refreshMapWithList:[NSMutableArray arrayWithArray:arrResult]];
        }
        else
        {
            [self refreshMapWithList:self.orderListVC.localWorkOrders];
        }
        
        if ([self.orderListVC.localWorkOrders count] == 0 && [arrResult count] == 0) {
            [self.routeView clearRoutes];
            [self.routeView centerWithCurrentLocation];
        }
        
        shouldDisappearDetailVC = YES;
        if (self.detailVC.selectedWorkOrder) {
            for (AMWorkOrder *wo in arrResult) {
                if ([wo.woNumber isEqualToString:self.detailVC.selectedWorkOrder.woNumber]) {
                    shouldDisappearDetailVC = NO;
                    break;
                }
            }
            [self disappearDetailVC];
            if (!shouldDisappearDetailVC) { //Intend to update lable count(pending WO amount of Account/POS)
                [self refreshCurrentWorkOrder];
                //            [self.detailVC assignNewWorkOrder:[[AMLogicCore sharedInstance] getWorkOrderInfoByID:self.orderListVC.selectedWorkOrderId]];
            }
        }

    });
}

- (void)benchListLoadData {
    
    MAIN(^{
        
#ifdef TESTMODEL
        NSArray *arrResult = [[TestManage sharedInstance] arrLocalList];
#else
        NSArray *arrResult = [[AMLogicCore sharedInstance] getTodayWorkOrderList];
#endif
        
        DLog(@"arrResult : %@",arrResult);
        
        [self.benchListVC refreshOrderList:[NSMutableArray arrayWithArray:arrResult]];
        
        [self requestRoutesTimeDistanceWithList:self.orderListVC.localWorkOrders];
        
        if ([self.benchListVC.localWorkOrders count] == 0) {
            [self refreshMapWithList:[NSMutableArray arrayWithArray:arrResult]];
        }
        else
        {
            [self refreshMapWithList:self.benchListVC.localWorkOrders];
        }
        
        if ([self.benchListVC.localWorkOrders count] == 0 && [arrResult count] == 0) {
            [self.routeView clearRoutes];
            [self.routeView centerWithCurrentLocation];
        }
        
        shouldDisappearDetailVC = YES;
        if (self.detailVC.selectedWorkOrder) {
            for (AMWorkOrder *wo in arrResult) {
                if ([wo.woNumber isEqualToString:self.detailVC.selectedWorkOrder.woNumber]) {
                    shouldDisappearDetailVC = NO;
                    break;
                }
            }
            [self disappearDetailVC];
            if (!shouldDisappearDetailVC) { //Intend to update lable count(pending WO amount of Account/POS)
                [self refreshCurrentWorkOrder];
                //            [self.detailVC assignNewWorkOrder:[[AMLogicCore sharedInstance] getWorkOrderInfoByID:self.orderListVC.selectedWorkOrderId]];
            }
        }
        
    });
}
- (void)refreshCurrentWorkOrder
{
    [self.detailVC assignNewWorkOrder:self.detailVC.selectedWorkOrder];
}

- (void)disappearDetailVC
{
    if (shouldDisappearDetailVC) {
        if (!self.orderListVC.show) {
            [self changeLeftListPanelHidden:NO animation:YES];
        }
        [self changeRouteViewWithPosition:PositionRouteView_Half animation:YES];
        [self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:YES];
    }
}

- (void)refreshMapWithList:(NSMutableArray *)aList
{
    NSMutableArray *arrTemp = [aList mutableCopy];
    
	NSMutableArray *annotations = [NSMutableArray array];
    
	for (NSInteger i = 0; i < [arrTemp count]; i++) {
        AnnotationInfo *info = [[AMInfoManage sharedInstance] covertAnnotationInfoFromLocalWorkOrderInfo:[arrTemp objectAtIndex:i] withIndex:(i + 1)];
        if (info) {
            [annotations addObject:info];
        }
	}
    
    [self.routeView refreshAnnotations:annotations];
    [self requestRoutesWithList:arrTemp Optimize:self.orderListVC.isSortByDistance];
}

- (AMLeftBarViewController *)leftVC {
	if (!leftVC) {
		leftVC = [[AMLeftBarViewController alloc] initWithNibName:@"AMLeftBarViewController" bundle:nil];
	}
    
	return leftVC;
}

- (AMOrderListViewController *)orderListVC {
	if (!orderListVC) {
		orderListVC = [[AMOrderListViewController alloc] initWithNibName:@"AMOrderListViewController" bundle:nil];
	}
    
	return orderListVC;
}

- (AMDetailPanelViewController *)detailVC {
	if (!detailVC) {
		detailVC = [[AMDetailPanelViewController alloc] initWithNibName:@"AMDetailPanelViewController" bundle:nil];
		detailVC.delegate = self;
	}
    
	return detailVC;
}

- (AMCheckoutPanelViewController *)checkoutVC {
	if (!checkoutVC) {
		checkoutVC = [[AMCheckoutPanelViewController alloc] initWithNibName:@"AMCheckoutPanelViewController" bundle:nil];
		checkoutVC.delegate = self;
	}
    
	return checkoutVC;
}

- (AMReportViewController *)reportVC {
	if (!reportVC) {
		reportVC = [[AMReportViewController alloc] initWithNibName:@"AMReportViewController" bundle:nil];
	}
    
	return reportVC;
}

- (AMSummaryViewController *)summaryVC {
	if (!summaryVC) {
		summaryVC = [[AMSummaryViewController alloc] initWithNibName:@"AMSummaryViewController" bundle:nil];
	}
    
	return summaryVC;
}

- (AMNewLeadViewController *)leadVC {
	if (!leadVC) {
		leadVC = [[AMNewLeadViewController alloc] initWithNibName:@"AMNewLeadViewController" bundle:nil];
	}
    
	return leadVC;
}

- (AMNewCaseViewController *)caseVC {
	if (!caseVC) {
		caseVC = [[AMNewCaseViewController alloc] initWithNibName:@"AMNewCaseViewController" bundle:nil];
	}
    
	return caseVC;
}

- (AMNearMeViewController *)nearMeVC
{
    if (!nearMeVC) {
        nearMeVC = [[AMNearMeViewController alloc] initWithNibName:@"AMNearMeViewController" bundle:nil];
    }
    
    return nearMeVC;
}

- (AMBenchListViewController *)benchListVC
{
    if (!benchListVC) {
        benchListVC = [[AMBenchListViewController alloc] initWithNibName:@"AMBenchListViewController" bundle:nil];
    }
    
    return benchListVC;
}

- (AMBenchActiveListViewController *)benchActiveListVC
{
    if (!benchActiveListVC) {
        benchActiveListVC = [[AMBenchActiveListViewController alloc] initWithNibName:@"AMBenchActiveListViewController" bundle:nil];
    }
    
    return benchActiveListVC;
}
#pragma mark - Touch

- (void)addGuesture
{
    if (!panRecognizer) {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:nil];
        panRecognizer.maximumNumberOfTouches = 1;
        panRecognizer.delegate = self;
    }
    [self.view addGestureRecognizer:panRecognizer];
}

- (void)removeGuesture
{
    [self.view removeGestureRecognizer:panRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_CLICK_SCREEN,
                              KEY_OF_INFO:touch
                              };
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMMAINVIEWCONTROLLER object:dicInfo];
    return YES;
}

#pragma mark - Layout Change

- (void)changeLeftListPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
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
                             [self.orderListVC viewWillDisappear:YES];
                         }
                         else {
                             if (![self.viewLeftListPanel.subviews containsObject:self.orderListVC.view]) {
                                 [self.viewLeftListPanel addSubview:self.orderListVC.view];
                             }
                             
                             [self.viewLeftListPanel setFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             [self.orderListVC viewWillAppear:YES];
                         }
                     }
     
	                 completion: ^(BOOL finished)
     {
         self.orderListVC.show = !isHidden;
     }];
}

- (void)changeLeftActiveBenchPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
    [self changeBenchActiveViewWithPosition:PositionBenchView_Full animation:NO];
    
    [UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         if (isHidden) {
                             [self.viewActiveBenchPanel setFrame:CGRectMake(-300,
                                                                      0,
                                                                      CGRectGetWidth(self.viewActiveBenchPanel.frame),
                                                                      CGRectGetHeight(self.viewActiveBenchPanel.frame))];
                             [self.orderListVC viewWillDisappear:YES];
                         }
                         else {
                             if (![self.viewActiveBenchPanel.subviews containsObject:self.benchActiveListVC.view]) {
                                 [self.viewActiveBenchPanel addSubview:self.orderListVC.view];
                             }
                             
                             [self.viewActiveBenchPanel setFrame:CGRectMake(92,
                                                                      52,
                                                                      CGRectGetWidth(self.viewActiveBenchPanel.frame),
                                                                      CGRectGetHeight(self.viewActiveBenchPanel.frame))];
                             [self.benchActiveListVC viewWillAppear:YES];
                         }
                     }
     
                     completion: ^(BOOL finished)
     {
         self.benchActiveListVC.show = !isHidden;
     }];
}

- (void)changeLeftBenchPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
    [self changeBenchViewWithPosition:PositionBenchView_Full animation:NO];
    
    [UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         if (isHidden) {
                             [self.viewBenchPanel setFrame:CGRectMake(-300,
                                                                         0,
                                                                         CGRectGetWidth(self.viewBenchPanel.frame),
                                                                         CGRectGetHeight(self.viewBenchPanel.frame))];
                             [self.orderListVC viewWillDisappear:YES];
                         }
                         else {
                             if (![self.viewBenchPanel.subviews containsObject:self.benchListVC.view]) {
                                 [self.viewBenchPanel addSubview:self.orderListVC.view];
                             }
                             
                             [self.viewBenchPanel setFrame:CGRectMake(92,
                                                                         52,
                                                                         CGRectGetWidth(self.viewBenchPanel.frame),
                                                                         CGRectGetHeight(self.viewBenchPanel.frame))];
                             [self.benchListVC viewWillAppear:YES];
                         }
                     }
     
                     completion: ^(BOOL finished)
     {
         self.benchListVC.show = !isHidden;
     }];
}

- (void)showFullDetailScreenWithAnimation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         [self changeLeftListPanelHidden:YES animation:NO];
                         [self changeDetailPanelViewTo:PositionDetailPanel_Full animation:NO];
                         [self.view layoutIfNeeded];
                     } completion: ^(BOOL finished) {
                         CGRect newRect = self.detailVC.topTabVC.view.frame;
                         newRect.size.width = 560.0 * 1.2;
                         self.detailVC.topTabVC.view.frame = newRect;
                     }];
}

- (void)hiddenFullDetailScreenWithAnimation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         [self changeLeftListPanelHidden:NO animation:NO];
                         if (self.beforeDetailPanelPosition == PositionDetailPanel_Top) {
                             [self changeDetailPanelViewTo:PositionDetailPanel_Top animation:NO];
                         }
                         else if (self.beforeDetailPanelPosition == PositionDetailPanel_Half) {
                             [self changeDetailPanelViewTo:PositionDetailPanel_Half animation:NO];
                             [self changeRouteViewWithPosition:PositionRouteView_Small animation:YES];
                         }
                         [self.view layoutIfNeeded];
                     } completion: ^(BOOL finished) {
                         CGRect newRect = self.detailVC.topTabVC.view.frame;
                         newRect.size.width = 560.0;
                         self.detailVC.topTabVC.view.frame = newRect;
                     }];
}

- (void)changeDetailPanelViewTo:(PositionDetailPanel)aPosition animation:(BOOL)aAnimation {
	detailPanelPosition = aPosition;
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         switch (aPosition) {
                             case PositionDetailPanel_Top:
                             {
                                 self.viewDetailPanel.frame = FRAME_OF_DETAILPANEL_NORMAL_TOP;
                                 [self.detailVC changeFrameTo:FrameType_Top animation:aAnimation];
                                 self.beforeDetailPanelPosition = aPosition;
                             }
                                 break;
                                 
                             case PositionDetailPanel_Half:
                             {
                                 self.viewDetailPanel.frame = FRAME_OF_DETAILPANEL_NORMAL_HALF;
                                 if (![self.viewDetailPanel.subviews containsObject:self.detailVC.view]) {
                                     [self.viewDetailPanel addSubview:self.detailVC.view];
                                 }
                                 [self.detailVC changeFrameTo:FrameType_Normal animation:aAnimation];
                                 self.beforeDetailPanelPosition = aPosition;
                             }
                                 break;
                                 
                             case PositionDetailPanel_Bottom:
                             {
                                 self.viewDetailPanel.frame = FRAME_OF_DETAILPANEL_NORMAL_BOTTON;
                                 [self.detailVC changeFrameTo:FrameType_Normal animation:aAnimation];
                                 self.beforeDetailPanelPosition = aPosition;
                                 
                                 [self.orderListVC deSelectRow];
                             }
                                 break;
                                 
                             case PositionDetailPanel_Full:
                             {
                                 self.viewDetailPanel.frame = FRAME_OF_DETAILPANEL_FULL_TOP;
                                 [self.detailVC changeFrameTo:FrameType_Full animation:aAnimation];
                             }
                                 break;
                                 
                             default:
                                 break;
                         }
                     } completion: NULL];
}

- (void)showFullCheckoutScreenWithAnimation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         [self changeLeftListPanelHidden:YES animation:NO];
                         [self changeCheckoutPanelViewTo:PositionDetailPanel_Full animation:YES];
                         [self.view layoutIfNeeded];
                     } completion:NULL];
}

- (void)hiddenFullCheckoutScreenWithAnimation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         [self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:YES];
                         [self.view layoutIfNeeded];
                     } completion:NULL];
}

- (void)changeCheckoutPanelViewTo:(PositionDetailPanel)aPosition animation:(BOOL)aAnimation {
	checkoutPanelPosition = aPosition;
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         switch (aPosition) {
                             case PositionDetailPanel_Top:
                             {
                                 self.viewCheckoutPanel.frame = FRAME_OF_DETAILPANEL_FULL_TOP;
                                 [self.checkoutVC changeFrameTo:FrameType_Top animation:aAnimation];
                                 self.beforeCheckoutPanelPosition = aPosition;
                             }
                                 break;
                                 
                             case PositionDetailPanel_Half:
                             {
                                 self.viewCheckoutPanel.frame = FRAME_OF_DETAILPANEL_FULL_HALF;
                                 [self.checkoutVC changeFrameTo:FrameType_Normal animation:aAnimation];
                                 self.beforeCheckoutPanelPosition = aPosition;
                             }
                                 break;
                                 
                             case PositionDetailPanel_Bottom:
                             {
                                 self.viewCheckoutPanel.frame = FRAME_OF_DETAILPANEL_FULL_BOTTON;
                                 [self.checkoutVC changeFrameTo:FrameType_Normal animation:aAnimation];
                                 self.beforeCheckoutPanelPosition = aPosition;
                             }
                                 break;
                                 
                             case PositionDetailPanel_Full:
                             {
                                 self.viewCheckoutPanel.frame = FRAME_OF_DETAILPANEL_FULL_TOP;
                                 [self.checkoutVC changeFrameTo:FrameType_Full animation:aAnimation];
                             }
                                 break;
                         }
                     } completion:NULL];
}

- (void)showLogOutViewWithAnimation:(BOOL)aAnimation {
    
    AMUser *user = [[AMLogicCore sharedInstance] getSelfUserInfo];
	self.labelName.text = user.displayName;
	self.imageHead.image = [UIImage imageWithData:[[AMLogicCore sharedInstance] getPhotoDataByName:user.photoUrl]];
	self.labelWelcome.text = [NSString stringWithFormat:@"%@ %@",MyLocal(@"Welcome"),user.displayName ? user.displayName : @""];
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         self.viewLogOut.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewLogOut.frame), CGRectGetHeight(self.viewLogOut.frame));
                         self.viewMain.frame = CGRectMake(OFFSET_OF_MAIN_TO_LOGOUT, 0, CGRectGetWidth(self.viewMain.frame), CGRectGetHeight(self.viewMain.frame));
                     }
     
	                 completion: ^(BOOL finished)
     {
         self.isLogOutViewShow = YES;
     }];
}

- (void)hiddenLogOutViewWithAnimation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         self.viewLogOut.frame = CGRectMake(-CGRectGetWidth(self.viewLogOut.frame), 0, CGRectGetWidth(self.viewLogOut.frame), CGRectGetHeight(self.viewLogOut.frame));
                         self.viewMain.frame = CGRectMake(0, 0, CGRectGetWidth(self.viewMain.frame), CGRectGetHeight(self.viewMain.frame));
                     }
     
	                 completion: ^(BOOL finished)
     {
         self.isLogOutViewShow = NO;
     }];
}

- (void)routeViewCenterWithSelected {
	if (!selectedAnnotationInfo) {
		[self.routeView centerWithAllAnnotations];
	}
	else {
		[self.routeView centerWithAnnotationInfo:selectedAnnotationInfo];
	}
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

- (void)changeBenchViewWithPosition:(PositionBenchView)aPosition animation:(BOOL)aAnimation {
    benchViewPosition = aPosition;
    
    [UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         switch (benchViewPosition) {
                             case PositionBenchView_Full:
                             {
                                 self.benchView.frame =  CGRectMake(92, 52, 830, 716);
                             }
                                 break;
                                 
                             case PositionBenchView_Half:
                             {
                                 self.benchView.frame =  CGRectMake(92, 52, 830, 716);
                             }
                                 break;
                                 
                             case PositionBenchView_Small:
                             {
                                 self.benchView.frame =  CGRectMake(92, 52, 830, 716);
                             }
                                 break;
                         }
                     } completion:NULL];
}

- (void)changeBenchActiveViewWithPosition:(PositionBenchView)aPosition animation:(BOOL)aAnimation {
    benchActiveViewPosition = aPosition;
    
    [UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         switch (benchActiveViewPosition) {
                             case PositionBenchView_Full:
                             {
                                 self.benchActiveView.frame =  CGRectMake(92, 52, 830, 716);
                             }
                                 break;
                                 
                             case PositionBenchView_Half:
                             {
                                 self.benchActiveView.frame =  CGRectMake(92, 52, 830, 716);
                             }
                                 break;
                                 
                             case PositionBenchView_Small:
                             {
                                 self.benchActiveView.frame =  CGRectMake(92, 52, 830, 716);
                             }
                                 break;
                         }
                     } completion:NULL];
}

- (MainViewLayoutType)currentMainViewLayoutType {
	if (!self.orderListVC.show) {
		return MainViewLayoutType_MapOnly;
	}
	else {
		if (detailPanelPosition == PositionDetailPanel_Bottom && checkoutPanelPosition == PositionDetailPanel_Bottom) {
			return MainViewLayoutType_LeftListShow;
		}
		else if (detailPanelPosition != PositionDetailPanel_Bottom && checkoutPanelPosition == PositionDetailPanel_Bottom) {
			switch (detailPanelPosition) {
				case PositionDetailPanel_Full:
				{
					return MainViewLayoutType_LeftListShow_DetailPanel_Full;
				}
                    break;
                    
				case PositionDetailPanel_Top:
				{
					return MainViewLayoutType_LeftListShow_DetailPanel_Top;
				}
                    break;
                    
				default:
				{
					return MainViewLayoutType_LeftListShow_DetailPanel_Half;
				}
                    break;
			}
		}
		else if (detailPanelPosition == PositionDetailPanel_Bottom && checkoutPanelPosition != PositionDetailPanel_Bottom) {
			switch (checkoutPanelPosition) {
				case PositionDetailPanel_Full:
				{
					return MainViewLayoutType_LeftListShow_CheckoutPanel_Full;
				}
                    break;
                    
				case PositionDetailPanel_Top:
				{
					return MainViewLayoutType_LeftListShow_CheckoutPanel_Top;
				}
                    break;
                    
				default:
				{
					return MainViewLayoutType_LeftListShow_CheckoutPanel_Half;
				}
                    break;
			}
		}
		if (detailPanelPosition != PositionDetailPanel_Bottom && checkoutPanelPosition != PositionDetailPanel_Bottom) {
			switch (checkoutPanelPosition) {
				case PositionDetailPanel_Full:
				{
					return MainViewLayoutType_LeftListShow_CheckoutPanel_Full;
				}
                    break;
                    
				case PositionDetailPanel_Top:
				{
					return MainViewLayoutType_LeftListShow_CheckoutPanel_Top;
				}
                    break;
                    
				default:
				{
					return MainViewLayoutType_LeftListShow_CheckoutPanel_Half;
				}
                    break;
			}
		}
	}
    
	return 99;
}

- (void)changeSignViewHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         self.signVC.view.hidden = isHidden;
                     } completion:NULL];
}

- (void)changePanelWithType:(PanelType)aType {
    
    if(self.currentShowPanel == PanelType_Case && aType != PanelType_Case)
    {
        [self.caseVC viewWillDisappear:YES];
    }
    
    if (self.currentShowPanel == PanelType_Lead && aType != PanelType_Lead) {
        [self.leadVC viewWillDisappear:YES];
    }
    
	self.currentShowPanel = aType;
    
	self.viewMainPanel.hidden = YES;
	self.viewReportPanel.hidden = YES;
	self.viewSummaryPanel.hidden = YES;
    self.viewLeadPanel.hidden = YES;
    self.viewCasePanel.hidden = YES;
    self.viewNearMePanel.hidden = YES;
    self.viewBenchPanel.hidden = YES;
    self.viewActiveBenchPanel.hidden = YES;
    
	switch (aType) {
		case PanelType_Main:
		{
			self.viewMainPanel.hidden = NO;
		}
            break;
            
		case PanelType_Report:
		{
			self.viewReportPanel.hidden = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_REPORTS object:nil];
		}
            break;
            
		case PanelType_Summary:
		{
			self.viewSummaryPanel.hidden = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_SUMMARY object:nil];
		}
            break;
            
        case PanelType_Case:
		{
			self.viewCasePanel.hidden = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_CASE object:nil];
		}
            break;
            
        case PanelType_Lead:
		{
			self.viewLeadPanel.hidden = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_LEAD object:nil];
		}
            break;
        case PanelType_NearMe:
        {
            self.viewNearMePanel.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_NEAR object:nil];
        }
            break;
        case PanelType_Bench:
        {
            self.viewBenchPanel.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_BENCH object:nil];
        }
            break;
        case PanelType_ActiveBench:
        {
            self.viewActiveBenchPanel.hidden = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_ACTIVEBENCH object:nil];
        }
            break;
	}
}

#pragma mark - Click top left button to show Login/Logout Panel
- (IBAction)clickLoginBtn:(UIButton *)sender {
	DLog(@"clickLoginBtn");
	if (isLogOutViewShow) {
		[self hiddenLogOutViewWithAnimation:YES];
        [self userInteractionEnabled:YES];
	}
	else {
		[self showLogOutViewWithAnimation:YES];
        [self userInteractionEnabled:NO];
	}
}

- (IBAction)clearCacheButtonTapped:(id)sender {
    BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
    if (!isNetworkReachable) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
        return;
    }
    [UIAlertView showWithTitle:MyLocal(@"Clear Cache") message:MyLocal(@"Are you sure you want to clear application data? If Yes, it will refresh data from server.") cancelButtonTitle:MyLocal(@"NO") otherButtonTitles:@[MyLocal(@"YES")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            return;
        } else {
            [[AMLogicCore sharedInstance] clearCache];
        }
    }];
}

- (IBAction)clickLogOutBtn:(UIButton *)sender {
    BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
    if (!isNetworkReachable) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
        return;
    }
    [UIAlertView showWithTitle:@""
                       message:MyLocal(@"Are you sure you want to log out?")
             cancelButtonTitle:MyLocal(@"NO")
             otherButtonTitles:@[MyLocal(@"YES")]
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              return;
                          }
                          else
                          {
#ifdef TEST_FOR_SVPROGRESSHUD
                              [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%s", __FUNCTION__]];
#else
                              [SVProgressHUD show];
#endif
                              
                              [[AMLogicCore sharedInstance] logOut: ^(NSInteger type, NSError *error) {
                                  if (error) {
                                      MAIN ( ^{
                                          [SVProgressHUD dismiss];
                                          
                                          [UIAlertView showWithTitle:@""
                                                             message:MyLocal(@"Logout error!")
                                                   cancelButtonTitle:MyLocal(@"OK")
                                                   otherButtonTitles:nil
                                                            tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                                if (buttonIndex == [alertView cancelButtonIndex]) {
                                                                    return;
                                                                }
                                                            }];
                                      });
                                  }
                                  else {
                                      MAIN ( ^{
                                          [SVProgressHUD dismiss];
                                          [AMUtilities logout];
                                          [self hiddenLogOutViewWithAnimation:YES];
                                      });
                                  }
                              }];
                              
                          }
                      }];
}

#pragma mark - Deal With Notification
- (void)dealWithNotiFromBenchActiveListViewController:(NSNotification *)notification {

}
- (void)dealWithNotiFromBenchListViewController:(NSNotification *)notification {
    if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_CELL_SELECTED]) {
        AMWorkOrder *workOrderInfo = [[notification object] objectForKey:KEY_OF_INFO];
        self.labelBenchPOSName.text = @"POS Name Data";
        self.labelBenchAVNotes.text = @"AV Notes Data";
        self.labelBenchTechName.text = @"Tech Name Data";
        self.labelBenchAssetNumber.text = @"Asset Number Data";
        self.labelBenchMachineType.text = @"Machine Type Data";
        self.labelBenchSerialNumber.text = @"Serial Number Data";
        self.labelBenchRepairMatrixNTE.text = @"Repair Matrix NTE Data";
    }
}


- (void)dealWithNotificationToMoveUpView {
	if (detailPanelPosition == PositionDetailPanel_Half) {
		[self changeDetailPanelViewTo:PositionDetailPanel_Top animation:YES];
	}
}

- (void)dealWithNotiFromOrderListViewController:(NSNotification *)notification {
    
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_CELL_SELECTED]) {
		AMWorkOrder *workOrderInfo = [[notification object] objectForKey:KEY_OF_INFO];
        
		selectedAnnotationInfo = [[AMInfoManage sharedInstance] covertAnnotationInfoFromLocalWorkOrderInfo:workOrderInfo withIndex:999];
        
		[self.routeView centerWithAnnotationInfo:selectedAnnotationInfo];
		[self.routeView selectAnnotationInfo:selectedAnnotationInfo];
        
        
		if ([selectedAnnotationInfo.woID isEqualToString:self.detailVC.selectedWorkOrder.woID] && detailPanelPosition == PositionDetailPanel_Bottom) {
			[self changeDetailPanelViewTo:PositionDetailPanel_Half animation:YES];
			[self changeRouteViewWithPosition:PositionRouteView_Small animation:YES];
			[self.routeView centerWithAnnotationInfo:selectedAnnotationInfo];
		}
        
		[self.detailVC refreshDataWithLocalWorkOrderInfo:[[notification object] objectForKey:KEY_OF_INFO]];
	}
	else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_WORK_ORDER_LIST_CHANGE]) {
		NSMutableArray *arrTemp = [[[notification object] objectForKey:KEY_OF_INFO] mutableCopy];
        
		NSMutableArray *annotations = [NSMutableArray array];
        
		for (NSInteger i = 0; i < [arrTemp count]; i++) {
            AnnotationInfo *info = [[AMInfoManage sharedInstance] covertAnnotationInfoFromLocalWorkOrderInfo:[arrTemp objectAtIndex:i] withIndex:(i + 1)];
            if (info) {
                [annotations addObject:info];
            }
		}

        [self requestRoutesWithList:arrTemp Optimize:[[[notification object] objectForKey:KEY_OF_FLAG] boolValue]];
        if (![[[notification object] objectForKey:KEY_OF_FLAG] boolValue]) {
            [self.routeView refreshAnnotations:annotations];
        }
        
        [self requestRoutesTimeDistanceWithList:self.orderListVC.localWorkOrders];
	}
    else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_SEARCH_BAR_CHANGE]) {
		BOOL isSearching = [[[notification object] objectForKey:KEY_OF_INFO] boolValue];
        
		if (isSearching) {
            [self addGuesture];
        }
        else
        {
            [self removeGuesture];
        }
	}
}

- (void)dealWithNotiFromLeftViewController:(NSNotification *)notification {
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_BTN_ITEM_CLICKED]) {
        
		switch ([[[notification object] objectForKey:KEY_OF_INFO] intValue]) {
			case LeftViewButtonType_Home:
			{
				if (!self.orderListVC.show) {
                    if (detailPanelPosition != PositionDetailPanel_Full) {
                        [self changeLeftListPanelHidden:NO animation:YES];
                        [self changeRouteViewWithPosition:PositionRouteView_Half animation:YES];
                        [self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                        [self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                        [self orderListLoadData];
                    }
                    else
                    {
                        [self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
                        [self changeLeftListPanelHidden:YES animation:YES];
                        if (detailPanelPosition != PositionDetailPanel_Bottom) {
                            [self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:YES];
                        }
                        if (checkoutPanelPosition != PositionDetailPanel_Bottom) {
                            [self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:YES];
                        }
                        [self.leftVC resetAllBtns];
                        [self.routeView centerWithAllAnnotations];
                        [self changePanelWithType:PanelType_Main];
                    }
				}
				else {
					[self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
					[self changeLeftListPanelHidden:YES animation:YES];
					if (detailPanelPosition != PositionDetailPanel_Bottom) {
						[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:YES];
					}
					if (checkoutPanelPosition != PositionDetailPanel_Bottom) {
						[self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:YES];
					}
					[self.leftVC resetAllBtns];
					[self.routeView centerWithAllAnnotations];
				}
				[self changePanelWithType:PanelType_Main];
                
                [self.nearMeVC changeLeftListPanelHidden:YES animation:NO];
			}
                break;
                
			case LeftViewButtonType_Reports:
			{
                if (![[self.viewReportPanel subviews] containsObject:self.reportVC.view]) {
                    [self.viewReportPanel addSubview:self.reportVC.view];
                }
				if (self.orderListVC.show) {
					[self changeLeftListPanelHidden:YES animation:NO];
				}
                
				if (detailPanelPosition != PositionDetailPanel_Bottom) {
					[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
				}
				[self changePanelWithType:PanelType_Report];
                
                [self.nearMeVC changeLeftListPanelHidden:YES animation:NO];
			}
                break;
                
			case LeftViewButtonType_Summary:
			{
                if (![[self.viewSummaryPanel subviews] containsObject:self.summaryVC.view]) {
                    [self.viewSummaryPanel addSubview:self.summaryVC.view];
                }
				if (self.orderListVC.show) {
					[self changeLeftListPanelHidden:YES animation:NO];
				}
                
				if (detailPanelPosition != PositionDetailPanel_Bottom) {
					[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
				}
				[self changePanelWithType:PanelType_Summary];
                
                [self.nearMeVC changeLeftListPanelHidden:YES animation:NO];
			}
                break;
                
            case LeftViewButtonType_NewCase:
			{
                if (![[self.viewCasePanel subviews] containsObject:self.caseVC.view]) {
                    [self.viewCasePanel addSubview:self.caseVC.view];
                }
				if (self.orderListVC.show) {
					[self changeLeftListPanelHidden:YES animation:NO];
				}
                
				if (detailPanelPosition != PositionDetailPanel_Bottom) {
					[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
				}
                
				[self changePanelWithType:PanelType_Case];
                [self.caseVC refreshNewCaseView];
                
                [self.nearMeVC changeLeftListPanelHidden:YES animation:NO];
			}
                break;
                
            case LeftViewButtonType_NewLead:
			{
                if (![[self.viewLeadPanel subviews] containsObject:self.leadVC.view]) {
                    [self.viewLeadPanel addSubview:self.leadVC.view];
                }
				if (self.orderListVC.show) {
					[self changeLeftListPanelHidden:YES animation:NO];
				}
                
				if (detailPanelPosition != PositionDetailPanel_Bottom) {
					[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
				}
                
				[self changePanelWithType:PanelType_Lead];
                [self.leadVC refreshNewLeadView];
                
                [self.nearMeVC changeLeftListPanelHidden:YES animation:NO];
			}
                break;
            case LeftViewButtonType_NearMe:
			{
                if (![[self.viewNearMePanel subviews] containsObject:self.nearMeVC.view]) {
                    [self.viewNearMePanel addSubview:self.nearMeVC.view];
                }
				if (self.orderListVC.show) {
					[self changeLeftListPanelHidden:YES animation:NO];
				}
                
				if (detailPanelPosition != PositionDetailPanel_Bottom) {
					[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
				}
                
				[self changePanelWithType:PanelType_NearMe];
                
                if (self.nearMeVC.show) {
                    [self.nearMeVC changeLeftListPanelHidden:YES animation:YES];
                     [self.leftVC resetAllBtns];
                }
                else
                {
                     [self.nearMeVC changeLeftListPanelHidden:NO animation:YES];
                }
                
                [self.nearMeVC refreshdata];
			}
                break;
                
            case LeftViewButtonType_ActiveBenchTech:
            {
                //first time in, add the benchListVC to the view
                if (![[self.viewActiveBenchPanel subviews] containsObject:self.benchActiveListVC.view]) {
                    [self.viewActiveBenchPanel addSubview: self.benchActiveListVC.view];
                }
                if (self.orderListVC.show) {
                    [self changeLeftListPanelHidden:YES animation:NO];
                }
                if (detailPanelPosition != PositionDetailPanel_Bottom) {
                    [self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                }
                
                [self changePanelWithType:PanelType_ActiveBench];

                if (self.nearMeVC.show) {
                    [self.nearMeVC changeLeftListPanelHidden:YES animation:YES];
                    [self.leftVC resetAllBtns];
                }
                else
                {
                    [self.nearMeVC changeLeftListPanelHidden:NO animation:YES];
                }
                
                if (detailPanelPosition != PositionDetailPanel_Full) {
                    [self changeLeftActiveBenchPanelHidden:NO animation:YES];
                    [self changeBenchActiveViewWithPosition:PositionBenchView_Half animation:YES];
                    //[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                    //[self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                    [self benchListLoadData];
                }
                else
                {
                    [self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
                    [self changeLeftActiveBenchPanelHidden:YES animation:YES];
                    
                    [self.leftVC resetAllBtns];
                    [self.routeView centerWithAllAnnotations];
                    [self changePanelWithType:PanelType_Main];
                }
                
            }
                break;
            case LeftViewButtonType_BenchTech:
            {

                //first time in, add the benchListVC to the view
                if (![[self.viewBenchPanel subviews] containsObject:self.benchListVC.view]) {
                    [self.viewBenchPanel addSubview: self.benchListVC.view];
                }
                if (self.orderListVC.show) {
                    [self changeLeftListPanelHidden:YES animation:NO];
                }
                if (detailPanelPosition != PositionDetailPanel_Bottom) {
                    [self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                }
                
                [self changePanelWithType:PanelType_Bench];
                
                if (self.nearMeVC.show) {
                    [self.nearMeVC changeLeftListPanelHidden:YES animation:YES];
                    [self.leftVC resetAllBtns];
                }
                else
                {
                    [self.nearMeVC changeLeftListPanelHidden:NO animation:YES];
                }

                if (detailPanelPosition != PositionDetailPanel_Full) {
                    [self changeLeftBenchPanelHidden:NO animation:YES];
                    [self changeBenchViewWithPosition:PositionBenchView_Half animation:YES];
                    //[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                    //[self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                    [self benchListLoadData];
                }
                else
                {
                    [self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
                    [self changeLeftBenchPanelHidden:YES animation:YES];
  
                    [self.leftVC resetAllBtns];
                    [self.routeView centerWithAllAnnotations];
                    [self changePanelWithType:PanelType_Main];
                }
            }
                break;
		}
	}
}

- (void)dealWithNotiFromDetailPanelViewController:(NSNotification *)notification {
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_SCREEN_FRAME]) {
		if ([[[notification object] objectForKey:KEY_OF_INFO] boolValue]) {
			[self showFullDetailScreenWithAnimation:YES];
		}
		else {
			[self hiddenFullDetailScreenWithAnimation:YES];
		}
	}
}

- (void)dealWithNotiFromCheckoutPanelViewController:(NSNotification *)notification {
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_SCREEN_FRAME]) {
		if ([[[notification object] objectForKey:KEY_OF_INFO] boolValue]) {
			[self showFullCheckoutScreenWithAnimation:YES];
		}
		else {
			[self hiddenFullCheckoutScreenWithAnimation:YES];
		}
	}
	else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_SIGNATURE]) {
		self.signVC.strFileName = [[notification object] objectForKey:KEY_OF_INFO];
		[self changeSignViewHidden:NO animation:YES];
	}
}

- (void)dealWithNotiFromMapView:(NSNotification *)notification {
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_ROUTES_REFRESH]) {
        [self requestRoutesTimeDistanceWithList:self.orderListVC.localWorkOrders];
        [self requestRoutesWithList:self.orderListVC.localWorkOrders Optimize:self.orderListVC.isSortByDistance];
	}
    else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_LIST_REFRESH]) {
        [self refreshOrderListStatus];
	}
}

- (void)dealWithNotiFromLogiccore:(NSNotification *)notification {
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_SHOW_ALERT]) {
        //TODO:: For Test Alert
        [AMUtilities showAlertWithInfo:[[notification object] objectForKey:KEY_OF_INFO]];
        return;
	}
	else if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_REFRESH_WORKORDERLIST]) {
		[self orderListLoadData];
	}
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_CASE_HISTORY_LIST object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_LEAD_HISTORY_LIST object:nil userInfo:nil];
}

#pragma mark -

- (void)startDragView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY {
	[self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
    
	if (aOffsetX < 0.0) {
		aOffsetX = 0.0;
	}
	else if (aOffsetX > CGRectGetWidth(self.viewLeftListPanel.frame)) {
		aOffsetX = CGRectGetWidth(self.viewLeftListPanel.frame);
	}
	if (aOffsetY < 0.0) {
		aOffsetY = 0.0;
	}
	else if (aOffsetY > CGRectGetHeight(self.viewDetailPanel.frame) - CGRectGetHeight(self.viewTitle.frame)) {
		aOffsetY = CGRectGetHeight(self.viewDetailPanel.frame) - CGRectGetHeight(self.viewTitle.frame);
	}
    
	self.viewDetailPanel.frame = CGRectMake(aOffsetX, aOffsetY, 930.0 - aOffsetX, CGRectGetHeight(self.viewDetailPanel.frame));
	self.viewLeftListPanel.frame = CGRectMake(aOffsetX - CGRectGetWidth(self.viewLeftListPanel.frame), CGRectGetMinY(self.viewLeftListPanel.frame), CGRectGetWidth(self.viewLeftListPanel.frame), CGRectGetHeight(self.viewLeftListPanel.frame));
	self.detailVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.viewDetailPanel.frame), CGRectGetHeight(self.viewDetailPanel.frame));
}

- (void)endDragView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY {
    
	CGFloat MIDDLE_LEFT_X = CGRectGetWidth(self.viewLeftListPanel.frame) / 2.0;
	CGFloat MIDDLE_UP_HALF_Y = ORIGINAL_Y_OF_DETAIL_HALF / 2.0;
    
	CGRect rectLeft_Up_To_Full = CGRectMake(0,
	                                        0,
	                                        MIDDLE_LEFT_X,
	                                        ORIGINAL_Y_OF_DETAIL_HALF);
    
	CGRect rectLeft_Down_To_Hidden = CGRectMake(0,
	                                            ORIGINAL_Y_OF_DETAIL_HALF,
	                                            MIDDLE_LEFT_X,
	                                            CGRectGetHeight(self.viewMainPanel.frame) - ORIGINAL_Y_OF_DETAIL_HALF);
    
	CGRect rectRight_Up_To_Top = CGRectMake(MIDDLE_LEFT_X,
	                                        0,
	                                        CGRectGetWidth(self.viewMainPanel.frame) - MIDDLE_LEFT_X,
	                                        MIDDLE_UP_HALF_Y);
    
	CGRect rectMiddle_To_Normal = CGRectMake(MIDDLE_LEFT_X,
	                                         MIDDLE_UP_HALF_Y,
	                                         CGRectGetWidth(self.viewMainPanel.frame) - MIDDLE_LEFT_X,
	                                         CGRectGetHeight(self.viewMainPanel.frame) - MIDDLE_UP_HALF_Y - CGRectGetHeight(FRAME_OF_DETAILPANEL_NORMAL_HALF) / 2.0);
    
	if (CGRectContainsPoint(rectLeft_Up_To_Full, self.viewDetailPanel.frame.origin)) {
		[self changeDetailPanelViewTo:PositionDetailPanel_Full animation:YES];
		[self changeLeftListPanelHidden:YES animation:YES];
	}
	else if (CGRectContainsPoint(rectLeft_Down_To_Hidden, self.viewDetailPanel.frame.origin)) {
		[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:YES];
		[self changeLeftListPanelHidden:YES animation:YES];
		[self.leftVC resetAllBtns];
	}
	else if (CGRectContainsPoint(rectRight_Up_To_Top, self.viewDetailPanel.frame.origin)) {
		[self changeDetailPanelViewTo:PositionDetailPanel_Top animation:YES];
		[self changeLeftListPanelHidden:NO animation:YES];
	}
	else if (CGRectContainsPoint(rectMiddle_To_Normal, self.viewDetailPanel.frame.origin)) {
		[self changeDetailPanelViewTo:PositionDetailPanel_Half animation:YES];
		[self changeLeftListPanelHidden:NO animation:YES];
		[self changeRouteViewWithPosition:PositionRouteView_Small animation:YES];
	}
	else {
		[self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:YES];
		[self changeLeftListPanelHidden:NO animation:YES];
		[self changeRouteViewWithPosition:PositionRouteView_Half animation:YES];
	}
    
	if ([self currentMainViewLayoutType] == MainViewLayoutType_LeftListShow || [self currentMainViewLayoutType] == MainViewLayoutType_MapOnly) {
		[self.routeView centerWithAllAnnotations];
	}
}

#pragma mark -

- (void)startDragCheckoutPanelView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY {
	[self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
    
	if (aOffsetX < 0.0) {
		aOffsetX = 0.0;
	}
	else if (aOffsetX > CGRectGetWidth(self.viewLeftListPanel.frame)) {
		aOffsetX = CGRectGetWidth(self.viewLeftListPanel.frame);
	}
	if (aOffsetY < 0.0) {
		aOffsetY = 0.0;
	}
	else if (aOffsetY > CGRectGetHeight(self.viewDetailPanel.frame) - CGRectGetHeight(self.viewTitle.frame)) {
		aOffsetY = CGRectGetHeight(self.viewDetailPanel.frame) - CGRectGetHeight(self.viewTitle.frame);
	}
    
	self.viewCheckoutPanel.frame = CGRectMake(aOffsetX, aOffsetY, 930.0 - aOffsetX, CGRectGetHeight(self.viewCheckoutPanel.frame));
	self.viewLeftListPanel.frame = CGRectMake(aOffsetX - CGRectGetWidth(self.viewLeftListPanel.frame), CGRectGetMinY(self.viewLeftListPanel.frame), CGRectGetWidth(self.viewLeftListPanel.frame), CGRectGetHeight(self.viewLeftListPanel.frame));
	self.checkoutVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.viewCheckoutPanel.frame), CGRectGetHeight(self.viewCheckoutPanel.frame));
}

- (void)endDragCheckoutPanelView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY {
	CGFloat MIDDLE_LEFT_X = CGRectGetWidth(self.viewLeftListPanel.frame) / 2.0;
	CGFloat MIDDLE_UP_HALF_Y = ORIGINAL_Y_OF_DETAIL_HALF / 2.0;
    
	CGRect rectLeft_Up_To_Full = CGRectMake(0,
	                                        0,
	                                        MIDDLE_LEFT_X,
	                                        ORIGINAL_Y_OF_DETAIL_HALF);
    
	CGRect rectLeft_Down_To_Hidden = CGRectMake(0,
	                                            ORIGINAL_Y_OF_DETAIL_HALF,
	                                            MIDDLE_LEFT_X,
	                                            CGRectGetHeight(self.viewMainPanel.frame) - ORIGINAL_Y_OF_DETAIL_HALF);
    
	CGRect rectRight_Up_To_Top = CGRectMake(MIDDLE_LEFT_X,
	                                        0,
	                                        CGRectGetWidth(self.viewMainPanel.frame) - MIDDLE_LEFT_X,
	                                        MIDDLE_UP_HALF_Y);
    
	CGRect rectMiddle_To_Normal = CGRectMake(MIDDLE_LEFT_X,
	                                         MIDDLE_UP_HALF_Y,
	                                         CGRectGetWidth(self.viewMainPanel.frame) - MIDDLE_LEFT_X,
	                                         CGRectGetHeight(self.viewMainPanel.frame) - MIDDLE_UP_HALF_Y - CGRectGetHeight(FRAME_OF_DETAILPANEL_NORMAL_HALF) / 2.0);
    
	if (CGRectContainsPoint(rectLeft_Up_To_Full, self.viewCheckoutPanel.frame.origin)) {
		[self changeCheckoutPanelViewTo:PositionDetailPanel_Full animation:YES];
		[self changeLeftListPanelHidden:YES animation:YES];
	}
	else if (CGRectContainsPoint(rectLeft_Down_To_Hidden, self.viewCheckoutPanel.frame.origin)) {
		[self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:YES];
		[self changeLeftListPanelHidden:YES animation:YES];
		[self.leftVC resetAllBtns];
	}
	else if (CGRectContainsPoint(rectRight_Up_To_Top, self.viewCheckoutPanel.frame.origin)) {
		[self changeCheckoutPanelViewTo:PositionDetailPanel_Top animation:YES];
		[self changeLeftListPanelHidden:NO animation:YES];
	}
	else if (CGRectContainsPoint(rectMiddle_To_Normal, self.viewCheckoutPanel.frame.origin)) {
		[self changeCheckoutPanelViewTo:PositionDetailPanel_Half animation:YES];
		[self changeLeftListPanelHidden:NO animation:YES];
		[self changeRouteViewWithPosition:PositionRouteView_Small animation:YES];
	}
	else {
		[self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:YES];
		[self changeLeftListPanelHidden:NO animation:YES];
		[self changeRouteViewWithPosition:PositionRouteView_Half animation:YES];
	}
    
	if ([self currentMainViewLayoutType] == MainViewLayoutType_LeftListShow || [self currentMainViewLayoutType] == MainViewLayoutType_MapOnly) {
		[self.routeView centerWithAllAnnotations];
	}
}

- (void)finishedAllCheckoutProcess {
    [self enterCheckOutModel:NO];
	[self changeCheckoutPanelViewTo:PositionDetailPanel_Bottom animation:YES];
    [self orderListLoadData];
}

#pragma mark -

- (void)routeMapView:(RouteMapView *)aRouteView didTappedCancelAnnotationView:(PointAnnotationView *)aPointAnnotationView
{
    AMWorkOrder *workOrder = [[AMLogicCore sharedInstance] getWorkOrderInfoByID:aPointAnnotationView.mapAnnotation.woID];
    [self.detailVC refreshDataWithLocalWorkOrderInfo:workOrder];
}

- (void)routeMapView:(RouteMapView *)aRouteView didTappedPointAnnotationView:(PointAnnotationView *)aPointAnnotationView {
	AMWorkOrder *workOrder = [[AMLogicCore sharedInstance] getWorkOrderInfoByID:aPointAnnotationView.mapAnnotation.woID];
    
    [self.orderListVC refreshSelectStatusWithWorkOrderId:aPointAnnotationView.mapAnnotation.woID];
    
    switch (aPointAnnotationView.mapAnnotation.viewType) {
        case AnnotationViewType_Finished:
        {
            [self enterCheckOutModel:YES];
            [self changeCheckoutPanelViewTo:PositionDetailPanel_Full animation:YES];
            [self.checkoutVC refreshDataWithLocalWorkOrderInfo:workOrder];
            
            if (self.detailPanelPosition != PositionDetailPanel_Bottom) {
                [self changeDetailPanelViewTo:PositionDetailPanel_Bottom animation:NO];
                
                if (self.orderListVC.show) {
                    [self changeRouteViewWithPosition:PositionRouteView_Half animation:NO];
                }
                else
                {
                    [self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
                }
            }
            
            [self.detailVC refreshDataWithLocalWorkOrderInfo:workOrder];
        }
            break;
        case AnnotationViewType_CheckOut:
        {
            if (!self.orderListVC.show) {
                [self.leftVC selectItemWithType:LeftViewButtonType_Home];
                [self changeLeftListPanelHidden:NO animation:NO];
                [self changeRouteViewWithPosition:PositionRouteView_Half animation:YES];
            }
            
            if (detailPanelPosition == PositionDetailPanel_Bottom) {
                [self changeDetailPanelViewTo:PositionDetailPanel_Half animation:YES];
                [self changeRouteViewWithPosition:PositionRouteView_Small animation:YES];
            }
            
            [self.detailVC refreshDataWithLocalWorkOrderInfo:workOrder];
        }
            break;
            
//        case AnnotationViewType_CheckIn:
//        {
//            if (!self.orderListVC.show) {
//                [self.leftVC selectItemWithType:LeftViewButtonType_Home];
//                [self changeLeftListPanelHidden:NO animation:NO];
//                [self changeRouteViewWithPosition:PositionRouteView_Half animation:YES];
//            }
//            
//            if (detailPanelPosition == PositionDetailPanel_Bottom) {
//                [self changeDetailPanelViewTo:PositionDetailPanel_Half animation:YES];
//                [self changeRouteViewWithPosition:PositionRouteView_Small animation:YES];
//            }
//            
//            [self.detailVC refreshDataWithLocalWorkOrderInfo:workOrder];
//            
//        }
//            break;
        default:
            break;
    }
    
	[self.routeView centerWithAnnotationInfo:aPointAnnotationView.mapAnnotation];
}

#pragma mark -

- (void)AMSignViewController:(AMSignViewController *)aAMSignViewController confirmWith:(UIImage *)aSignImage {
	NSData *data = UIImageJPEGRepresentation(aSignImage, 1);
	[AMFileManage saveData:data withName:aAMSignViewController.strFileName];
	[self changeSignViewHidden:YES animation:YES];
	[self.checkoutVC refreshToInitialization];
}

- (void)AMSignViewController:(AMSignViewController *)aAMSignViewController resetWith:(UIImage *)aSignImage {
    [AMFileManage removeDataWithName:aAMSignViewController.strFileName];
}

- (void)AMSignViewController:(AMSignViewController *)aAMSignViewController cancelWith:(UIImage *)aSignImage {
	[self changeSignViewHidden:YES animation:YES];
}

#pragma mark -

- (void)userInteractionEnabled:(BOOL)enable
{
    self.viewMainPanel.userInteractionEnabled = enable;
    self.viewNearMePanel.userInteractionEnabled = enable;
    self.viewBenchPanel.userInteractionEnabled = enable;
    self.viewActiveBenchPanel.userInteractionEnabled = enable;
    self.viewReportPanel.userInteractionEnabled = enable;
    self.viewSummaryPanel.userInteractionEnabled = enable;
    self.viewLeadPanel.userInteractionEnabled = enable;
    self.viewCasePanel.userInteractionEnabled = enable;
    [self.leftVC userInteractionEnabled:enable];
}

- (void)enterCheckOutModel:(BOOL)isCheckOut
{
    [self.leftVC userInteractionEnabled:!isCheckOut];
    self.btnLogin.enabled = !isCheckOut;
//    willSwitchLanguage = !isCheckOut; //Ignore Application language switched if enter checkout process, should finish checkout first.
}

#pragma mark -

- (void)requestRoutesTimeDistanceWithList:(NSMutableArray *)aList
{
    NSMutableArray *arrTemp = [aList mutableCopy];
    NSMutableArray *arrInfos = [NSMutableArray array];
    for (NSInteger i = 1; i < [arrTemp count]; i++) {
        AMWorkOrder *workorderFrom = [arrTemp objectAtIndex:(i-1)];
        AMWorkOrder *workorderTo = [arrTemp objectAtIndex:i];
        GoogleRouteInfo *routeInfo = [[GoogleRouteInfo alloc] init];
        routeInfo.gId = workorderTo.woID;
        routeInfo.gFrom = [[CLLocation alloc] initWithLatitude:[workorderFrom.latitude floatValue] longitude:[workorderFrom.longitude floatValue]];
        routeInfo.gTo = [[CLLocation alloc] initWithLatitude:[workorderTo.latitude floatValue] longitude:[workorderTo.longitude floatValue]];
        routeInfo.gMode = @"driving";
        [arrInfos addObject:routeInfo];
    }
    
    if ([arrInfos count] == 0) {
        return;
    }
    
    AMWorkOrder *workorderFirst = [aList firstObject];
    
    GoogleRouteInfo *routeInfoFirst = [[GoogleRouteInfo alloc] init];
    routeInfoFirst.gId = workorderFirst.woID;
    routeInfoFirst.gFrom = self.routeView.currentLocation;
    routeInfoFirst.gTo = [[CLLocation alloc] initWithLatitude:[workorderFirst.latitude floatValue] longitude:[workorderFirst.longitude floatValue]];
    routeInfoFirst.gMode = @"driving";
    
    [arrInfos insertObject:routeInfoFirst atIndex:0];
    
    [[GoogleRouteManage sharedInstance] fetchRoutes:arrInfos completion:^(NSInteger type, id result, NSError *error) {
        MAIN(^{
            [self.orderListVC refreshTimeAndDistanceBySingleRequest:result];
        });
    }];
}

- (void)requestRoutesWithList:(NSMutableArray *)aList Optimize:(BOOL)isOptimize
{
    if ([aList count] == 0) {
        return;
    }
    
     NSMutableArray *arrTemp = [aList mutableCopy];
    
    BACK(^{
        
        [requestQueue cancelAllOperations];

        NSNumber *number = [NSNumber numberWithBool:isOptimize];
        
        NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
        [dicInfo setObject:arrTemp forKey:@"LIST"];
        [dicInfo setObject:number forKey:@"OPTIMIZE"];
        
            NSInvocationOperation *theOp = [[NSInvocationOperation alloc]
                                            initWithTarget:self
                                            selector:@selector(myRequestTaskMethod:)
                                            object:dicInfo];
            
        [requestQueue addOperation:theOp];
    });
}

#pragma mark -

- (void)myRequestTaskMethod:(id)Info {
    
    NSMutableArray *aList = [[Info objectForKey:@"LIST"] mutableCopy];
    BOOL isOptimize = [[Info objectForKey:@"OPTIMIZE"] boolValue];
    
    NSMutableArray *arrInfos = [NSMutableArray array];
    for (NSInteger i = 0; i < [aList count]; i++) {
        AMWorkOrder *workorder = [aList objectAtIndex:i];
        
        GooglePointInfo *pointInfo = [[GooglePointInfo alloc] init];
        pointInfo.gType = PointType_Noraml;
        pointInfo.gId = workorder.woID;
        pointInfo.gMode = @"driving";
        pointInfo.gLocation = [[CLLocation alloc] initWithLatitude:[workorder.latitude floatValue] longitude:[workorder.longitude floatValue]];
        
        [arrInfos addObject:pointInfo];
    }
    
    GooglePointInfo *pointInfo = [[GooglePointInfo alloc] init];
    pointInfo.gType = PointType_Start;
    pointInfo.gId = @"";
    pointInfo.gMode = @"driving";
    pointInfo.gLocation = self.routeView.currentLocation;
    
    [arrInfos insertObject:pointInfo atIndex:0];
    
    if ([arrInfos count] == 1) {
        [self.routeView hiddenTip];
        return;
    }
    
    [[GoogleRouteManage sharedInstance] fetchPoints:arrInfos optimize:isOptimize completion:^(NSInteger type, id result, NSError *error) {
        if (result) {
            
            NSMutableArray *arrPolyLine = [NSMutableArray array];
            NSMutableArray *arrSort = [NSMutableArray array];
            
            for (GooglePointInfo *point in result) {
                
                if ([point.gPolyLine count] != 0) {
                    [arrPolyLine addObjectsFromArray:point.gPolyLine];
                }
                
                [arrSort addObject:point.gId];
            }
            
            MAIN(^{
                
                if (isOptimize) {
                    
                    NSMutableArray *arrTemp = [[self.orderListVC sortWithMoveList:arrSort] mutableCopy];
                    
                    NSMutableArray *annotations = [NSMutableArray array];
                    
                    for (NSInteger i = 0; i < [arrTemp count]; i++) {
                        [annotations addObject:[[AMInfoManage sharedInstance] covertAnnotationInfoFromLocalWorkOrderInfo:[arrTemp objectAtIndex:i] withIndex:(i + 1)]];
                    }
                    
                    [self.orderListVC refreshOrderList:arrTemp];
                    [self requestRoutesTimeDistanceWithList:arrTemp];
                    [self.routeView refreshAnnotations:annotations];
                }
                
                [self.orderListVC refreshTimeAndDistanceByRouteRequest:result];
                
                if ([arrPolyLine count] == 0) {
                    [self.routeView showTip:MyLocal(@"Failed to get Google map route")];
                }
                else
                {
                    [self.routeView drawRoutesOnMap:arrPolyLine];
                    [self.routeView hiddenTip];
                }
            });
        }
        else
        {
            MAIN(^{
                [self.routeView showTip:MyLocal(@"Net Error, Failed to get Google map route")];
            });

        }
    }];
}

- (void)userDefaultValueChanged:(NSNotification*)aNotification
{
    NSString *settingLanguage = [USER_DEFAULT objectForKey:kAMAPPLICATION_LANGUAGE_KEY];
    NSNumber *langNumber = [NSNumber numberWithInt:[settingLanguage intValue]];
    NSNumber *currentLang = [USER_DEFAULT objectForKey:kAMAPPLICATION_CURRENT_LANGUAGE_KEY];
    if (willSwitchLanguage && currentLang && ![langNumber isEqualToNumber:currentLang]) {
        willSwitchLanguage = NO;
        [UIAlertView showWithTitle:MyLocal(@"Language Changed") message:MyLocal(@"Would you like to re-login to change application language?") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"NO") otherButtonTitles:@[MyLocal(@"YES")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != [alertView cancelButtonIndex]) {
                BOOL isNetworkReachable = [[AMLogicCore sharedInstance] isNetWorkReachable];
                if (!isNetworkReachable) {
                    [AMUtilities showAlertWithInfo:MyLocal(@"Please check network connection.")];
                    return;
                }
                [SVProgressHUD show];
                [LanguageConfig setLanguage:[langNumber intValue]];
                willSwitchLanguage = YES;
                [[AMLogicCore sharedInstance] logOut: ^(NSInteger type, NSError *error) {
                    if (error) {
                        MAIN ( ^{
                            [SVProgressHUD dismiss];
                            
                            [UIAlertView showWithTitle:@""
                                               message:MyLocal(@"Logout error!")
                                     cancelButtonTitle:MyLocal(@"OK")
                                     otherButtonTitles:nil
                                              tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                                      return;
                                                  }
                                              }];
                        });
                    }
                    else {
                        MAIN ( ^{
                            [SVProgressHUD dismiss];
                            [AMUtilities logout];
                            [self hiddenLogOutViewWithAnimation:YES];
                        });
                    }
                }];
            } else {
                willSwitchLanguage = NO;
            }
        }];
    } else if (currentLang && [langNumber isEqualToNumber:currentLang]){
        willSwitchLanguage = YES; //
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//   
//}
#pragma mark BenchTechViewRelated
- (IBAction)tapStartBenchButtn:(UIButton *)sender {
    [UIAlertView showWithTitle:MyLocal(@"Start Bench") message:MyLocal(@"Start Bench Tapped.") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"OK") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        return ;
    }];
}

- (IBAction)tapScrapBenchButtn:(UIButton *)sender {
    [UIAlertView showWithTitle:MyLocal(@"Scrap Bench") message:MyLocal(@"Scrap Bench Tapped.") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"OK") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        return ;
    }];
}

- (IBAction)tapActiveBenchButtn:(UIButton *)sender {
//    [UIAlertView showWithTitle:MyLocal(@"Active Bench") message:MyLocal(@"Active Bench Tapped.") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"OK") otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        return ;
//    }];
    
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                              KEY_OF_INFO:[NSNumber numberWithInteger:8]
                              };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
}


@end
