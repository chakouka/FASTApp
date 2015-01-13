//
//  AMPendingWOCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWorkOrder.h"
#import "AMWOPopoverViewController.h"

@interface AMPendingWOCell : UITableViewCell<AMWOPopoverViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *workOrderTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *compliantCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *machineTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *posLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;
@property (weak, nonatomic) IBOutlet UIButton *woIDButton;

@property (nonatomic) AMRelatedWOType type;

@property (strong, nonatomic) AMWorkOrder *workOrder;
@end
