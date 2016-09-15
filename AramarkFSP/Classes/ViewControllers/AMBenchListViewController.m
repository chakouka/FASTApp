//
//  AMBENCHLISTVIEWCONTROLLER.m
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

#import "AMBenchListViewController.h"
#import "AMBenchListcell.h"
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

NSMutableArray *machineTypesArray;

@interface AMBenchListViewController ()
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

@implementation AMBenchListViewController
@synthesize isSortByDistance;
@synthesize selectedWorkOrderId;
@synthesize show;
@synthesize localWorkOrders;
@synthesize machineTypesArray;
@synthesize isSorting;
@synthesize searchOperationQueue;
@synthesize refreshOperationQueue;
@synthesize searchResultList;
@synthesize arrMoveList;
@synthesize pickerMachineType;

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
    
    self.pickerMachineType = [[UIPickerView alloc] init];
    self.pickerMachineType.delegate = self;
    self.pickerMachineType.dataSource = self;
    [self.pickerMachineType setUserInteractionEnabled:NO];
    
    [self.viewPickerPanel addSubview:self.pickerMachineType];
    [[self.viewPickerPanel superview] bringSubviewToFront:self.viewPickerPanel];

    self.searchbarTitle.placeholder = MyLocal(@"SEARCH ASSET or Serial No.");
    
    //bkk 2/2/15 - item 000124
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 2.0; //seconds
    lpgr.delegate = self;
    [self.tableViewList addGestureRecognizer:lpgr];
}

- (void)viewWillAppear:(BOOL)animated
{

    [self searchEnable:NO];
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
	AMBenchListCell *cell = (AMBenchListCell *)[tableView dequeueReusableCellWithIdentifier:@"AMBenchListCell"];
	if (cell == nil) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMBenchListCell" owner:[AMBenchListCell class] options:nil];
		cell = (AMBenchListCell *)[nib objectAtIndex:0];
		cell.contentView.backgroundColor = [UIColor clearColor];
	}
    
	NSDictionary *workOrder = nil;
    
	if (isSearching) {
		workOrder = [self.searchResultList objectAtIndex:indexPath.row];
	}
	else
    {
		workOrder = [self.localWorkOrders objectAtIndex:indexPath.row];
	}
    
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

    
    cell.label_AssetNumber.text = [workOrder valueForKeyWithNullToNil: @"Machine_Number__c"];
    cell.label_SerialNumber.text = [workOrder valueForKeyWithNullToNil: @"SerialNumber"];
	cell.label_MachineGroup.text = [workOrder valueForKeyWithNullToNil:@"Machine_Number__c"];
    cell.label_MachineType.text = [[((NSArray *)[[workOrder valueForKey:@"Work_Orders__r"] objectForKey:@"records"])[0] valueForKeyWithNullToNil:@"Machine_Type__r"] valueForKeyWithNullToNil:@"Name"];
    
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
    
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *info = nil;
    
	if (isSearching) {
		info = [searchResultList objectAtIndex:indexPath.row];
	}
	else {
		info = [localWorkOrders objectAtIndex:indexPath.row];
	}
    
    self.selectedWorkOrderId = [info valueForKey:@"Id"];
    
	NSDictionary *dicInfo = @{
                              KEY_OF_TYPE:TYPE_OF_CELL_SELECTED,
                              KEY_OF_INFO:info,
                              KEY_OF_FLAG:[NSNumber numberWithBool:NO]
                              };
    
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMBENCHLISTVIEWCONTROLLER object:dicInfo];
    
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

- (void)refreshBenchMachineTypeList:(NSMutableArray *)aMachineTypes
{
    self.machineTypesArray = aMachineTypes;
    
    [self myRefreshBenchMachineTypeMethod:aMachineTypes];
    [self.pickerMachineType reloadAllComponents];
}
- (void)refreshBenchList:(NSMutableArray *)aLocalBenchWorkOrders;
{
    [self myRefreshBenchTaskMethod:aLocalBenchWorkOrders];
}

- (void)myRefreshBenchTaskMethod:(NSMutableArray *)array {
    self.localWorkOrders = [NSMutableArray arrayWithArray:array];

    if (isSearching) {
        [self searchItemWithString:self.searchbarTitle.text inList:localWorkOrders];
    }
    
    [self reloadData];
}

- (void)myRefreshBenchMachineTypeMethod:(NSMutableArray *)array {
   
    if (isSearching) {
        [self searchItemWithString:self.searchbarTitle.text inList:localWorkOrders];
    }
    
    

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

    NSString *machineTypeName;
	for (NSDictionary *order in [Info objectForKey:@"List"]) {
        machineTypeName = [[((NSArray *)[[order valueForKey:@"Work_Orders__r"] objectForKey:@"records"])[0] valueForKeyWithNullToNil:@"Machine_Type__r"] valueForKeyWithNullToNil:@"Name"];
		if ( ([[order valueForKeyWithNullToNil:@"Machine_Number__c"] rangeOfString:[Info objectForKey:@"String"] options:NSCaseInsensitiveSearch].location != NSNotFound)
            || ([[order valueForKeyWithNullToNil:@"SerialNumber"] rangeOfString:[Info objectForKey:@"String"] options:NSCaseInsensitiveSearch].location != NSNotFound)
            
            )
        {
            //modify Id part in last one to also factor in the Machine Type
            if ([_labelMachineType.text isEqualToString:@"Machine Type"])
            {
                //just add it.  don't factor in the machine type
                [searchResultList addObject:order];
            } else {
                if ([machineTypeName rangeOfString:_labelMachineType.text options:NSCaseInsensitiveSearch].location != NSNotFound)
                {
                    //in this case, only add it if the machine type is found.
                    [searchResultList addObject:order];
                }
            }
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
    if (searchText.length > 0) {
        [self searchEnable:YES];
        [self searchItemWithString:searchText inList:localWorkOrders];
    } else {
        [self searchEnable:NO];
        [self reloadData];
    }
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
	if (!isEnable) {
		[self reloadData];
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


#pragma mark - Gesture delegate //bkk 2/2/15 - item 000124
//-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
//{
//    CGPoint p = [gestureRecognizer locationInView:self.tableViewList];
//    
//    NSIndexPath *indexPath = [self.tableViewList indexPathForRowAtPoint:p];
//    if (indexPath == nil) {
//        NSLog(@"long press on table view but not on a row");
//    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
//        NSArray *todayCheckInWOList = [[AMDBManager sharedInstance] getSelfOwnedTodayCheckInWorkOrders];
//        if (todayCheckInWOList.count == 0)
//        {
//            [self.tableViewList selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
//            [self tableView:self.tableViewList didSelectRowAtIndexPath:indexPath];
//            [self showCheckInAlert:self.localWorkOrders[indexPath.row]];
//        }
//        NSLog(@"long press on table view at row %d", indexPath.row);
//    } else {
//        NSLog(@"gestureRecognizer.state = %d", gestureRecognizer.state);
//    }
//}
#pragma mark - CheckIn //bkk 2/2/15 - item 000124
//- (void)showCheckInAlert:(AMWorkOrder *)workorder {
//    [UIAlertView showWithTitle:@""
//                       message:MyLocal(@"Are you sure you want to Check In ?")
//             cancelButtonTitle:MyLocal(@"NO")
//             otherButtonTitles:@[MyLocal(@"YES")]
//                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
//                          if (buttonIndex == [alertView cancelButtonIndex]) {
//                              return;
//                          }
//                          else
//                          {
//                              [[AMLogicCore sharedInstance] checkInWorkOrder:workorder completionBlock:^(NSInteger type, NSError *error) {
//                                  if (error) {
//                                      [AMUtilities showAlertWithInfo:[error localizedDescription]];
//                                      return ;
//                                  }
//                                  NSDictionary *dicInfo = @{
//                                                            KEY_OF_TYPE:TYPE_OF_WORK_ORDER_LIST_CHANGE,
//                                                            KEY_OF_INFO:self.localWorkOrders,
//                                                            KEY_OF_FLAG:[NSNumber numberWithBool:NO]
//                                                            };
//                                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMORDERLISTVIEWCONTROLLER object:dicInfo];
//
//                              }];
//                              
//                          }
//                      }];
//}



#pragma mark - Layout Change

- (void)changeLeftListPanelHidden:(BOOL)isHidden animation:(BOOL)aAnimation {
    
    self.show = !isHidden;
    
 //   [self changeRouteViewWithPosition:PositionRouteView_Full animation:NO];
    
    [UIView animateWithDuration:(aAnimation ? DEFAULT_DURATION : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations: ^{
                         if (isHidden) {
                             [self.viewLeftListPanel setFrame:CGRectMake(-300,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             
//                             [self changeRouteViewWithPosition:PositionRouteView_Full animation:aAnimation];
                             
//                             [self.nearOrderListVC viewWillDisappear:YES];
                         }
                         else {
                             [self.viewLeftListPanel setFrame:CGRectMake(0,
                                                                         0,
                                                                         CGRectGetWidth(self.viewLeftListPanel.frame),
                                                                         CGRectGetHeight(self.viewLeftListPanel.frame))];
                             
//                             [self changeRouteViewWithPosition:PositionRouteView_Half animation:aAnimation];
                             
//                             [self.nearOrderListVC viewWillAppear:YES];
                         }
                     }
     
                     completion: ^(BOOL finished)
     {
//         self.nearOrderListVC.show = !isHidden;
     }];
}

- (IBAction)btnMachineType:(id)sender
{
    self.viewPickerPanel.hidden = !self.viewPickerPanel.isHidden;

    if (self.viewPickerPanel.hidden)
    {
        _labelMachineType.text = self.machineTypesArray[[self.pickerMachineType selectedRowInComponent:0]];

        if([_labelMachineType.text isEqualToString:@"Machine Type"])
        {
            [self searchEnable: NO];
        } else {
            [self searchEnable: YES];
            [self searchItemWithString:_labelMachineType.text inList:self.localWorkOrders];
        }
    }
    [self.pickerMachineType setUserInteractionEnabled:!self.viewPickerPanel.isHidden];
    [self.pickerMachineType reloadAllComponents];

}

#pragma mark - Picker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.machineTypesArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *strPickerSelection;
    
    strPickerSelection = self.machineTypesArray[row];
//    _labelMachineType.text = strPickerSelection;
    
    return strPickerSelection;
}

@end
