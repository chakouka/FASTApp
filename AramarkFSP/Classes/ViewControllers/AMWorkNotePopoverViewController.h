//
//  AMWorkNotePopoverViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWorkOrder.h"

@interface AMWorkNotePopoverViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *valueTF;
@property (weak, nonatomic) IBOutlet UILabel *descriptionFixedLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UILabel *repairCodeFixedLabel;
@property (weak, nonatomic) IBOutlet UILabel *repairCodeLabel;
@property (strong, nonatomic) AMWorkOrder *workOrder;
@end
