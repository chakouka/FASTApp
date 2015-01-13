//
//  AMRepairTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMRepairTableViewCell.h"

@implementation AMRepairTableViewCell

- (void)awakeFromNib
{
    self.labelTRepairCode.text = [NSString stringWithFormat:@"%@:",MyLocal(@"REPAIR CODE")];
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
//    if ([[dicInfo objectForKey:@"REPAIR_CODE"] isEqualToString:@"0"]) {
//        [self.btnRepairCode setImage:[UIImage imageNamed:@"type-drop-down"] forState:UIControlStateNormal];
//        [self.btnRepairCode setImage:[UIImage imageNamed:@"type-drop-down"] forState:UIControlStateHighlighted];
//    }
//    else
//    {
//        [self.btnRepairCode setImage:nil forState:UIControlStateNormal];
//        [self.btnRepairCode setImage:nil forState:UIControlStateHighlighted];
//        
//        [self.btnRepairCode setTitle:[dicInfo objectForKey:@"REPAIR_CODE"] forState:UIControlStateNormal];
//        [self.btnRepairCode setTitle:[dicInfo objectForKey:@"REPAIR_CODE"] forState:UIControlStateHighlighted];
//    }
}

@end
