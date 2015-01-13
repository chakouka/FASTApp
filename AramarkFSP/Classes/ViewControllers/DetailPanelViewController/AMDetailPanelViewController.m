//
//  AMDetailPanelViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMDetailPanelViewController.h"
#import "AMWorkOrder.h"
#import "AMLogicCore.h"
#import "AMLocation.h"
#import "AMContact.h"

#define WIDTH_OF_BUTTON_NORMAL      78
#define WIDTH_OF_BUTTON_FULL        105

@interface AMDetailPanelViewController ()
{
	CGPoint originalPoint;
	CGFloat xCoor;
	CGFloat yCoor;
	BOOL isMoved;
    CGRect originViewRect;
}

@property (assign, nonatomic) BOOL isFullScreen;
@property (strong, nonatomic) NSMutableArray *arrTitleItems;

@end

@implementation AMDetailPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		_selectedWorkOrder = nil;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self viewInitialization];
    _isFullScreen = NO;
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
    [self.view addGestureRecognizer:panGesture];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToHideKeyboard)]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.accountVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.accountVC.view.frame));
    self.posVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.posVC.view.frame));
    self.locationsVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.locationsVC.view.frame));
    self.contactsVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.viewMain.frame));
    self.assetsVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.assetsVC.view.frame));
    self.casesVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.casesVC.view.frame));
    float topViewWidth = CGRectGetWidth(self.topTapParentView.frame);
//    if (topViewWidth <= 560 * 1.2) {
//        CGRect topTabViewRect = _topTabVC.view.frame;
//        topTabViewRect.size.width = topViewWidth;
//        _topTabVC.view.frame = topTabViewRect;
//    }
    CGRect newRect = _topTabVC.view.frame;
    if (_isFullScreen) {
        newRect.size.width = 560.0 * 1.2;
        if (newRect.size.width > topViewWidth) {
            newRect.size.width = topViewWidth;
        }
        _topTabVC.view.frame = newRect;
    } else {
        newRect.size.width = 560.0;
        _topTabVC.view.frame = newRect;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    originViewRect = self.view.superview.frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.view.superview.frame = originViewRect;
}

- (void)panDetected:(UIPanGestureRecognizer *)gesture
{
//    CGPoint velocity = [gesture velocityInView:self.view];
    static CGPoint originalCenter;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = [gesture locationInView:self.view.superview];
        xCoor = self.view.superview.frame.origin.x;
		yCoor = self.view.superview.frame.origin.y;
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint currentPoint = [gesture locationInView:self.view.superview];
		xCoor = xCoor + currentPoint.x - originalCenter.x;
		yCoor =  yCoor + currentPoint.y - originalCenter.y;
        if (self.delegate && [self.delegate respondsToSelector:@selector(startDragView:xOffset:yOffset:)]) {
			[self.delegate startDragView:self.view xOffset:xCoor yOffset:yCoor];
		}
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed ||
             gesture.state == UIGestureRecognizerStateCancelled)
    {
        float xTemp = self.view.superview.frame.origin.x;
        float yTemp = self.view.superview.frame.origin.y;
        if (self.delegate && [self.delegate respondsToSelector:@selector(endDragView:xOffset:yOffset:)]) {
			[self.delegate endDragView:self.view xOffset:xTemp yOffset:yTemp];
		}
    }
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)tapToHideKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark -
- (void)viewInitialization {
    if (!_topTabVC) {
        _topTabVC = [[AMDetailTabViewController alloc] initWithNibName:@"AMDetailTabViewController" bundle:nil];
        _topTabVC.delegate = self;
        _topTabVC.selectedIndex = AMTabTypeWorkOrder;
        [self.topView addSubview:_topTabVC.view];
    }
    
}

#pragma mark -

- (void)assignNewWorkOrder:(AMWorkOrder *)workOrder
{
    AMWorkOrder *newWO = [[AMLogicCore sharedInstance] getFullWorkOrderInfoByID:workOrder.woID];
    self.selectedWorkOrder = newWO;
    [_topTabVC populateCountNumber:newWO];
    if (self.topTabVC.selectedIndex) {
        [self didSelectTabAtTabType:self.topTabVC.selectedIndex];
    } else {
        [self didSelectTabAtTabType:AMTabTypeWorkOrder];
        self.topTabVC.selectedIndex = AMTabTypeWorkOrder;
    }
}

- (void)refreshDataWithLocalWorkOrderInfo:(AMWorkOrder *)aWorkOrder {
    [self assignNewWorkOrder:aWorkOrder];
}

#pragma mark -
- (IBAction)fullScreenButtonTapped:(id)sender {
    [self showFullScreen:!_isFullScreen];
}

#pragma mark - Layout Change

- (void)changeFrameTo:(FrameType)aType animation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
	    switch (aType) {
			case FrameType_Top:
			case FrameType_Normal:
				{
				    self.view.frame = CGRectMake(0, 0, 630, 716);
                    self.topTabVC.view.frame = CGRectMake(0.0, 0.0, 560.0, 80.0);
				    _isFullScreen = NO;
				}
				break;

			case FrameType_Full:
				{
				    self.view.frame = CGRectMake(0, 0, 930, 716);
                    self.topTabVC.view.frame = CGRectMake(0.0, 0.0, 560.0*1.2, 80.0);
				    _isFullScreen = YES;
				}
				break;

			default:
				break;
		}
	} completion: ^(BOOL finished) {
        
	}];
    [self.fullScreenButton setSelected:_isFullScreen];
}

- (void)showFullScreen:(BOOL)boolValue
{
    _isFullScreen = boolValue;
    
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_SCREEN_FRAME,
                              KEY_OF_INFO:[NSNumber numberWithBool:boolValue]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMDETAILPANELVIEWCONTROLLER object:dicInfo];
}

#pragma AMDetailTabViewControllerDelegate
- (void)didSelectTabAtTabType:(AMTabType)tabType
{
    switch (tabType) {
        case AMTabTypeWorkOrder:
        {
            if (!_workOrderVC) {
                _workOrderVC = [[AMWorkOrderViewController alloc] initWithNibName:@"AMWorkOrderViewController" bundle:nil];
                [self.viewMain addSubview:_workOrderVC.view];
            }
            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_workOrderVC.view.frame)) {
                [self.viewMain setScrollEnabled:YES];
            } else {
                [self.viewMain setScrollEnabled:NO];
            }
            [self.viewMain setContentSize:_workOrderVC.view.frame.size];
            _workOrderVC.assignedWorkOrder = self.selectedWorkOrder;
            [self.viewMain bringSubviewToFront:_workOrderVC.view];
        }
            break;
            
        case AMTabTypeAccount:
        {
            if (!_accountVC) {
                _accountVC = [[AMAccountViewController alloc] initWithNibName:NSStringFromClass([AMAccountViewController class]) bundle:nil];
                [self.viewMain addSubview:_accountVC.view];
            }
            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_accountVC.view.frame)) {
                [self.viewMain setScrollEnabled:YES];
            } else {
                [self.viewMain setScrollEnabled:NO];
            }
            [self.viewMain setContentSize:_accountVC.view.frame.size];
            _accountVC.assignedAccount = self.selectedWorkOrder.woAccount;
            _accountVC.relatedWOPoS = self.selectedWorkOrder.woPoS;
            [self.viewMain bringSubviewToFront:_accountVC.view];
            
        }
            break;
            
        case AMTabTypePOS:
        {
            if (!_posVC) {
                _posVC = [[AMPOSViewController alloc] initWithNibName:NSStringFromClass([AMPOSViewController class]) bundle:nil];
                [self.viewMain addSubview:_posVC.view];
                
            }
            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_posVC.view.frame)) {
                [self.viewMain setScrollEnabled:YES];
            } else {
                [self.viewMain setScrollEnabled:NO];
            }
            [self.viewMain setContentSize:_posVC.view.frame.size];
            _posVC.assignedPOS = self.selectedWorkOrder.woPoS;
            _posVC.relatedWO = self.selectedWorkOrder;
            [self.viewMain bringSubviewToFront:_posVC.view];
            [_posVC viewWillLayoutSubviews];
        }
            break;
            
        case AMTabTypeLocation:
        {
            if (!_locationsVC) {
                _locationsVC = [[AMLocationViewController alloc] initWithNibName:NSStringFromClass([AMLocationViewController class]) bundle:nil];
                [self.viewMain addSubview:_locationsVC.view];
                
            }
            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_locationsVC.view.frame)) {
                [self.viewMain setScrollEnabled:YES];
            } else {
                [self.viewMain setScrollEnabled:NO];
            }
            [self.viewMain setContentSize:_locationsVC.view.frame.size];
            _locationsVC.locationArr = self.selectedWorkOrder.woAccount.locationList;
            _locationsVC.accountId = self.selectedWorkOrder.woAccount.accountID;
            _locationsVC.relatedWO = self.selectedWorkOrder;
            [self.viewMain bringSubviewToFront:_locationsVC.view];
            [_locationsVC viewWillLayoutSubviews];
            
        }
            break;
            
        case AMTabTypeContacts:
        {
            if (!_contactsVC) {
                _contactsVC = [[AMContactTableViewController alloc] initWithContactArray:self.selectedWorkOrder.woPoS.contactList];
                [self.viewMain addSubview:_contactsVC.view];
                
            }
//            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_contactsVC.view.frame)) {
//                [self.viewMain setScrollEnabled:YES];
//            } else {
//                [self.viewMain setScrollEnabled:NO];
//            }
            [self.viewMain setScrollEnabled:NO];
            [self.viewMain setContentSize:_contactsVC.view.frame.size];
            _contactsVC.contactArr = self.selectedWorkOrder.woPoS.contactList;
            [self.viewMain bringSubviewToFront:_contactsVC.view];
        }
            break;
            
        case AMTabTypeAssets:
            if (!_assetsVC) {
                _assetsVC = [[AMAssetsViewController alloc] initWithAsset:self.selectedWorkOrder.woAsset];
                [self.viewMain addSubview:_assetsVC.view];
                
            }
            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_assetsVC.view.frame)) {
                [self.viewMain setScrollEnabled:YES];
            } else {
                [self.viewMain setScrollEnabled:NO];
            }
            [self.viewMain setContentSize:_assetsVC.view.frame.size];
            _assetsVC.assignedAsset = self.selectedWorkOrder.woAsset;
            _assetsVC.accountId = self.selectedWorkOrder.woAccount.accountID;
            [self.viewMain bringSubviewToFront:_assetsVC.view];
            break;
            
        case AMTabTypeCases:
            if (!_casesVC) {
                _casesVC = [[AMCasesViewController alloc] initWithNibName:NSStringFromClass([AMCasesViewController class]) bundle:nil];
                [self.viewMain addSubview:_casesVC.view];
                
            }
            if (CGRectGetHeight(self.viewMain.frame) < CGRectGetHeight(_casesVC.view.frame)) {
                [self.viewMain setScrollEnabled:YES];
            } else {
                [self.viewMain setScrollEnabled:NO];
            }
            [self.viewMain setContentSize:_casesVC.view.frame.size];
            _casesVC.assignedCase = self.selectedWorkOrder.woCase;
            [self.viewMain bringSubviewToFront:_casesVC.view];
            break;
            
        default:
            break;
    }
}

@end
