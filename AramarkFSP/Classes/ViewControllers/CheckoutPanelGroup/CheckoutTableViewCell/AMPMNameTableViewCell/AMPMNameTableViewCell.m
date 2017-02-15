//
//  AMPMNameTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPMNameTableViewCell.h"

@implementation AMPMNameTableViewCell

- (void)awakeFromNib
{
    self.labelTQuantity.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Quantity")];
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

}

@end
