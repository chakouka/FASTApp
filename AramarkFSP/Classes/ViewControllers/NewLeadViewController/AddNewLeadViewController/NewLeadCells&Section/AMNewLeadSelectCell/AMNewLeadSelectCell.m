//
//  AMNewLeadSelectCell.m
//  AramarkFSP
//
//  Created by PwC on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewLeadSelectCell.h"

@implementation AMNewLeadSelectCell

- (void)awakeFromNib
{
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
