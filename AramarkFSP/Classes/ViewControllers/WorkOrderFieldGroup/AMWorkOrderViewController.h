//
//  AMWorkOrderViewController.h
//  AramarkFSP
//
//  Created by PwC on 4/28/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWorkOrder.h"
#import "AMSectionFooterView.h"
#import "AMSectionHeaderView.h"
#import "AMBaseTableViewCell.h"
#import "AMWOTabBaseViewController.h"
#import "AMDropdownTableViewCell.h"
#import "AMSectionHeaderAttachmentView.h"
#import "AMCheckBoxTableViewCell.h"

@protocol AMWorkOrderViewControllerDelegate <NSObject>

- (void)didSaveNewWorkOrder:(BOOL)success;

@end

@interface AMWorkOrderViewController : AMWOTabBaseViewController <UITableViewDataSource, UITableViewDelegate, AMSectionFooterViewDelegate, AMBaseTableViewCellDelegate, AMDropdownTableViewCellDelegate, AMSectionHeaderAttachmentViewDelegate, AMSectionHeaderViewDelegate, UICollectionViewDelegate, AMCheckBoxTableViewCellDelegate>
{
    WORKORDERType type;
}

@property(nonatomic,assign) WORKORDERType type;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *dataArr;
@property (strong, nonatomic) AMWorkOrder *assignedWorkOrder;
@property (weak, nonatomic) id<AMWorkOrderViewControllerDelegate> delegate;

- (id)initWithWorkOrder:(AMWorkOrder *)workOrder;

- (id)initWithNewWorkOrder:(AMWorkOrder *)byWorkOrder;

@end
