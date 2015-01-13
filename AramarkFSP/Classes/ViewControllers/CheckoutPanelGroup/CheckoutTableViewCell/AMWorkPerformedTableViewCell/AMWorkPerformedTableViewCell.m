//
//  AMWorkPerformedTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWorkPerformedTableViewCell.h"

@implementation AMWorkPerformedTableViewCell

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

//[dicWorkPerformed setObject:@"0" forKey:KEY_OF_HOURS_WORKED];
//[dicWorkPerformed setObject:@"0" forKey:KEY_OF_HOURS_RATE];
#pragma mark -
- (void)refreshData:(NSMutableDictionary *)dicInfo
{
    self.labelWorkPerformed.text = [NSString stringWithFormat:@"%@",[dicInfo objectForKey:KEY_OF_WORK_PERFORMED]];

    if ([[dicInfo objectForKey:KEY_OF_HOURS_WORKED] length] == 0 || [[dicInfo objectForKey:KEY_OF_HOURS_WORKED] isEqualToString:@"0"]) {
        [self.btnHoursWorked setImage:[UIImage imageNamed:@"type-drop-down"] forState:UIControlStateNormal];
        [self.btnHoursWorked setImage:[UIImage imageNamed:@"type-drop-down"] forState:UIControlStateHighlighted];
        self.textFieldHoursRate.text = TEXT_OF_NULL;
    }
    else
    {
        [self.btnHoursWorked setImage:nil forState:UIControlStateNormal];
        [self.btnHoursWorked setImage:nil forState:UIControlStateHighlighted];
        
        [self.btnHoursWorked setTitle:[dicInfo objectForKey:KEY_OF_HOURS_WORKED] forState:UIControlStateNormal];
        [self.btnHoursWorked setTitle:[dicInfo objectForKey:KEY_OF_HOURS_WORKED] forState:UIControlStateHighlighted];
        self.textFieldHoursRate.text = [[dicInfo objectForKey:KEY_OF_HOURS_RATE] length] == 0 ? TEXT_OF_NULL : [dicInfo objectForKey:KEY_OF_HOURS_RATE];
        
        self.textFieldHoursRate.enabled = [[dicInfo objectForKey:KEY_OF_HOURS_RATE] isEqualToString:@"0"];
    }
}

@end
