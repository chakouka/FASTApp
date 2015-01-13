//
//  AMNearOrderListViewController.h
//  AramarkFSP
//
//  Created by FYH on 8/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMNearOrderListViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>
{
	BOOL show;
	BOOL isSorting;
	NSMutableArray *localWorkOrders;
}

@property (assign, nonatomic) BOOL show;
@property (assign, nonatomic) BOOL isSorting;
@property (strong, nonatomic) NSMutableArray *localWorkOrders;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;
@property (strong, nonatomic) NSString *selectedWorkOrderId;
@property (weak, nonatomic) IBOutlet UIButton *btnTitle;

@property (weak, nonatomic) IBOutlet UIView *viewSort;
@property (weak, nonatomic) IBOutlet UITableView *tableViewList;
@property (weak, nonatomic) IBOutlet UIButton *btnSort;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;

- (void)deSelectRow;
- (void)refreshOrderList:(NSMutableArray *)aLocalWorkOrders;
- (void)refreshSelectStatusWithWorkOrderId:(NSString *)aWorkOrderId;
- (void)refreshTimeAndDistanceBySingleRequest:(NSMutableArray *)aList;
- (void)removeWorkOrder:(NSString *)aWoId;
- (NSMutableArray *)sortWithMoveList:(NSMutableArray *)moveList;

- (IBAction)clickDistanceBtn:(UIButton *)sender;
- (IBAction)clickSortBtn:(UIButton *)sender;



@end
