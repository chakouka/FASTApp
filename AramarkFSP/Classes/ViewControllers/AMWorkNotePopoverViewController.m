//
//  AMWorkNotePopoverViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWorkNotePopoverViewController.h"

@interface AMWorkNotePopoverViewController ()

@end

@implementation AMWorkNotePopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.nameLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Work Order Notes")];
    [self.nameLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.valueTF setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    
    self.ownerFixedLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Owner")];
    [self.ownerFixedLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.ownerLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    
    self.descriptionFixedLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Description")];
    [self.descriptionFixedLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.descriptionText setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    
    self.repairCodeFixedLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Repair Code")];
    [self.repairCodeFixedLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.repairCodeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    
    self.completionDateFixedLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Completion Date")];
    [self.repairCodeFixedLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.repairCodeLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setWorkOrder:(AMWorkOrder *)workOrder
{
    _workOrder = workOrder;
    self.valueTF.text = workOrder.notes;
    
    self.ownerLabel.text = workOrder.ownerName;
    self.descriptionText.text = workOrder.workOrderDescription;
    self.repairCodeLabel.text = workOrder.repairCode;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:AMDATE_FORMATTER_STRING_STANDARD];
    self.completionDateLabel.text = [df stringFromDate:workOrder.actualTimeEnd];
}

@end
