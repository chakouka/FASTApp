//
//  AMBENCHACTIVELISTVIEWCONTROLLER.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//
/*************************************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM000118: iPad Beep on Sync with new WO. By Hari Kolasani. 12/9/2014
 *************************************************************************************************/

#import "AMBenchActiveListViewController.h"
#import "AMBenchActiveListcell.h"
#import "AMWorkOrder.h"
#import "AMLogicCore.h"
#import "GoogleRouteManage.h"
#import "JumpMapApp.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "AMProtocolManager.h"
#define HEIGH_OF_TABLEVIEW_ORIGINAL     88.0
#define HEIGH_OF_TABLEVIEW_CHANGED      218.0
#define HEIGH_OF_TABLEVIEW_CELL         146.0   //TODO::Hidden estimate time

#define kAMPRIORITY_STRING_CRITICAL @"Critical"
#define kAMPRIORITY_STRING_HIGH @"High"
#define kAMPRIORITY_STRING_MEDIUM @"Medium"
#define kAMPRIORITY_STRING_LOW @"Low"

typedef NS_ENUM (NSInteger, SortType) {
	SortType_EstimatedTimeEnd = 0,
	SortType_Priority,
	SortType_Distance,
	SortType_Move,
	SortType_Null
};

bool isTimerStarted;
//int  timerStartedCellRow;
NSString *timerStartedCellAssetID;
@interface AMBenchActiveListViewController ()
<
UISearchBarDelegate
>
{
	NSString *selectedWorkOrderId;
	BOOL isSearching;
	BOOL isMoving;
	BOOL isNeedRefresh;
    BOOL isCooperative;
	NSOperationQueue *searchOperationQueue;
	NSOperationQueue *refreshOperationQueue;
	NSMutableArray *searchResultList;
    
	SortType currentType;
    CGRect originViewRect;
}

@property (strong, nonatomic) NSOperationQueue *searchOperationQueue;
@property (strong, nonatomic) NSOperationQueue *refreshOperationQueue;
@property (strong, nonatomic) NSMutableArray *searchResultList;



@end

@implementation AMBenchActiveListViewController
@synthesize isSortByDistance;
@synthesize selectedWorkOrderId;
@synthesize show;
@synthesize localWorkOrders;
@synthesize isSorting;
@synthesize searchOperationQueue;
@synthesize refreshOperationQueue;
@synthesize searchResultList;
@synthesize arrMoveList;
@synthesize btnBackToBench;
#pragma mark - TEST

#pragma mark -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_FROM_AMMAINVIEWCONTROLLER object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		isSorting = NO;
		isSearching = NO;
		isMoving = NO;
		isNeedRefresh = NO;
        isCooperative = NO;
        isSortByDistance = NO;
		currentType = SortType_Null;
        
		searchOperationQueue = [[NSOperationQueue alloc] init];
		[searchOperationQueue setMaxConcurrentOperationCount:1];
        
		refreshOperationQueue = [[NSOperationQueue alloc] init];
		[refreshOperationQueue setMaxConcurrentOperationCount:1];
        
		searchResultList = [NSMutableArray array];
        arrMoveList = [NSMutableArray array];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealWithNotiFromMainViewController:) name:NOTIFICATION_FROM_AMMAINVIEWCONTROLLER object:nil];
    
    [self refreshFontInView:self.view];
    
    self.searchbarTitle.placeholder = MyLocal(@"SEARCH ASSET or Serial No.");
    
    //bkk 2/2/15 - item 000124
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.tableViewList addGestureRecognizer:lpgr];
    [btnBackToBench setTitle:MyLocal(@"BACK TO BENCH") forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
//    [self searchEnable:NO];
    [super viewWillAppear:animated];
    originViewRect = self.view.superview.frame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.superview.frame = originViewRect;
}

- (void)refreshFontInView:(UIView *)aView
{
    for (UIView *subview in [aView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeSmall]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeSmall]];
        } else if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subview;
            [btn.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeSmall]];
        }else if ([[subview subviews] count] > 0) {
            [self refreshFontInView:subview];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	self.selectedWorkOrderId = nil;
	[self deSelectRow];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Layout Change

#pragma mark - TableView List

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 90;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (isSearching) {
		return [searchResultList count];
	}
	else {
        AppDelegate *appdelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        if([localWorkOrders count] > appdelegate.woCount) {
            //CHANGE:ITEM-000118
            [self beep];
            appdelegate.woCount = [localWorkOrders count];
        }
        return [localWorkOrders count];
	}
}

//CHANGE:ITEM-000118
- (void) beep {
    
    AudioServicesPlaySystemSound(1007);
    
    //NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"beep" ofType:@"wav"];
    //SystemSoundID soundID;
    //AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    //AudioServicesPlaySystemSound (soundID);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	AMBenchActiveListCell *cell = (AMBenchActiveListCell *)[tableView dequeueReusableCellWithIdentifier:@"AMBenchActiveListCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMBenchActiveListCell" owner:[AMBenchActiveListCell class] options:nil];
		cell = (AMBenchActiveListCell *)[nib objectAtIndex:0];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
    
	NSDictionary *workOrder = nil;

    workOrder = [self.localWorkOrders objectAtIndex:indexPath.row];

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    cell.fullAssetInfoDict = [NSDictionary dictionaryWithDictionary: workOrder];
    cell.label_AssetNumber.text = [workOrder valueForKeyWithNullToNil:@"Machine_Number__c"] == nil ? @"" : [workOrder valueForKeyWithNullToNil:@"Machine_Number__c"];
    cell.label_SerialNumber.text = [workOrder valueForKeyWithNullToNil:@"SerialNumber"] == nil ? @"" : [workOrder valueForKeyWithNullToNil:@"SerialNumber"];
    cell.label_MachineType.text = [[workOrder valueForKeyWithNullToNil:@"Product2"] valueForKeyWithNullToNil:@"Name"];
    cell.strAssetID = [[workOrder valueForKeyWithNullToNil:@"Item"] valueForKeyWithNullToNil:@"Asset__c"];

    cell.label_MachineTypeTitle.text = MyLocal(@"Machine Type:");
    cell.label_SerialNumberTitle.text = MyLocal(@"Serial #:");
    cell.label_AssetNumberTitle.text = MyLocal(@"Asset #:");
    
    cell.btnGetAssetInfo.tag = indexPath.row;

    cell.btnStart.tag = indexPath.row;
    cell.btnStop.tag = indexPath.row;
    cell.btnCheckout.tag = indexPath.row;

    cell.btnStart.titleLabel.text = MyLocal(@"START");
    cell.btnStop.titleLabel.text = MyLocal(@"STOP");
    cell.btnCheckout.titleLabel.text = MyLocal(@"CHECK OUT");
    cell.btnGetAssetInfo.titleLabel.text = MyLocal(@"GET ASSET INFO");
    
    [cell.btnGetAssetInfo addTarget:self action:@selector(clickGetAssetInfoBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnStart addTarget:self action:@selector(clickStartBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnStop addTarget:self action:@selector(clickStopBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnCheckout addTarget:self action:@selector(clickCheckoutBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    if (selectedWorkOrderId) {
        if ([[workOrder valueForKey:@"Id"] isEqual:selectedWorkOrderId]) {
            [cell showShadeStatus:NO];
        }
        else {
            [cell showShadeStatus:YES];
        }
    }
    else {
        cell.viewShade.hidden = YES;
        cell.viewRight.hidden = YES;
    }
    
    if (isTimerStarted && [timerStartedCellAssetID isEqualToString:cell.label_AssetNumber.text])
    {
        [cell setBackgroundColor:[UIColor lightGrayColor]];
    } else {
        [cell setBackgroundColor:[UIColor lightTextColor]];
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)refreshSelectStatusWithWorkOrderId:(NSString *)aWorkOrderId
{

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	if (isSearching) {
		return NO;
	}
	else {
		return YES;
	}
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	NSUInteger fromRow = [fromIndexPath row];
	NSUInteger toRow = [toIndexPath row];
    
	if (fromRow != toRow) {
		isNeedRefresh = YES;
	}
    
    [localWorkOrders exchangeObjectAtIndex:fromRow withObjectAtIndex:toRow];
    
    if ([arrMoveList count] == [localWorkOrders count]) {
        DLog(@"arrMoveList exchangeObjectAtIndex");
        [arrMoveList exchangeObjectAtIndex:fromRow withObjectAtIndex:toRow];
    }
}

#pragma mark - Load Data


- (void)refreshActiveBenchList:(NSMutableArray *)aLocalWorkOrders;
{
    [self myRefreshTaskMethod:aLocalWorkOrders];
}

- (void)refreshWorkOrderStatus:(NSMutableArray *)aList
{

}

- (void)myRefreshTaskMethod:(NSMutableArray *)aWorkOrders {
	self.localWorkOrders = [NSMutableArray arrayWithArray:aWorkOrders];
	[self reloadData];
}

- (void)deSelectRow {
	selectedWorkOrderId = nil;
	[self reloadData];
}

#pragma mark - Noti

- (void)dealWithNotiFromMainViewController:(NSNotification *)notification {
	if ([[[notification object] objectForKey:KEY_OF_TYPE] isEqualToString:TYPE_OF_CLICK_SCREEN]) {
		UITouch *touch = [[notification object] objectForKey:KEY_OF_INFO];
        CGPoint point = [touch locationInView:self.view];
        
        DLog(@"Noti Point : %f - %f",point.x,point.y);
        
        if (!CGRectContainsPoint(self.view.frame, point)
            && [self.searchbarTitle isFirstResponder]) {
            [self.searchbarTitle resignFirstResponder];
        }
    }
}

#pragma mark - View

- (void)showProgressHUD {
	self.view.userInteractionEnabled = NO;
#ifdef TEST_FOR_SVPROGRESSHUD
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%s", __FUNCTION__]];
#else
    [SVProgressHUD show];
#endif
}

- (void)hiddenProgressHUD {
	[SVProgressHUD dismiss];
	self.view.userInteractionEnabled = YES;
}

- (void)reloadData {
	MAIN ( ^{
        if (localWorkOrders) {
            [self.tableViewList reloadData];
        }
	});
}

#pragma mark - Gesture delegate //bkk 2/2/15 - item 000124
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableViewList];
    
    NSIndexPath *indexPath = [self.tableViewList indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSArray *todayCheckInWOList = [[AMDBManager sharedInstance] getSelfOwnedTodayCheckInWorkOrders];
        if (todayCheckInWOList.count == 0)
        {
            [self.tableViewList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tableViewList didSelectRowAtIndexPath:indexPath];
            [self showCheckInAlert:self.localWorkOrders[indexPath.row]];
        }
        NSLog(@"long press on table view at row %d", indexPath.row);
    } else {
        NSLog(@"gestureRecognizer.state = %d", gestureRecognizer.state);
    }
}
#pragma mark - CheckIn //bkk 2/2/15 - item 000124
- (void)showCheckInAlert:(AMWorkOrder *)workorder {
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
                                  NSDictionary *dicInfo = @{
                                                            KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                                                            KEY_OF_INFO:self.localWorkOrders,
                                                            KEY_OF_FLAG:[NSNumber numberWithBool:NO]
                                                            };
                                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];

                              }];
                              
                          }
                      }];
}



#pragma mark - Layout Change

- (void)changeLeftListPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
    
    self.show = !isHidden;
    
    [UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         if (isHidden) {
                             [self.viewLeftListPanel setFrame:CGRectMake(-300,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             
                         }
                         else {
                             [self.viewLeftListPanel setFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             

                         }
                     }
     
                     completion: ^(BOOL finished) {
                     
                     }];
}
- (IBAction)btnBackToBench:(id)sender {
    //Back to bench view
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                              KEY_OF_INFO:[NSNumber numberWithInteger:7]
                              };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
}

- (IBAction)clickGetAssetInfoBtn:(id)sender {
    //Asset info view
    UIButton *button = ((UIButton*) sender);
    
    AMBenchActiveListCell *cell = [self.tableViewList cellForRowAtIndexPath: [NSIndexPath indexPathForRow:button.tag inSection:[self.tableViewList numberOfSections]-1]];
    
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                              KEY_OF_INFO:[NSNumber numberWithInteger:9],
                              @"FullAsset" : cell.fullAssetInfoDict
                              };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
}

- (IBAction)clickStartBtn:(id)sender {
    UIButton *button = ((UIButton*) sender);
    
    AMBenchActiveListCell *cell = [self.tableViewList cellForRowAtIndexPath: [NSIndexPath indexPathForRow:button.tag inSection:[self.tableViewList numberOfSections]-1]];
    
    //Make sure global isTimerStarted is false before coming in here
    if(!isTimerStarted)
    {
        //toggleTimer on Server
        [[AMProtocolManager sharedInstance] toggleTimerForAssetStart:cell.strAssetID completion:^(NSInteger type, NSError *error, id userData, id responseData) {
            
            
            if([[responseData valueForKeyWithNullToNil:@"success"] isEqualToString:@"true"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView showWithTitle:MyLocal(@"Success") message:MyLocal(@"Started Successfully") style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        //disable Start button
                        [button setUserInteractionEnabled:NO];
                        
                        //Enable Stop button
                        [cell.btnStop setUserInteractionEnabled:YES];
                        
                        cell.isTimerRunning = YES;
                        isTimerStarted = YES;
                        //timerStartedCellRow = button.tag;
                        timerStartedCellAssetID = [NSString stringWithString:cell.label_AssetNumber.text];
                        [cell setBackgroundColor:[UIColor lightGrayColor]];
                        
                    }];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView showWithTitle:@"Error" message:@"Already in progress" style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        //for scenario when the app has crashed or we quit, we need to reestablish the state of the button so that we can stop the timer...
                        //disable Start button
                        [button setUserInteractionEnabled:NO];
                        
                        //Enable Stop button
                        [cell.btnStop setUserInteractionEnabled:YES];
                        
                        cell.isTimerRunning = YES;
                        isTimerStarted = YES;
                        //timerStartedCellRow = button.tag;
                        timerStartedCellAssetID = [NSString stringWithString:cell.label_AssetNumber.text];
                    }];
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView showWithTitle:@"Error" message:@"Timer Already Started!" style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {

                
            }];
        });
    }
    

}

- (IBAction)clickStopBtn:(id)sender {
    UIButton *button = ((UIButton*) sender);
    
    AMBenchActiveListCell *cell = [self.tableViewList cellForRowAtIndexPath: [NSIndexPath indexPathForRow:button.tag inSection:[self.tableViewList numberOfSections]-1]];
    
    if(isTimerStarted && ([timerStartedCellAssetID isEqualToString:cell.label_AssetNumber.text]))
    {

        //toggleTimer on Server
        [[AMProtocolManager sharedInstance] toggleTimerForAssetStop: cell.strAssetID completion:^(NSInteger type, NSError *error, id userData, id responseData) {
            
            if([[responseData valueForKeyWithNullToNil:@"success"] isEqualToString:@"true"])
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView showWithTitle:MyLocal(@"Success") message:MyLocal(@"Stopped Successfully") style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        //Disable Stop button
                        [button setUserInteractionEnabled:NO];
                        
                        //Enable Start button
                        [cell.btnStart setUserInteractionEnabled:YES];
                        cell.isTimerRunning = NO;
                        isTimerStarted = NO;
                        //timerStartedCellRow = -999;
                        timerStartedCellAssetID = @"";
                        [cell setBackgroundColor:[UIColor lightTextColor]];
                        
                    }];
                });


            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView showWithTitle:@"Error" message:@"Cannot stop one you haven't started." style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        
                    }];
                });
            }
        }];
    }
}

- (IBAction)clickCheckoutBtn:(id)sender {

    //Asset info view
    UIButton *button = ((UIButton*) sender);
    
    AMBenchActiveListCell *cell = [self.tableViewList cellForRowAtIndexPath: [NSIndexPath indexPathForRow:button.tag inSection:[self.tableViewList numberOfSections]-1]];
    

    [[AMProtocolManager sharedInstance] toggleTimerForAssetStop:cell.strAssetID completion:^(NSInteger type, NSError *error, id userData, id responseData) {
        
        if([[responseData valueForKeyWithNullToNil:@"success"] isEqualToString:@"true"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //enable Start button
                [cell.btnStart setUserInteractionEnabled:YES];
                [cell.btnStop setUserInteractionEnabled:NO];
                
                NSDictionary *dicInfo = @{
                                          KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                                          KEY_OF_INFO:[NSNumber numberWithInteger:10],
                                          @"FullAsset" : cell.fullAssetInfoDict
                                          };
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView showWithTitle:@"Check Out Error" message:@"Must Stop Timer to Checkout" cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                }];
            });
        }
    }];

}

@end
