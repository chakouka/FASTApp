//
//  AMAccountPendingWOCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 10/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAccountPendingWOCell.h"

@interface AMAccountPendingWOCell(){
    UIPopoverController *popover;
    AMWOPopoverViewController *popoverVC;
}

@end

@implementation AMAccountPendingWOCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self.workOrderTypeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.compliantCodeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.machineTypeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.posLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
//    [self.statusLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.priorityLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.woIDButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
- (IBAction)workOrderNumberTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!popover) {
        popoverVC = [[AMWOPopoverViewController alloc] initWithNibName:@"AMWOPopoverViewController" bundle:nil];
        popoverVC.popoverType = self.type;
        popoverVC.delegate = self;
        popover = [[UIPopoverController alloc] initWithContentViewController:popoverVC];
        [popover setPopoverContentSize:popoverVC.view.frame.size];
    }
    popoverVC.workOrder = self.workOrder;
    [popover presentPopoverFromRect:button.bounds inView:button permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)setWorkOrder:(AMWorkOrder *)workOrder
{
    _workOrder = workOrder;
    [self.woIDButton setTitle:workOrder.woNumber forState:UIControlStateNormal];
    self.workOrderTypeLabel.text = MyLocal(workOrder.woType);
    self.compliantCodeLabel.text = MyLocal(workOrder.complaintCode);
    self.machineTypeLabel.text = workOrder.machineTypeName;
    self.posLabel.text = workOrder.woPoS.name;
//    self.statusLabel.text = workOrder.status;
    self.priorityLabel.text = MyLocal(workOrder.priority);
}


#pragma AMWOPopoverViewControllerDelegate
- (void)assignToMyselfTapped:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [AMUtilities showAlertWithInfo:error.localizedDescription];
        } else {
            //            [SVProgressHUD showSuccessWithStatus:@"Success to Assign" duration:2.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_RELATED_WORKORDER_LIST object:nil];
        }
        [SVProgressHUD dismiss];
    });
}

- (void)dismissPopover
{
#ifdef TEST_FOR_SVPROGRESSHUD
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"%s", __FUNCTION__]];
#else
    [SVProgressHUD show];
#endif
    [popover dismissPopoverAnimated:YES];
}

@end
