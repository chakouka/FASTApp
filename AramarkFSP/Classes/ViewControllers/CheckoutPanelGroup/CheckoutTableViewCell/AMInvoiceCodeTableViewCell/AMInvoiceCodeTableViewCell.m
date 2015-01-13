//
//  AMInvoiceCodeTableViewCell.m
//  AramarkFSP
//
//  Created by FYH on 7/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceCodeTableViewCell.h"

@implementation AMInvoiceCodeTableViewCell

- (void)awakeFromNib
{
    self.labelTPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Price")];
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
