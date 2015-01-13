//
//  AMCheckoutPanelViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//
/***************************************************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM000121: Check Out on Install WO Adding Asset and Warning. By Hari Kolasani. 12/9/2014
 ***************************************************************************************************************/

#import <UIKit/UIKit.h>

#import "AMCheckoutTabViewController.h"

@class AMCheckoutTabViewController;
@class AMCheckoutViewController;
@class AMInvoiceViewController;
@class AMPointsViewController;
@class AMVerificationViewController;
@class AMWorkOrder;

//typedef NS_ENUM(NSInteger, FrameType) {
//    FrameType_Normal = 0,
//    FrameType_Top,
//    FrameType_Full,
//};

@protocol AMCheckoutPanelViewControllerDelegate;

@interface AMCheckoutPanelViewController : UIViewController <AMCheckoutTabViewControllerDelegate>

@property (strong, nonatomic) AMWorkOrder *selectedWorkOrder;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (strong, nonatomic) AMCheckoutTabViewController *topTabVC;
@property (strong, nonatomic) AMCheckoutViewController *checkoutVC;
@property (strong, nonatomic) AMInvoiceViewController *invoiceVC;
@property (strong, nonatomic) AMPointsViewController *pointsVC;
@property (strong, nonatomic) AMVerificationViewController *verificationVC;
//@property (assign, nonatomic) AMCheckoutTabType checkOutSetp;

@property (weak, nonatomic) id <AMCheckoutPanelViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;

- (void)refreshToInitialization;
- (void)refreshDataWithLocalWorkOrderInfo:(AMWorkOrder *)aWorkOrder;
- (void)changeFrameTo:(FrameType)aType animation:(BOOL)aAnimation;
@end


@protocol AMCheckoutPanelViewControllerDelegate <NSObject>

- (void)startDragCheckoutPanelView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY;
- (void)endDragCheckoutPanelView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY;
- (void)finishedAllCheckoutProcess;

@end
