//
//  AMPointsViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMPointsViewControllerDelegate;

@interface AMPointsViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>
{
	AMWorkOrder *workOrder;
}

@property (strong, nonatomic) NSMutableArray *arrPointsInfos;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) AMWorkOrder *workOrder;
@property (nonatomic, weak) id<AMPointsViewControllerDelegate> delegate;

- (void)setupDataSourceByInfo:(AMWorkOrder *)aWorkOrder;
- (IBAction)clickSubmitBtn:(id)sender;

@end

@protocol AMPointsViewControllerDelegate <NSObject>

- (void)didClickPointsViewControllerNextBtn;

@end
