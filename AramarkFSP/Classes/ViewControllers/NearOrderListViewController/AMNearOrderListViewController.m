//
//  AMNearOrderListViewController.m
//  AramarkFSP
//
//  Created by FYH on 8/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNearOrderListViewController.h"
#import "AMNearOrderListPMCell.h"
#import "AMNearOrderListFECell.h"
#import "AMNearOrderListAdminCell.h"
#import "AMWorkOrder.h"
#import "AMLogicCore.h"
#import "JumpMapApp.h"
#import "GoogleRouteInfo.h"
#import "AMPopoverSelectTableViewController.h"

#define HEIGH_OF_TABLEVIEW_ORIGINAL     88.0
#define HEIGH_OF_TABLEVIEW_CHANGED      (218.0 - 40)

#define HEIGH_OF_TABLEVIEW_CELL_PM         222.0
#define HEIGH_OF_TABLEVIEW_CELL_FE         230.0
#define HEIGH_OF_TABLEVIEW_CELL_ADMIN      254.0

#define kAMPRIORITY_STRING_CRITICAL @"Critical"
#define kAMPRIORITY_STRING_HIGH @"High"
#define kAMPRIORITY_STRING_MEDIUM @"Medium"
#define kAMPRIORITY_STRING_LOW @"Low"

typedef NS_ENUM (NSInteger, SortType) {
	SortType_Distance = 0,
	SortType_Priority,
    SortType_WoType
};

@interface AMNearOrderListViewController ()
<
UIPopoverControllerDelegate,
AMPopoverSelectTableViewControllerDelegate
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
    NSMutableArray *arrDistanceList;
    
	SortType currentType;
    CGRect originViewRect;
    
    NSMutableArray *arrMoveList;
    
    UIPopoverController *aPopoverVC;
    
     NSNumber *distance;
}

@property (strong, nonatomic) NSOperationQueue *searchOperationQueue;
@property (strong, nonatomic) NSOperationQueue *refreshOperationQueue;
@property (strong, nonatomic) NSMutableArray *searchResultList;
@property (strong, nonatomic) NSMutableArray *arrMoveList;
@property (strong, nonatomic)  NSNumber *distance;
@property (strong, nonatomic) NSMutableArray *arrDistanceList;
@property (nonatomic, strong) UIPopoverController *aPopoverVC;

@property (weak, nonatomic) IBOutlet UILabel *labelTSortBy;
@property (weak, nonatomic) IBOutlet UIButton *btnSortByWorkorderType;
@property (weak, nonatomic) IBOutlet UIButton *btnSortByDistance;

@end

@implementation AMNearOrderListViewController
@synthesize show;
@synthesize isSorting;
@synthesize localWorkOrders;
@synthesize tableViewMain;
@synthesize selectedWorkOrderId;
@synthesize searchOperationQueue;
@synthesize refreshOperationQueue;
@synthesize searchResultList;
@synthesize arrMoveList;
@synthesize arrDistanceList;
@synthesize aPopoverVC;
@synthesize distance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isSearching = NO;
        distance = @1;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     [self refreshFontInView:self.view];
    
    self.labelTSortBy.text = MyLocal(@"SORT BY");
    
    [self.btnSortByWorkorderType setTitle:MyLocal(@"SORT BY WORKORDER TYPE") forState:UIControlStateNormal];
    [self.btnSortByWorkorderType setTitle:MyLocal(@"SORT BY WORKORDER TYPE") forState:UIControlStateHighlighted];
    
    [self.btnSortByDistance setTitle:MyLocal(@"SORT BY DISTANCE") forState:UIControlStateNormal];
    [self.btnSortByDistance setTitle:MyLocal(@"SORT BY DISTANCE") forState:UIControlStateHighlighted];
    
   self.btnTitle.titleLabel.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger];
    
    self.labelSort.text = MyLocal(@"WORKORDER TYPE");
    [self.btnTitle setTitle:[NSString stringWithFormat:@"%@ : 1 %@",MyLocal(@"Current Distance"),MyLocal(@"Mile")] forState:UIControlStateNormal];
    [self.btnTitle setTitle:[NSString stringWithFormat:@"%@ : 1 %@",MyLocal(@"Current Distance"),MyLocal(@"Mile")] forState:UIControlStateHighlighted];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)deSelectRow
{
    
}

- (void)refreshOrderList:(NSMutableArray *)aLocalWorkOrders
{
    for (AMWorkOrder *work in aLocalWorkOrders) {
        if ([work.eventList count] > 1) {
            isCooperative = YES;
            break;
        }
    }
    
	self.localWorkOrders = [NSMutableArray arrayWithArray:aLocalWorkOrders];
    [self sortLocalWorkOrderListBy:SortType_WoType];
	self.labelSort.text = MyLocal(@"WORKORDER TYPE");
	[self reloadData];
}

- (void)refreshTimeAndDistanceBySingleRequest:(NSMutableArray *)aList
{
    self.arrDistanceList = aList;
    
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

- (NSNumber *)valueFrom:(AMWorkOrder *)aWorkorder
{
    for (GoogleRouteInfo *info in self.arrDistanceList) {
         if ([aWorkorder.woID isEqualToString:info.gId]) {
             return info.gDistance.value ? info.gDistance.value : @999999;
             break;
         }
    }
    
    return @999999;
}

-(NSString *)distanceFrom:(AMWorkOrder *)aWorkorder
{
    CLLocation *alocation = [[CLLocation alloc] initWithLatitude:[aWorkorder.latitude floatValue]  longitude:[aWorkorder.longitude floatValue]];
    CLLocation *current = [AMUtilities currentLocation];
    return [NSString stringWithFormat:@"%f",[alocation distanceFromLocation:current]/kMile];
}

- (void)refreshSelectStatusWithWorkOrderId:(NSString *)aWorkOrderId
{
    [self reloadData];
}

#pragma mark - TableView List

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AMWorkOrder *workOrder = nil;
    
	if (isSearching) {
		workOrder = [self.searchResultList objectAtIndex:indexPath.row];
	}
	else
    {
		workOrder = [self.localWorkOrders objectAtIndex:indexPath.row];
	}
    
    if ([workOrder.woType isEqualToLocalizedString:@"Preventative Maintenance"]) {
        return HEIGH_OF_TABLEVIEW_CELL_PM;
    }
    else if ([workOrder.woType isEqualToLocalizedString:@"Filter Exchange"])
    {
        return HEIGH_OF_TABLEVIEW_CELL_FE;
    } else {
        return HEIGH_OF_TABLEVIEW_CELL_ADMIN;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (isSearching) {
		return [searchResultList count];
	}
	else {
		return [localWorkOrders count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AMWorkOrder *workOrder = nil;
    
	if (isSearching) {
		workOrder = [self.searchResultList objectAtIndex:indexPath.row];
	}
	else
    {
		workOrder = [self.localWorkOrders objectAtIndex:indexPath.row];
	}
    
	
    
    if ([workOrder.woType isEqualToLocalizedString:@"Preventative Maintenance"]) {
        
        AMNearOrderListPMCell *cell = (AMNearOrderListPMCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNearOrderListPMCell"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNearOrderListPMCell" owner:[AMNearOrderListPMCell class] options:nil];
            cell = (AMNearOrderListPMCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        
        cell.labelMachineType.text = workOrder.machineTypeName;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *strType = [NSString stringWithFormat:@"[%@]", MyLocal(workOrder.woType)];
        
        cell.label_Title.text = workOrder.accountName;
        cell.label_Type.text = strType;
        cell.label_Distance.text = workOrder.nextDistance;
        cell.label_Time.text = workOrder.nextTime;
        cell.labelWONumber.text = workOrder.woNumber;
        cell.label_ContactName.text = workOrder.contact;
        cell.label_Address.text = workOrder.workLocation;   
        NSTimeZone *aZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
        cell.labelEstimatedWorkDate.text = [workOrder.estimatedDate formattedDateWithFormat:@"yyyy.MM.dd" timeZone:aZone];
        
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
        
        cell.label_Index.text = [NSString stringWithFormat:@"%d", ((int)indexPath.row + 1)];
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
    else if ([workOrder.woType isEqualToLocalizedString:@"Filter Exchange"])
    {
        AMNearOrderListFECell *cell = (AMNearOrderListFECell *)[tableView dequeueReusableCellWithIdentifier:@"AMNearOrderListFECell"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNearOrderListFECell" owner:[AMNearOrderListFECell class] options:nil];
            cell = (AMNearOrderListFECell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        
        cell.labelFilterType.text = workOrder.filterTypeName;
        cell.labelFilterNumber.text = [NSString stringWithFormat:@"%@",workOrder.filterCount];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *strType = [NSString stringWithFormat:@"[%@]", MyLocal(workOrder.woType)];
        
        cell.label_Title.text = workOrder.accountName;
        cell.label_Type.text = strType;
        cell.label_Distance.text = workOrder.nextDistance;
        cell.label_Time.text = workOrder.nextTime;
        cell.labelWONumber.text = workOrder.woNumber;
        cell.labelContactName.text = workOrder.contact == nil ? @"NONE" : workOrder.contact;
        cell.labelLocation.text = workOrder.workLocation;
        
        NSTimeZone *aZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
        cell.labelEstimatedWorkDate.text = [workOrder.estimatedDate formattedDateWithFormat:@"yyyy.MM.dd" timeZone:aZone];
        
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
        
        cell.label_Index.text = [NSString stringWithFormat:@"%d", ((int)indexPath.row + 1)];
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

    } else {
        //admin cell type
        AMNearOrderListAdminCell *cell = (AMNearOrderListAdminCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNearOrderListAdminCell"];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNearOrderListAdminCell" owner:[AMNearOrderListAdminCell class] options:nil];
            cell = (AMNearOrderListAdminCell *)[nib objectAtIndex:0];
            cell.contentView.backgroundColor = [UIColor clearColor];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        NSString *strType = [NSString stringWithFormat:@"[%@]", MyLocal(workOrder.woType)];
        
        cell.label_Title.text = workOrder.accountName;
        cell.label_Type.text = MyLocal(strType);
        cell.label_Distance.text = workOrder.nextDistance;
        cell.label_Time.text = workOrder.nextTime;
        cell.labelWONumber.text = workOrder.woNumber;
        cell.label_ContactName.text = workOrder.contact == nil ? @"NONE" : workOrder.contact;
        cell.label_Address.text = workOrder.workLocation;
        cell.labelComplaintCode.text = MyLocal(workOrder.complaintCode);
        cell.labelSubject.text = workOrder.subject;
        
        NSTimeZone *aZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
        cell.labelEstimatedWorkDate.text = [workOrder.estimatedDate formattedDateWithFormat:@"yyyy.MM.dd" timeZone:aZone];
        
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
        
        cell.label_Index.text = [NSString stringWithFormat:@"%d", (int)(indexPath.row + 1)];
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
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self reloadData];
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

- (void)reloadData {
	MAIN ( ^{
	    if (isSearching) {
	        if (searchResultList) {
	            [self.tableViewMain reloadData];
			}
		}
	    else {
	        if (localWorkOrders) {
	            [self.tableViewMain reloadData];
			}
		}
	});
}

- (void)removeWorkOrder:(NSString *)aWoId
{
    NSMutableArray *arrTemp = [self.localWorkOrders mutableCopy];
    for (AMWorkOrder *wo in arrTemp) {
        if ([wo.woID isEqualToString:aWoId]) {
            [self.localWorkOrders removeObject:wo];
            break;
        }
    }
    
    [self reloadData];
}

#pragma mark -

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
	if (aVerificationStatusTableViewController.tag == 1000) {
        
		NSString *strTitle = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        distance = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
        [self.btnTitle setTitle:[NSString stringWithFormat:@"%@ : %@",MyLocal(@"Current Distance"),strTitle] forState:UIControlStateNormal];
        [self.btnTitle setTitle:[NSString stringWithFormat:@"%@ : %@",MyLocal(@"Current Distance"),strTitle] forState:UIControlStateHighlighted];
        
        NSDictionary *dicInfo = @{
                                  KEY_OF_TYPE:TYPE_OF_RADIUS_SELECTED,
                                  KEY_OF_INFO:distance
                                  };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER object:dicInfo];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
	}
}

#pragma mark -

- (IBAction)clickDistanceBtn:(UIButton *)sender {
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = 1000;

    popView.arrInfos = [NSMutableArray arrayWithObjects:
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"0.1 Mile", kAMPOPOVER_DICTIONARY_KEY_DATA : @0.1},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"0.5 Mile", kAMPOPOVER_DICTIONARY_KEY_DATA : @0.5},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"1 Mile", kAMPOPOVER_DICTIONARY_KEY_DATA : @1},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"2 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @2},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"3 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @3},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"4 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @4},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"5 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @5},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"10 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @10},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"15 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @15},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"20 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @20},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"30 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @30},
                        @{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"50 Miles", kAMPOPOVER_DICTIONARY_KEY_DATA : @50},
                        nil];
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame) + 100, CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];

}

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

#pragma mark -

- (IBAction)clickSortBtn:(UIButton *)sender {
	if (isSorting) {
		[self closeSortViewWithAnimation:YES];
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
                                  }
                              }];
		}
		else {
			[self openSortViewWithAnimation:YES];
		}
	}
}

- (IBAction)clickSortByWorkorderType:(UIButton *)sender {
	[self sortLocalWorkOrderListBy:SortType_WoType];
	self.labelSort.text = MyLocal(@"WORKORDER TYPE");
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                              KEY_OF_INFO:self.localWorkOrders
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self clickSortBtn:nil];
    [self reloadData];
}

- (IBAction)clickSortByDistanceBtn:(UIButton *)sender {
	[self sortLocalWorkOrderListBy:SortType_Distance];
	self.labelSort.text = @"DISTANCE";
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
                              KEY_OF_INFO:self.localWorkOrders,
                              KEY_OF_FLAG:[NSNumber numberWithBool:YES]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMNEARMEORDERLISTVIEWCONTROLLER object:dicInfo];
    
	[self clickSortBtn:nil];
    
    [self reloadData];
}

#pragma mark -

#pragma mark - Sort

- (void)sortLocalWorkOrderListBy:(SortType)aType {
    
	currentType = aType;
    
	switch (aType) {
		case SortType_WoType:
		{
			NSArray *sortedArray = [self.localWorkOrders sortedArrayUsingComparator: ^NSComparisonResult (AMWorkOrder *workOrder1, AMWorkOrder *workOrder2) {
			    return [workOrder1.woType compare:workOrder2.woType];
			}];
            
			self.localWorkOrders = [NSMutableArray arrayWithArray:sortedArray];
		}
            break;
            
		case SortType_Distance:
		{
            NSArray *sortedArray = [self.localWorkOrders sortedArrayUsingComparator: ^NSComparisonResult (AMWorkOrder *workOrder1, AMWorkOrder *workOrder2) {
			    return [[self valueFrom:workOrder1] compare:[self valueFrom:workOrder2]];
			}];
            
			self.localWorkOrders = [NSMutableArray arrayWithArray:sortedArray];
		}
            break;
    
		default:
		{
		}
            break;
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

@end
