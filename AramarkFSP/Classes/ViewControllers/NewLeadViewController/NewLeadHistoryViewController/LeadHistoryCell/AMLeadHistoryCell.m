//
//  AMLeadHistoryCell.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMLeadHistoryCell.h"

@implementation AMLeadHistoryCell

- (void)awakeFromNib
{
    self.labelTFirstName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"First Name")];
    self.labelTLastName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Last Name")];
    self.labelTTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Title")];
    self.labelTCreateDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Created Date")];
    self.labelTPhone.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Phone")];
    self.labelTEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Email")];
    self.labelTAddress.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Address")];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
