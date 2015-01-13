//
//  AMInvoiceRepairTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceRepairTableViewCell.h"

@implementation AMInvoiceRepairTableViewCell

- (void)awakeFromNib
{
    self.labelTLaborCharge.text = MyLocal(@"Labor Charge");
    self.labelTHoursWorked.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Hours worked")];
    self.labelTHoursRate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Hours Rate")];
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
