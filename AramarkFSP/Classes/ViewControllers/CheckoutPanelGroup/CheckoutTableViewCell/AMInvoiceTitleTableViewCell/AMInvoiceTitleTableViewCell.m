//
//  AMInvoiceTitleTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceTitleTableViewCell.h"

@implementation AMInvoiceTitleTableViewCell

- (void)awakeFromNib
{
    self.labelTCase.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case #")];
    self.labelTRequestedBy.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Requested By")];
    self.labelTCompletedBy.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Created Date")];
    self.labelTCaseDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Closed Date")];
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
