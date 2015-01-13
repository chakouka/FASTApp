//
//  AMSummaryEmptyListCell.m
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/11/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSummaryEmptyListCell.h"

@implementation AMSummaryEmptyListCell

- (void)awakeFromNib
{
    self.lbl_noWOInformation.text = MyLocal(@"No Work Order");
    // Initialization code
    [self initFonts];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initFonts{
    [self.lbl_noWOInformation setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18]];
}

@end
