//
//  AMInvoiceRepairFilterNameCell.m
//  AramarkFSP
//
//  Created by PwC on 6/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceRepairFilterNameCell.h"

@implementation AMInvoiceRepairFilterNameCell

- (void)awakeFromNib
{
    self.labelTFilterName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Filter Name")];
    self.labelTFilterPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Filter Price")];
    self.labelTFilterQuantity.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Filter Quantity")];
    [AMUtilities refreshFontInView:self.contentView];
}

@end
