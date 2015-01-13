//
//  AMRelatedWOHistoryTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOPopoverViewController.h"

@interface AMRelatedWOHistoryTableViewCell : UITableViewCell<AMWOPopoverViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *woNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *woNumberButton;
@property (weak, nonatomic) IBOutlet UILabel *woTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *repairCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *woDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *assignedToLabel;
@property (weak, nonatomic) IBOutlet UILabel *priorityLabel;




@property (nonatomic) AMRelatedWOType type;

@property (strong, nonatomic) AMWorkOrder *workOrder;

@end
