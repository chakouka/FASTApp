//
//  AMAMBENCHACTIVELISTVIEWCONTROLLER.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMBenchActiveListViewController : UIViewController
	<
	    UITableViewDelegate,
	    UITableViewDataSource,
        UIGestureRecognizerDelegate//bkk 2/2/15 - item 000124
	>
{
	BOOL show;
	BOOL isSorting;
    BOOL isSortByDistance;
	NSMutableArray *localWorkOrders;
}

@property (assign, nonatomic) BOOL show;
@property (assign, nonatomic) BOOL isSorting;
@property (assign, nonatomic) BOOL isSortByDistance;
@property (strong, nonatomic) NSMutableArray *localWorkOrders;
@property (strong, nonatomic) NSMutableArray *arrMoveList;
@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UIView *viewSort;
@property (weak, nonatomic) IBOutlet UITableView *tableViewList;
@property (strong, nonatomic) NSString *selectedWorkOrderId;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbarTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;

@property (weak, nonatomic) IBOutlet UIView *viewMainPanel;
@property (weak, nonatomic) IBOutlet UIView *viewLeftListPanel;




- (void)deSelectRow;

- (void)refreshActiveBenchList:(NSMutableArray *)aLocalWorkOrders;

- (void)refreshWorkOrderStatus:(NSMutableArray *)aList;

- (void)refreshTimeAndDistanceBySingleRequest:(NSMutableArray *)aList;

- (void)refreshTimeAndDistanceByRouteRequest:(NSMutableArray *)aList;

- (void)refreshSelectStatusWithWorkOrderId:(NSString *)aWorkOrderId;

- (NSMutableArray *)sortWithMoveList:(NSMutableArray *)moveList;

- (void)showProgressHUD;

- (void)hiddenProgressHUD;

@end
