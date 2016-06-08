//
//  AMCheckoutPanelViewController.m
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

#import "AMCheckoutPanelViewController.h"

#import "AMCheckoutViewController.h"
#import "AMInvoiceViewController.h"
#import "AMPointsViewController.h"
#import "AMVerificationViewController.h"
#import "AMCheckoutTabViewController.h"
#import "AMSyncingManager.h"
#import "AMOnlineOprManager.h"

@interface AMCheckoutPanelViewController ()
<
AMCheckoutViewControllerDelegate,
AMVerificationViewControllerDelegate,
AMPointsViewControllerDelegate,
AMInvoiceViewControllerDelegate
>
{
    NSMutableArray *arrTitleItems;
	BOOL isFullScreen;
    AMWorkOrder *workOrder;
    UIAlertView *syncAlertview;


    CGFloat xCoor;
	CGFloat yCoor;
}

@property (assign, nonatomic) BOOL isFullScreen;
@property (strong, nonatomic) NSMutableArray *arrTitleItems;
@property (strong, nonatomic) AMWorkOrder *workOrder;

@end

@implementation AMCheckoutPanelViewController
@synthesize workOrder;
@synthesize isFullScreen;
@synthesize selectedWorkOrder;
@synthesize topTabVC;
@synthesize checkoutVC;
@synthesize invoiceVC;
@synthesize pointsVC;
@synthesize verificationVC;
@synthesize arrTitleItems;
//@synthesize checkOutSetp;
@synthesize delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self viewInitialization];
    
    syncAlertview = [[UIAlertView alloc] initWithTitle:MyLocal(@"Syncing")
                                               message:MyLocal(@"Please do not shut down device while syncing")
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(syncAlertview.bounds.size.width / 2, syncAlertview.bounds.size.height - 50);
    [indicator startAnimating];
    [syncAlertview setValue:indicator forKey:@"accessoryView"];
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)];
//    [self.view addGestureRecognizer:panGesture];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)panDetected:(UIPanGestureRecognizer *)gesture
{
    CGPoint touchPoint = [gesture locationInView:self.view.superview];
    
    if (!CGRectContainsPoint(self.topView.frame, touchPoint)) {
        return;
    }
    
    static CGPoint originalCenter;
    
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = touchPoint;
        xCoor = self.view.superview.frame.origin.x;
		yCoor = self.view.superview.frame.origin.y;
        
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint currentPoint = touchPoint;
		xCoor = xCoor + currentPoint.x - originalCenter.x;
		yCoor =  yCoor + currentPoint.y - originalCenter.y;
        if (delegate && [delegate respondsToSelector:@selector(startDragCheckoutPanelView:xOffset:yOffset:)]) {
            [delegate startDragCheckoutPanelView:self.view xOffset:xCoor yOffset:yCoor];
		}
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateFailed ||
             gesture.state == UIGestureRecognizerStateCancelled)
    {
        float xTemp = self.view.superview.frame.origin.x;
        float yTemp = self.view.superview.frame.origin.y;
        if (delegate && [delegate respondsToSelector:@selector(endDragCheckoutPanelView:xOffset:yOffset:)]) {
            [delegate endDragCheckoutPanelView:self.view xOffset:xTemp yOffset:yTemp];
		}
    }
}

#pragma mark - 

- (void)viewInitialization {
    if (!topTabVC) {
        topTabVC = [[AMCheckoutTabViewController alloc] initWithNibName:@"AMCheckoutTabViewController" bundle:nil];
        topTabVC.delegate = self;
        topTabVC.selectedIndex = AMCheckoutTabType_Verification;
        [self.topView addSubview:topTabVC.view];
    }
    
    [self didSelectCheckoutTabAtTabType:topTabVC.selectedIndex];
    self.topTabVC.checkOutSetp = AMCheckoutTabType_Verification;
}

-(void)refreshToInitialization
{
    [self.invoiceVC refreshToInitialization];
}

-(void)refreshDataWithLocalWorkOrderInfo:(AMWorkOrder *)aWorkOrder
{
    self.workOrder = aWorkOrder;
    [self didSelectCheckoutTabAtTabType:AMCheckoutTabType_Verification];
    self.topTabVC.selectedIndex = AMCheckoutTabType_Verification;
    self.topTabVC.checkOutSetp = AMCheckoutTabType_Verification;
}

- (void)changeFrameTo:(FrameType)aType animation:(BOOL)aAnimation {
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         switch (aType) {
                             case FrameType_Top:
                             case FrameType_Normal:
                             {
                                 self.view.frame = CGRectMake(0, 0, 930, 716);
                                 self.viewMain.frame = CGRectMake(0, 80, 930, 636);
                                 isFullScreen = NO;
                             }
                                 break;
                                 
                             case FrameType_Full:
                             {
                                 self.view.frame = CGRectMake(0, 0, 930, 716);
                                  self.viewMain.frame = CGRectMake(0, 80, 930, 636);
                                 isFullScreen = YES;
                             }
                                 break;
                                 
                             default:
                                 break;
                         }
                     } completion: ^(BOOL finished) {
                         [self.checkoutVC.mainTableView reloadData];
                     }];
}

#pragma mark -
- (IBAction)fullScreenButtonTapped:(UIButton *)sender {
    
//    if (isFullScreen) {
//        [self.fullScreenButton setImage:[UIImage imageNamed:@"fullscreen-button"] forState:UIControlStateNormal];
//        [self.fullScreenButton setImage:[UIImage imageNamed:@"fullscreen-button"] forState:UIControlStateHighlighted];
//    }
//    else
//    {
//        [self.fullScreenButton setImage:[UIImage imageNamed:@"small-screen-button"] forState:UIControlStateNormal];
//        [self.fullScreenButton setImage:[UIImage imageNamed:@"small-screen-button"] forState:UIControlStateHighlighted];
//    }
    
    [self showFullScreen:!isFullScreen];
}

- (void)showFullScreen:(BOOL)boolValue
{
    isFullScreen = boolValue;
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_SCREEN_FRAME,
                              KEY_OF_INFO:[NSNumber numberWithBool:boolValue]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_CHECKOUTPANELVIEWCONTROLLER object:dicInfo];
}

#pragma mark -

- (void)didSelectCheckoutTabAtTabType:(AMCheckoutTabType)tabType
{
    switch (tabType) {
        case AMCheckoutTabType_Checkout:
        {
            if (!checkoutVC) {
                checkoutVC = [[AMCheckoutViewController alloc] initWithNibName:NSStringFromClass([AMCheckoutViewController class]) bundle:nil];
                checkoutVC.delegate = self;
                [self.viewMain addSubview:checkoutVC.view];
            }
            
            //Change: ITEM000121
            checkoutVC.arrResultAssetRequest = [NSMutableArray arrayWithArray:self.verificationVC.arrResultAssetRequest];
            
            [self.viewMain bringSubviewToFront:checkoutVC.view];
            
            [checkoutVC setupDataSourceByWorkOrder:self.workOrder];
        }
            break;
            
        case AMCheckoutTabType_Verification:
        {
            if (!verificationVC) {
                verificationVC = [[AMVerificationViewController alloc] initWithNibName:NSStringFromClass([AMVerificationViewController class]) bundle:nil];
                verificationVC.delegate = self;
                [self.viewMain addSubview:verificationVC.view];
            }
            [self.viewMain bringSubviewToFront:verificationVC.view];
            
            [verificationVC setupDataSourceByInfo:self.workOrder];
        }
            break;
            
        case AMCheckoutTabType_Points:
        {
            if (!pointsVC) {
                pointsVC = [[AMPointsViewController alloc] initWithNibName:NSStringFromClass([AMPointsViewController class]) bundle:nil];
                pointsVC.delegate = self;
                [self.viewMain addSubview:pointsVC.view];
            }
            [self.viewMain bringSubviewToFront:pointsVC.view];
            
             [pointsVC setupDataSourceByInfo:self.workOrder];
        }
            break;
            
        case AMCheckoutTabType_Invoice:
        {
            if (!invoiceVC) {
                invoiceVC = [[AMInvoiceViewController alloc] initWithNibName:NSStringFromClass([AMInvoiceViewController class]) bundle:nil];
                invoiceVC.delegate = self;
                [self.viewMain addSubview:invoiceVC.view];
                invoiceVC.txtSelectedFilters.text = @"";
                
                if (checkoutVC.strSelectedFilters) {
                    if (checkoutVC.strSelectedFilters.length > 0) {
                        invoiceVC.txtSelectedFilters.text = [NSString stringWithFormat:@"Filter Exchanges\n\n%@\n\n Priced per contract.  An invoice will be generated and mailed by our local office.\n", checkoutVC.strSelectedFilters];
                    } else {
                        invoiceVC.txtSelectedFilters.text = @"";
                    }
                } else {
                    invoiceVC.txtSelectedFilters.text = @"";
                }

            }else{
                invoiceVC.txtSelectedFilters.text = @"";
            }
            
            //make sure email field and checkbox are cleared
            [invoiceVC setupDataSourceByInfo:self.workOrder];
            invoiceVC.imageSelected.hidden = YES;
            invoiceVC.textFieldEmail.text = TEXT_OF_NULL;
            invoiceVC.isMCEmailSelected = NO;
            
            [self.viewMain bringSubviewToFront:invoiceVC.view];
            
            NSMutableArray *arrList = [NSMutableArray arrayWithArray:self.checkoutVC.arrInvoiceItems];
            self.invoiceVC.tempInvoiceList = [NSMutableArray arrayWithArray:arrList];
            
            [invoiceVC setupDataSourceByInfo:self.workOrder];
//Don't sync when moving from 3rd tab to this one. bkk 11/2/2015
//            [[AMSyncingManager sharedInstance] startSyncing:^(NSInteger type, NSError * error){
//                if (!error ||
//                    [error.localizedDescription rangeOfString:kAM_MESSAGE_SYNC_IN_PROCESS].location == NSNotFound) {
//                    [self syncingCompletion:error];
//                }
//            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -Sync Completion
- (void)syncingCompletion:(NSError *)error
{
    [syncAlertview dismissWithClickedButtonIndex:0 animated:YES];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
            
            [userInfo setObject:TYPE_OF_SHOW_ALERT forKey:KEY_OF_TYPE];
            if (error.localizedDescription) {
                [userInfo setObject:error.localizedDescription forKey:KEY_OF_INFO];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SYNCING_DONE object:nil];
    });
}

#pragma mark -

- (void)didClickCheckoutViewControllerCreatNewBtn
{
    //Save check out page 1 data
    [[AMLogicCore sharedInstance] updateAssetList:self.verificationVC.arrResultAsset completionBlock: ^(NSInteger type, NSError *error) {
        MAIN ( ^{
            if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
            }
            else
            {
                DLog(@"Save check out page 1 data : step 1 Success")
            }
        });
        
        [[AMLogicCore sharedInstance] saveAssetRequestList:self.verificationVC.arrResultAssetRequest completionBlock: ^(NSInteger type, NSError *error) {
            MAIN ( ^{
                if (error) {
                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                }
                else
                {
                    DLog(@"Save check out page 1 data : step 2 Success")
                }
                
                //Save check out page 2 data
                
                for (NSMutableDictionary *dicInfo in self.pointsVC.arrPointsInfos) {
                    if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_0) {
                        self.pointsVC.workOrder.leftInOrderlyManner = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                    }
                    else if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_1) {
                        self.pointsVC.workOrder.testedAll = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                    }
                    else if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_2) {
                        self.pointsVC.workOrder.inspectedTubing = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                    }
                }

                [[AMLogicCore sharedInstance] updateWorkOrder:self.pointsVC.workOrder completionBlock: ^(NSInteger type, NSError *error) {
                    MAIN ( ^{
                        if (error) {
                            [AMUtilities showAlertWithInfo:[error localizedDescription]];
                        }
                        else
                        {
                            DLog(@"Save check out page 2 data : Success")
                        }
                    });
                    
                    //Save check out page 3 data
                    
                    self.checkoutVC.workOrder.repairCode = self.checkoutVC.strRepairCode;
                    self.checkoutVC.workOrder.notes = self.checkoutVC.strNotes;
                    
                    [[AMLogicCore sharedInstance] saveInvoiceList:self.checkoutVC.arrInvoiceItems completionBlock: ^(NSInteger type, NSError *error) {
                        MAIN ( ^{
                            if (error) {
                                [AMUtilities showAlertWithInfo:[error localizedDescription]];
                            }
                            else
                            {
                                DLog(@"Save check out page 3 data : Success")
                            }
                        });
                        
                        [[AMLogicCore sharedInstance] finishCheckOutWorkOrder:workOrder completion: ^(NSInteger type, NSError *error){
                            MAIN ( ^{
                                if (error) {
                                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                    return ;
                                }
                                else {
                                    [delegate finishedAllCheckoutProcess];
                                }
                            });
                        }];
                    }];
                }];
            });
        }];
    }];
}

- (void)didClickCheckoutViewControllerNextBtn
{
//     if (1)
    if ([[AMLogicCore sharedInstance] shouldShowSignaturePage:self.workOrder])
    {
        [self didSelectCheckoutTabAtTabType:AMCheckoutTabType_Invoice];
        self.topTabVC.selectedIndex = AMCheckoutTabType_Invoice;
        self.topTabVC.checkOutSetp = AMCheckoutTabType_Invoice;
    }
    else
    {
        //bkk item000662 Checkout Process - no signature needed
        self.workOrder.status = @"Checked Out";
        [[AMOnlineOprManager sharedInstance] updateSingleWO:self.workOrder completion:^(NSInteger type, NSError *error) {
            
        }];
        self.workOrder.status = @"In Progress";
        
        [self performSelector:@selector(hideAlert) withObject:syncAlertview afterDelay:30];
        
        [syncAlertview show];
        
        [[AMSyncingManager sharedInstance] startSyncing:^(NSInteger type, NSError *error) {
            [self syncingCompletion:error];
        }];
        
        //Save check out page 1 data
        [[AMLogicCore sharedInstance] updateAssetList:self.verificationVC.arrResultAsset completionBlock: ^(NSInteger type, NSError *error) {
            MAIN ( ^{
                if (error) {
                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                }
                else
                {
                    DLog(@"Save check out page 1 data : step 1 Success")
                }
            });
            
            [[AMLogicCore sharedInstance] saveAssetRequestList:self.verificationVC.arrResultAssetRequest completionBlock: ^(NSInteger type, NSError *error) {
                MAIN ( ^{
                    if (error) {
                        [AMUtilities showAlertWithInfo:[error localizedDescription]];
                    }
                    else
                    {
                        DLog(@"Save check out page 1 data : step 2 Success")
                    }
                    
                    //Save check out page 2 data
                    
                    for (NSMutableDictionary *dicInfo in self.pointsVC.arrPointsInfos) {
                        if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_0) {
                            self.pointsVC.workOrder.leftInOrderlyManner = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                        }
                        else if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_1) {
                            self.pointsVC.workOrder.testedAll = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                        }
                        else if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_2) {
                            self.pointsVC.workOrder.inspectedTubing = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                        }
                    }
                    
                    [[AMLogicCore sharedInstance] updateWorkOrder:self.pointsVC.workOrder completionBlock: ^(NSInteger type, NSError *error) {
                        MAIN ( ^{
                            if (error) {
                                [AMUtilities showAlertWithInfo:[error localizedDescription]];
                            }
                            else
                            {
                                DLog(@"Save check out page 2 data : Success")
                            }
                        });
                        
                        //Save check out page 3 data
                        
                        self.checkoutVC.workOrder.repairCode = self.checkoutVC.strRepairCode;
                        self.checkoutVC.workOrder.notes = self.checkoutVC.strNotes;
                        
                        [[AMLogicCore sharedInstance] updateWorkOrder:self.checkoutVC.workOrder completionBlock:nil];
                        
                        [[AMLogicCore sharedInstance] saveInvoiceList:self.checkoutVC.arrInvoiceItems completionBlock: ^(NSInteger type, NSError *error) {
                            MAIN ( ^{
                                if (error) {
                                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                }
                                else
                                {
                                    DLog(@"Save check out page 3 data : Success")
                                }
                            });
                            
                            [[AMLogicCore sharedInstance] finishCheckOutWorkOrder:workOrder completion: ^(NSInteger type, NSError *error){
                                MAIN ( ^{
                                    if (error) {
                                        [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                        return ;
                                    }
                                    else {
                                        [delegate finishedAllCheckoutProcess];
                                    }
                                });
                            }];
                        }];
                    }];
                });
            }];
        }];
    }
}

- (void)didClickVerificationViewControllerNextBtn
{
     [self didSelectCheckoutTabAtTabType:AMCheckoutTabType_Points];
     self.topTabVC.selectedIndex = AMCheckoutTabType_Points;
     self.topTabVC.checkOutSetp = AMCheckoutTabType_Points;
}

- (void)didClickPointsViewControllerNextBtn
{
    [self didSelectCheckoutTabAtTabType:AMCheckoutTabType_Checkout];
    self.topTabVC.selectedIndex = AMCheckoutTabType_Checkout;
    self.topTabVC.checkOutSetp = AMCheckoutTabType_Checkout;
}

- (void)didClickInvoiceViewControllerNextBtn
{
    [[AMLogicCore sharedInstance] updateAssetList:self.verificationVC.arrResultAsset completionBlock: ^(NSInteger type, NSError *error) {
        MAIN ( ^{
            if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
            }
            else
            {
                DLog(@"Save check out page 1 data : step 1 Success")
            }
        });
        
        [[AMLogicCore sharedInstance] saveAssetRequestList:self.verificationVC.arrResultAssetRequest completionBlock: ^(NSInteger type, NSError *error) {
            MAIN ( ^{
                if (error) {
                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                }
                else
                {
                    DLog(@"Save check out page 1 data : step 2 Success")
                }
                
                //Save check out page 2 data
                
                for (NSMutableDictionary *dicInfo in self.pointsVC.arrPointsInfos) {
                    if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_0) {
                        self.pointsVC.workOrder.leftInOrderlyManner = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                    }
                    else if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_1) {
                        self.pointsVC.workOrder.testedAll = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                    }
                    else if ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue] == AMCheckoutCellType_Points_Check_2) {
                        self.pointsVC.workOrder.inspectedTubing = [dicInfo objectForKey:KEY_OF_CHECK_STATUS];
                    }
                }

                [[AMLogicCore sharedInstance] updateWorkOrder:self.pointsVC.workOrder completionBlock: ^(NSInteger type, NSError *error) {
                    MAIN ( ^{
                        if (error) {
                            [AMUtilities showAlertWithInfo:[error localizedDescription]];
                        }
                        else
                        {
                            DLog(@"Save check out page 2 data : Success")
                        }
                    });
                    
                    //Save check out page 3 data
                    
                    self.checkoutVC.workOrder.repairCode = self.checkoutVC.strRepairCode;
                    self.checkoutVC.workOrder.notes = self.checkoutVC.strNotes;
                    
                    [[AMLogicCore sharedInstance] saveInvoiceList:self.checkoutVC.arrInvoiceItems completionBlock: ^(NSInteger type, NSError *error) {
                        MAIN ( ^{
                            if (error) {
                                [AMUtilities showAlertWithInfo:[error localizedDescription]];
                            }
                            else
                            {
                                DLog(@"Save check out page 3 data : Success")
                            }
                        });
                        
                        if (delegate && [delegate respondsToSelector:@selector(finishedAllCheckoutProcess)]) {
                            
                            [[AMLogicCore sharedInstance] finishCheckOutWorkOrder:workOrder completion: ^(NSInteger type, NSError *error) {
                                MAIN ( ^{
                                    if (error) {
                                        [AMUtilities showAlertWithInfo:[error localizedDescription]];
                                        return ;
                                    }
                                    else {
                                        [delegate finishedAllCheckoutProcess];
                                    }
                                });
                            }];
                        }
                    }];
                }];
            });
        }];
    }];
}

-(void) keyboardWillShow:(NSNotification *)note{
    
    if (CGRectGetHeight(self.viewMain.frame) < 300) {
        return;
    }
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect btnFrame = self.viewMain.frame;
    btnFrame.size.height = btnFrame.size.height - keyboardBounds.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    self.viewMain.frame = btnFrame;
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect btnFrame = self.viewMain.frame;
//    btnFrame.size.height = btnFrame.size.height + keyboardBounds.size.height;
    btnFrame.size.height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.topView.frame);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.viewMain.frame = btnFrame;
    [UIView commitAnimations];
}

- (void)hideAlert {
    if (syncAlertview.visible) {
        [syncAlertview dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
