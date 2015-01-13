//
//  AMMaintenanceTypeTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMMaintenanceTypeTableViewCell.h"

@implementation AMMaintenanceTypeTableViewCell

- (void)awakeFromNib
{
    self.labelTMaintenanceType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Maintenance Type")];
    self.labelTMaintenanceFee.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Maintenance Fee")];
     [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark -
- (void)refreshData:(NSMutableDictionary *)dicInfo
{
    self.labelPreventiveMaintenance.text = [dicInfo objectForKey:KEY_OF_MAINTENANCE_TYPE];
    if ([[dicInfo objectForKey:KEY_OF_MAINTENANCE_FEE] integerValue] == 0 || ![dicInfo objectForKey:KEY_OF_MAINTENANCE_FEE]) {
        self.textFieldMaintenanceFee.text = TEXT_OF_NULL;
    }
    else
    {
        self.textFieldMaintenanceFee.text =  [NSString stringWithFormat:@"%@",[dicInfo objectForKey:KEY_OF_MAINTENANCE_FEE]];
    }
}



@end
