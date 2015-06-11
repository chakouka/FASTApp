//
//  AMRelatedWOHistoryTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMRelatedWOHistoryTableViewCell.h"
#import "AMWorkNotePopoverViewController.h"


@interface AMRelatedWOHistoryTableViewCell(){
    UIPopoverController *popover;
    AMWOPopoverViewController *popoverVC;
    UIPopoverController *woNotePopover;
    AMWorkNotePopoverViewController *woNotePopoverVC;
}

@end

@implementation AMRelatedWOHistoryTableViewCell

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
    // Initialization code
//    [self.woNumberButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.woNumberLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.woTypeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.woDateLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.repairCodeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.assignedToLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.priorityLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell)];
    [self addGestureRecognizer:tapGesture];
    
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
//    [self.woNumberButton setTitle:workOrder.woNumber forState:UIControlStateNormal];
    self.woNumberLabel.text = workOrder.woNumber;
    self.woTypeLabel.text = MyLocal(workOrder.woType);
    self.repairCodeLabel.text = MyLocal(workOrder.repairCode);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:AMDATE_FORMATTER_STRING_STANDARD];
    self.woDateLabel.text = [df stringFromDate:workOrder.estimatedDate];
    self.assignedToLabel.text = workOrder.ownerName;
    self.priorityLabel.text = MyLocal(workOrder.priority);
}


#pragma mark - AMWOPopoverViewControllerDelegate
- (void)assignToMyselfTapped:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
//            [SVProgressHUD showErrorWithStatus:MyLocal(@"Fail to Assign") duration:3.0];
            [AMUtilities showAlertWithInfo:MyLocal(@"Fail to Assign")];

        } else {
//            [SVProgressHUD showSuccessWithStatus:MyLocal(@"Success to Assign")];
            [AMUtilities showAlertWithInfo:MyLocal(@"Success to Assign")];
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

#pragma mark - Target Action
- (void)tappedOnCell
{
    if (!woNotePopover) {
        woNotePopoverVC = [[AMWorkNotePopoverViewController alloc] initWithNibName:@"AMWorkNotePopoverViewController" bundle:nil];
        woNotePopover = [[UIPopoverController alloc] initWithContentViewController:woNotePopoverVC];
        [woNotePopover setPopoverContentSize:woNotePopoverVC.view.frame.size];
    }
    woNotePopoverVC.workOrder = self.workOrder;
    [woNotePopover presentPopoverFromRect:self.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

@end
