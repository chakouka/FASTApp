//
//  AMORDERLISTVIEWCONTROLLER.m
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

#import "AMOrderListViewController.h"
#import "AMOrderListcell.h"
#import "AMWorkOrder.h"
#import "AMLogicCore.h"
#import "GoogleRouteManage.h"
#import "JumpMapApp.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>

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


@interface AMOrderListViewController ()
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
@property (weak, nonatomic) IBOutlet UIButton *btnMove;

@property (weak, nonatomic) IBOutlet UILabel *lableTSortBy;
@property (weak, nonatomic) IBOutlet UIButton *btnSortByStartTime;
@property (weak, nonatomic) IBOutlet UIButton *btnSortByPriority;
@property (weak, nonatomic) IBOutlet UIButton *btnSortByDistance;


@end

@implementation AMOrderListViewController
@synthesize isSortByDistance;
@synthesize selectedWorkOrderId;
@synthesize show;
@synthesize localWorkOrders;
@synthesize isSorting;
@synthesize searchOperationQueue;
@synthesize refreshOperationQueue;
@synthesize searchResultList;
@synthesize arrMoveList;

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
    
    self.searchbarTitle.placeholder = MyLocal(@"SEARCH SPECIFIC ACCOUNT");
    [self.btnMove setTitle:MyLocal(@"Move") forState:UIControlStateNormal];
    [self.btnMove setTitle:MyLocal(@"Move") forState:UIControlStateHighlighted];
    self.lableTSortBy.text = MyLocal(@"SORT BY");
    self.labelSort.text = MyLocal(@"START TIME");
    [self.btnSortByStartTime setTitle:MyLocal(@"SORT BY START TIME") forState:UIControlStateNormal];
    [self.btnSortByStartTime setTitle:MyLocal(@"SORT BY START TIME") forState:UIControlStateHighlighted];
    [self.btnSortByPriority setTitle:MyLocal(@"SORT BY PRIORITY") forState:UIControlStateNormal];
    [self.btnSortByPriority setTitle:MyLocal(@"SORT BY PRIORITY") forState:UIControlStateHighlighted];
    [self.btnSortByDistance setTitle:MyLocal(@"SORT BY DISTANCE") forState:UIControlStateNormal];
    [self.btnSortByDistance setTitle:MyLocal(@"SORT BY DISTANCE") forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (void)openSortViewWithAnimation:(BOOL)aAnimation {
	if (isSorting) {
		return;
	}
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         [self.tableViewList setFrame:CGRectMake(0,
                                                                 HEIGH_OF_TABLEVIEW_CHANGED,
                                                                 CGRectGetWidth(self.view.frame),
                                                                 CGRectGetHeight(self.view.frame) - HEIGH_OF_TABLEVIEW_CHANGED)];
                         
                         [self.btnSort setImage:[UIImage imageNamed:@"Arrow-up"] forState:UIControlStateNormal];
                         [self.btnSort setImage:[UIImage imageNamed:@"Arrow-up"] forState:UIControlStateHighlighted];
                     }
     
	                 completion: ^(BOOL finished)
     {
         isSorting = YES;
     }];
}

- (void)closeSortViewWithAnimation:(BOOL)aAnimation {
	if (!isSorting) {
		return;
	}
    
	[UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
	                      delay:0.0
	                    options:UIViewAnimationOptionCurveEaseInOut
	                 animations: ^{
                         [self.tableViewList setFrame:CGRectMake(0,
                                                                 HEIGH_OF_TABLEVIEW_ORIGINAL,
                                                                 CGRectGetWidth(self.view.frame),
                                                                 CGRectGetHeight(self.view.frame) - HEIGH_OF_TABLEVIEW_ORIGINAL)];
                         
                         [self.btnSort setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateNormal];
                         [self.btnSort setImage:[UIImage imageNamed:@"arrow-down"] forState:UIControlStateHighlighted];
                     }
     
	                 completion: ^(BOOL finished) {
                         isSorting = NO;
                     }];
}

#pragma mark - Click

- (IBAction)clickMoveBtn:(UIButton *)sender {
    
    //    //For Test ============ Begin
    //    [self removeLastObjectFromList];
    //
    //    return;
    //    //For Test ============ End
    
	[self.tableViewList setEditing:!self.tableViewList.editing animated:YES];
    
	if (self.tableViewList.editing) {
		if (isCooperative) {
			[UIAlertView showWithTitle:@""
			                   message:MyLocal(@"One or more Field Technicians is assigned to a work order, please consider appropriately")
			         cancelButtonTitle:MyLocal(@"Cancel")
			         otherButtonTitles:@[MyLocal(@"Reorder")]
			                  tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      [self.tableViewList setEditing:!self.tableViewList.editing animated:YES];
                                      return;
                                  }
                                  else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:MyLocal(@"Reorder")]) {
                                      isMoving = YES;
                                      [sender setTitle:MyLocal(@"Done") forState:UIControlStateNormal];
                                      [sender setTitle:MyLocal(@"Done") forState:UIControlStateHighlighted];
                                      [self sortEnable:!isMoving];
                                  }
                              }];
		}
		else {
			isMoving = YES;
			[sender setTitle:MyLocal(@"Done") forState:UIControlStateNormal];
			[sender setTitle:MyLocal(@"Done") forState:UIControlStateHighlighted];
			[self sortEnable:!isMoving];
		}
	}
	else {
		isMoving = NO;
		[sender setTitle:MyLocal(@"Move") forState:UIControlStateNormal];
		[sender setTitle:MyLocal(@"Move") forState:UIControlStateHighlighted];
        
		if (!isNeedRefresh) {
            [self sortEnable:!isMoving];
			return;
		}
        
		isNeedRefresh = NO;
        
        currentType = SortType_Move;
        
        [self refreshMoveList];
        
		NSDictionary *dicInfo = @{
                                  KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                                  KEY_OF_INFO:self.localWorkOrders,
                                  KEY_OF_FLAG:[NSNumber numberWithBool:NO]
                                  };
        
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
		[self sortEnable:!isMoving];
	}
}


- (IBAction)clickSortBtn:(UIButton *)sender {
	if (isSorting) {
		[self closeSortViewWithAnimation:YES];
		[self moveEnable:isSorting];
	}
	else {
		if (isCooperative) {
			[UIAlertView showWithTitle:@""
			                   message:MyLocal(@"One or more Field Technicians is assigned to a work order, please consider appropriately")
			         cancelButtonTitle:MyLocal(@"Cancel")
			         otherButtonTitles:@[MyLocal(@"Reorder")]
			                  tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                  if (buttonIndex == [alertView cancelButtonIndex]) {
                                      return;
                                  }
                                  else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:MyLocal(@"Reorder")]) {
                                      [self openSortViewWithAnimation:YES];
                                      [self moveEnable:isSorting];
                                  }
                              }];
		}
		else {
			[self openSortViewWithAnimation:YES];
			[self moveEnable:isSorting];
		}
	}
}

- (IBAction)clickSortByEndTimeBtn:(UIButton *)sender {
	[self sortLocalWorkOrderListBy:SortType_EstimatedTimeEnd];
	self.labelSort.text = MyLocal(@"START TIME");
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                              KEY_OF_INFO:self.localWorkOrders
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self clickSortBtn:nil];
}

- (IBAction)clickSortByPriorityBtn:(UIButton *)sender {
	[self sortLocalWorkOrderListBy:SortType_Priority];
	self.labelSort.text = MyLocal(@"PRIORITY");
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                              KEY_OF_INFO:self.localWorkOrders,
                              KEY_OF_FLAG:[NSNumber numberWithBool:NO]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self clickSortBtn:nil];
}

- (IBAction)clickSortByDistanceBtn:(UIButton *)sender {
	[self sortLocalWorkOrderListBy:SortType_Distance];
	self.labelSort.text = MyLocal(@"DISTANCE");
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                              KEY_OF_INFO:self.localWorkOrders,
                              KEY_OF_FLAG:[NSNumber numberWithBool:YES]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self clickSortBtn:nil];
}

#pragma mark -

-(void)clickMapBtn:(UIButton *)sender
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:KEY_OF_CURRENT_LOCATION] && ![JumpMapApp isInstalledGoogleMapApp]) {
        [UIAlertView showWithTitle:@""
                           message:MyLocal(@"Sorry! Can Not Get Your Current Position. Please Try Later")
                 cancelButtonTitle:MyLocal(@"OK")
                 otherButtonTitles:nil
                          tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  return;
                              }
                          }];
        return;
    }
    
    CLLocation *currentLocation = [AMUtilities currentLocation];
    CLLocationCoordinate2D locationCorrrdinate = currentLocation.coordinate;
    
    [UIAlertView showWithTitle:@""
                       message:MyLocal(@"You are about to leave this application. Are you sure to navigate to maps ?")
             cancelButtonTitle:MyLocal(@"No")
             otherButtonTitles:@[MyLocal(@"Yes")]
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              return;
                          }
                          else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:MyLocal(@"Yes")]) {
                              AMWorkOrder *workOrder = nil;
                              
                              if (isSearching) {
                                  workOrder = [self.searchResultList objectAtIndex:sender.tag];
                              }
                              else {
                                  workOrder = [self.localWorkOrders objectAtIndex:sender.tag];
                              }
                              
                              CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:[workOrder.latitude floatValue] longitude:[workOrder.longitude floatValue]];
                              
                              if ([JumpMapApp isInstalledGoogleMapApp]) {
                                  if (currentLocation) {
                                      [JumpMapApp jumpToGoogleMapAppFromOriginLocation:locationCorrrdinate toDestinationLocation:targetLocation.coordinate];
                                  }
                                  else
                                  {
                                      [JumpMapApp jumpToGoogleMapAppToDestinationLocation:targetLocation.coordinate];
                                  }
                              }
                              else
                              {
                                  [JumpMapApp jumpToAppleMapAppFromOriginLocation:locationCorrrdinate toDestinationLocation:targetLocation.coordinate];
                              }
                          }
                      }];
}

#pragma mark - TableView List

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return HEIGH_OF_TABLEVIEW_CELL;
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
	AMOrderListCell *cell = (AMOrderListCell *)[tableView dequeueReusableCellWithIdentifier:@"AMOrderListCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMOrderListCell" owner:[AMOrderListCell class] options:nil];
		cell = (AMOrderListCell *)[nib objectAtIndex:0];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
    
	AMWorkOrder *workOrder = nil;
    
	if (isSearching) {
		workOrder = [self.searchResultList objectAtIndex:indexPath.row];
	}
	else
    {
		workOrder = [self.localWorkOrders objectAtIndex:indexPath.row];
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	CGSize titleSize = [workOrder.accountName boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: cell.label_Title.font } context:nil].size;
    
	NSString *strType = [NSString stringWithFormat:@"[%@]", MyLocal(workOrder.woType)];
    
	CGSize typeSize = [strType boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{ NSFontAttributeName: cell.label_Type.font } context:nil].size;
    
	CGFloat offsetType = 0.0;
    
	if (titleSize.width + typeSize.width > 258) {
		offsetType = 300 - typeSize.width;
	}
	else {
		offsetType = 40 + titleSize.width;
	}
    
	cell.label_Type.frame = CGRectMake(offsetType, 10, CGRectGetWidth(cell.label_Type.frame), CGRectGetHeight(cell.label_Type.frame));
    
	cell.label_Title.text = workOrder.accountName;
	cell.label_Type.text = strType;
	cell.label_Contact.text = workOrder.contact;
	cell.label_OpenSince.text = [AMUtilities daysFromDate:workOrder.createdDate ToDate:[NSDate date]];
	cell.label_Location.text = workOrder.workLocation;
	cell.label_Distance.text = [workOrder.nextDistance length] == 0 ? MyLocal(@"1 ft") : workOrder.nextDistance;
	cell.label_Time.text = [workOrder.nextTime length] == 0 ?  MyLocal(@"1 min"): workOrder.nextTime;
    
    UIImage *image = nil;
    
    if ([workOrder.priority isEqualToLocalizedString:kAMPRIORITY_STRING_CRITICAL]) {
        image = [UIImage imageNamed:@"alert-background.png"];
    }
    else if([workOrder.priority isEqualToLocalizedString:kAMPRIORITY_STRING_HIGH]) {
        image = [UIImage imageNamed:@"orange_priority.png"];
    }
    else if([workOrder.priority isEqualToLocalizedString:kAMPRIORITY_STRING_MEDIUM]) {
        image = [UIImage imageNamed:@"blue_priority.png"];
    }
    else {
        image = [UIImage imageNamed:@"green_priority.png"];
    }
    
    cell.label_Index.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cell.imageIndex.image = image;
    
    if (([workOrder.eventList count] > 1)) {
        cell.viewM.hidden = NO;
        cell.imageM.image = image;
    }
    else
    {
        cell.viewM.hidden = YES;
    }
    
    cell.btnMap.tag = indexPath.row;
    [cell.btnMap addTarget:self action:@selector(clickMapBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    NSTimeZone *aZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    cell.label_EstimationDuration.text = [NSString stringWithFormat:@"%@ - %@",[workOrder.estimatedTimeStart formattedDateWithFormat:@"HH:mm" timeZone:aZone],[workOrder.estimatedTimeEnd formattedDateWithFormat:@"HH:mm" timeZone:aZone]];
    
	if (selectedWorkOrderId) {
		if ([workOrder.woID isEqual:selectedWorkOrderId]) {
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
    
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	AMWorkOrder *info = nil;
    
	if (isSearching) {
		info = [searchResultList objectAtIndex:indexPath.row];
	}
	else {
		info = [localWorkOrders objectAtIndex:indexPath.row];
	}
    
    self.selectedWorkOrderId = info.woID;
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_CELL_SELECTED,
                              KEY_OF_INFO:info,
                              KEY_OF_FLAG:[NSNumber numberWithBool:NO]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self reloadData];
}

- (void)refreshSelectStatusWithWorkOrderId:(NSString *)aWorkOrderId
{
    if ([selectedWorkOrderId isEqualToString:aWorkOrderId]) {
        return;
    }
    self.selectedWorkOrderId = aWorkOrderId;
    
    if (isSearching) {
		[self searchEnable:NO];
        self.searchbarTitle.text = @"";
        if ([self.searchbarTitle isFirstResponder]) {
            [self.searchbarTitle resignFirstResponder];
        }
	}
    else
    {
        [self reloadData];
    }
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


- (void)refreshOrderList:(NSMutableArray *)aLocalWorkOrders;
{
    [self myRefreshTaskMethod:aLocalWorkOrders];
}

- (void)refreshWorkOrderStatus:(NSMutableArray *)aList
{
    for (AMWorkOrder *workOrder in localWorkOrders) {
        for (AMWorkOrder *info in aList) {
            if ([workOrder.woID isEqualToString:info.woID]) {
                workOrder.status = info.status;
                break;
            }
        }
    }
    
    [self reloadData];
}

- (void)refreshTimeAndDistanceBySingleRequest:(NSMutableArray *)aList
{
    for (AMWorkOrder *workOrder in localWorkOrders) {
        for (GoogleRouteInfo *info in aList) {
            if ([workOrder.woID isEqualToString:info.gId]) {
                workOrder.nextDistance = [info.gDistance.text length] != 0 ? info.gDistance.text : workOrder.nextDistance;
                workOrder.nextTime =  [info.gDuration.text length] != 0 ? info.gDuration.text : workOrder.nextTime;
                break;
            }
        }
    }
    
    [self reloadData];
}

- (void)refreshTimeAndDistanceByRouteRequest:(NSMutableArray *)aList
{
    for (AMWorkOrder *workOrder in localWorkOrders) {
        for (GooglePointInfo *info in aList) {
            if ([workOrder.woID isEqualToString:info.gId]) {
                workOrder.nextDistance = [info.gDistance.text length] != 0 ? info.gDistance.text : workOrder.nextDistance;
                workOrder.nextTime =  [info.gDuration.text length] != 0 ? info.gDuration.text : workOrder.nextTime;
                break;
            }
        }
    }
    
    [self reloadData];
}

- (void)myRefreshTaskMethod:(NSMutableArray *)aWorkOrders {
    
    for (AMWorkOrder *work in aWorkOrders) {
        if ([work.eventList count] > 1) {
            isCooperative = YES;
            break;
        }
    }
    
	self.localWorkOrders = [NSMutableArray arrayWithArray:aWorkOrders];
    [self sortLocalWorkOrderListBy:currentType];
    
    if (isSearching) {
        [self searchItemWithString:self.searchbarTitle.text inList:localWorkOrders];
    }
    
	[self reloadData];
}

- (void)searchItemWithString:(NSString *)aString inList:(NSMutableArray *)aList {
	if (!aList || [aList count] == 0) {
        
        if (searchResultList && [searchResultList count] > 0) {
            [searchResultList removeAllObjects];
        }
        
		return;
	}
    
	if (!aString) {
		aString = @"";
	}
    
	[searchOperationQueue cancelAllOperations];
    
	if (searchResultList && [searchResultList count] > 0) {
		[searchResultList removeAllObjects];
	}
    
	NSInvocationOperation *theOp = [[NSInvocationOperation alloc]
	                                initWithTarget:self
                                    selector:@selector(mySearchTaskMethod:)
                                    object:@{ @"String":aString, @"List":aList }];
    
	[searchOperationQueue addOperation:theOp];
}

- (void)mySearchTaskMethod:(id)Info {
	for (AMWorkOrder *order in[Info objectForKey:@"List"]) {
		if ([order.accountName rangeOfString:[Info objectForKey:@"String"] options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[searchResultList addObject:order];
		}
	}
    
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

#pragma mark - Searchbar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
	[self searchEnable:YES];
    //	searchBar.showsCancelButton = YES;
    
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_SEARCH_BAR_CHANGE,
                              KEY_OF_INFO:[NSNumber numberWithBool:YES]
                              };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
    
    [self reloadData];
	return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([searchBar.text length] == 0) {
        [self searchEnable:NO];
        [searchResultList removeAllObjects];
    }
	
    //	searchBar.showsCancelButton = NO;
    
    NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_SEARCH_BAR_CHANGE,
                              KEY_OF_INFO:[NSNumber numberWithBool:NO]
                              };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
    
    
    [self reloadData];
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self searchItemWithString:searchText inList:localWorkOrders];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[self searchEnable:NO];
	searchBar.text = @"";
	[searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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

- (void)searchEnable:(BOOL)isEnable {
	isSearching = isEnable;
	[self moveEnable:!isEnable];
	[self sortEnable:!isEnable];
    
	if (!isEnable) {
		[self reloadData];
	}
}

- (void)moveEnable:(BOOL)isEnable {
	self.btnMove.enabled = isEnable;
    
	if (isMoving) {
		isMoving = NO;
		[self.tableViewList setEditing:NO animated:YES];
		[self.btnMove setTitle:MyLocal(@"Move") forState:UIControlStateNormal];
		[self.btnMove setTitle:MyLocal(@"Move") forState:UIControlStateHighlighted];
	}
}

- (void)sortEnable:(BOOL)isEnable {
	self.btnSort.enabled = isEnable;
	if (isSorting) {
		[self closeSortViewWithAnimation:YES];
	}
}

#pragma mark - Sort

- (void)sortLocalWorkOrderListBy:(SortType)aType {
    //	if (currentType == aType) {
    //		return;
    //	}
    
	currentType = aType;
    isSortByDistance = NO;
    
	switch (aType) {
		case SortType_EstimatedTimeEnd:
		{
			NSArray *sortedArray = [self.localWorkOrders sortedArrayUsingComparator: ^NSComparisonResult (AMWorkOrder *workOrder1, AMWorkOrder *workOrder2) {
			    return [workOrder1.estimatedTimeStart compare:workOrder2.estimatedTimeStart];
			}];
            
			self.localWorkOrders = [NSMutableArray arrayWithArray:sortedArray];
		}
            break;
            
		case SortType_Priority:
		{
			NSArray *sortedArray = [self.localWorkOrders sortedArrayUsingComparator: ^NSComparisonResult (AMWorkOrder *workOrder1, AMWorkOrder *workOrder2) {
                if ([workOrder1.priority isEqualToLocalizedString:kAMPRIORITY_STRING_LOW]) {
                    return NSOrderedDescending;
                } else if ([workOrder2.priority isEqualToLocalizedString:kAMPRIORITY_STRING_LOW]) {
                    return NSOrderedAscending;
                }
			    return [workOrder1.priority compare:workOrder2.priority];
			}];
            
			self.localWorkOrders = [NSMutableArray arrayWithArray:sortedArray];
		}
            break;
            
		case SortType_Distance:
		{
			isSortByDistance = YES;
		}
            break;
            
		case SortType_Move:
		{
			self.localWorkOrders = [self sortWithMoveList:arrMoveList];
		}
            break;
            
		default:
		{
            
		}
            break;
	}
}

- (void)reloadData {
	MAIN ( ^{
	    if (isSearching) {
	        if (searchResultList) {
	            [self.tableViewList reloadData];
			}
		}
	    else {
	        if (localWorkOrders) {
	            [self.tableViewList reloadData];
			}
		}
	});
}

#pragma mark - Sort

- (void)refreshMoveList
{
    if ([arrMoveList count] > 0) {
        [arrMoveList removeAllObjects];
    }
    
    for (AMWorkOrder *workorder in self.localWorkOrders) {
        [arrMoveList addObject:workorder.woID];
    }
}

- (NSMutableArray *)sortWithMoveList:(NSMutableArray *)moveList
{
    if ([moveList count] == 0) {
        return localWorkOrders;
    }
    
    self.arrMoveList = moveList;
    
    NSMutableArray *arrResult = [NSMutableArray array];
    
    NSMutableArray *arrNew = [localWorkOrders mutableCopy];
    
    for (NSString *woId in moveList) {
        for (AMWorkOrder *workorder in self.localWorkOrders) {
            if ([workorder.woID isEqualToString:woId]) {
                [arrResult addObject:workorder];
                [arrNew removeObject:workorder];
                break;
            }
        }
    }
    
    if ([arrNew count] > 0) {
        [arrResult addObjectsFromArray:arrNew];
    }
    
    return arrResult;
}

@end
