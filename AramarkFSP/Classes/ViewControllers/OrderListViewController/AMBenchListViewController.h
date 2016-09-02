//
//  AMBENCHLISTVIEWCONTROLLER.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBenchListViewController : UIViewController
	<
	    UITableViewDelegate,
	    UITableViewDataSource,
        UIGestureRecognizerDelegate,//bkk 2/2/15 - item 000124
        UIPickerViewDelegate,
        UIPickerViewDataSource
	>
{
	BOOL show;
	BOOL isSorting;
    BOOL isSortByDistance;
	NSMutableArray *localWorkOrders;
    NSMutableArray *machineTypesArray;
}

@property (assign, nonatomic) BOOL show;
@property (assign, nonatomic) BOOL isSorting;
@property (assign, nonatomic) BOOL isSortByDistance;
@property (strong, nonatomic) NSMutableArray *localWorkOrders;
@property (strong, nonatomic) NSMutableArray *machineTypesArray;
@property (strong, nonatomic) NSMutableArray *arrMoveList;
@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UIView *viewSort;
@property (weak, nonatomic) IBOutlet UITableView *tableViewList;
@property (strong, nonatomic) NSString *selectedWorkOrderId;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbarTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelMachineType;

@property (weak, nonatomic) IBOutlet UIView *viewMainPanel;
@property (weak, nonatomic) IBOutlet UIView *viewLeftListPanel;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerMachineType;
@property (weak, nonatomic) IBOutlet UIView *viewPickerPanel;




- (void)deSelectRow;

- (void)refreshBenchList:(NSMutableArray *)aLocalWorkOrders;
- (void)refreshBenchMachineTypeList:(NSMutableArray *)aMachineTypes;

- (void)refreshSelectStatusWithWorkOrderId:(NSString *)aWorkOrderId;

- (void)showProgressHUD;

- (void)hiddenProgressHUD;

- (IBAction)btnMachineType:(id)sender;
@end
