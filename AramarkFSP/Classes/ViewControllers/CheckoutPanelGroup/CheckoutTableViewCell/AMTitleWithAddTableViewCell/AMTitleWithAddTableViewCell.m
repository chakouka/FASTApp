//
//  AMTitleWithAddTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMTitleWithAddTableViewCell.h"

@implementation AMTitleWithAddTableViewCell

- (void)awakeFromNib
{
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData:(NSMutableDictionary *)dicInfo
{
    self.labelTitle.text = [dicInfo objectForKey:KEY_OF_ADD_HEAD_TITLE];
    self.labelAdd.text = [dicInfo objectForKey:KEY_OF_ADD_HEAD_INFO];
}

@end
