//
//  AMInvoiceRepairTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceRepairMaintenanceTableViewCell.h"

@implementation AMInvoiceRepairMaintenanceTableViewCell

- (void)awakeFromNib
{
    self.labelTPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"PRICE")];
    self.labelTMaintenanceType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Maintenance Type")];
    self.labelTMaintenanceFee.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Maintenance Fee")];
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
