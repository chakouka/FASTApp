//
//  AMDetailPanelViewController.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMDetailTabViewController.h"
#import "AMWorkOrderViewController.h"
#import "AMPOSViewController.h"
#import "AMAccountViewController.h"
#import "AMLocationViewController.h"
#import "AMAssetsViewController.h"
#import "AMContactTableViewController.h"
#import "AMCasesViewController.h"

@class AMWorkOrder;

@protocol AMDetailPanelViewDelegate;

@interface AMDetailPanelViewController : UIViewController<AMDetailTabViewControllerDelegate>

@property (strong, nonatomic) AMWorkOrder *selectedWorkOrder;
@property (weak, nonatomic) IBOutlet UILabel *label_Title;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *topTapParentView;
@property (weak, nonatomic) IBOutlet UILabel *label_Tip;
@property (weak, nonatomic) IBOutlet UIScrollView *viewMain;
@property (strong, nonatomic) AMDetailTabViewController *topTabVC;
@property (strong, nonatomic) AMWorkOrderViewController *workOrderVC;
@property (strong, nonatomic) AMAccountViewController *accountVC;
@property (strong, nonatomic) AMPOSViewController *posVC;
@property (strong, nonatomic) AMLocationViewController *locationsVC;
@property (strong, nonatomic) AMContactTableViewController *contactsVC;
@property (strong, nonatomic) AMAssetsViewController *assetsVC;
@property (strong, nonatomic) AMCasesViewController *casesVC;

@property (weak, nonatomic) id <AMDetailPanelViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;

- (void)assignNewWorkOrder:(AMWorkOrder *)workOrder;
-(void)refreshDataWithLocalWorkOrderInfo:(AMWorkOrder *)aWorkOrder;

-(void)changeFrameTo:(FrameType)aType animation:(BOOL)aAnimation;
@end


@protocol AMDetailPanelViewDelegate <NSObject>

- (void)startDragView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY;
- (void)endDragView:(UIView *)dragView xOffset:(CGFloat)aOffsetX yOffset:(CGFloat)aOffsetY;
@end