//
//  AMCaseHistoryCell.m
//  AramarkFSP
//
//  Created by PwC on 7/8/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMCaseHistoryCell.h"

@implementation AMCaseHistoryCell

- (void)awakeFromNib
{
    self.labelTType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Type")];
    self.labelTAccount.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Account")];
    self.labelTPos.text = [NSString stringWithFormat:@"%@:",MyLocal(@"PoS")];
    self.labelTSubject.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Subject")];
    self.labelTCase.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case #")];
    self.labelTStatus.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Status")];
    self.labelTDescription.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Description")];
    
    [self.btnModify setTitle:MyLocal(@"Clone") forState:UIControlStateHighlighted];
    [self.btnModify setTitle:MyLocal(@"Clone") forState:UIControlStateNormal];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
