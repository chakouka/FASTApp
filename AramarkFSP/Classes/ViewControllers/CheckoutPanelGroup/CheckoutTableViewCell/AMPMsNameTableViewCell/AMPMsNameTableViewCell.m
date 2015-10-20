//
//  AMPMsNameTableViewCell.m
//  AramarkFSP
//
//  Created by bkendall on 10/14/15.
//  Copyright © 2015 PWC Inc. All rights reserved.
//

#import "AMPMsNameTableViewCell.h"

@implementation AMPMsNameTableViewCell

- (void)awakeFromNib
{
    self.labelTPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Quantity")];

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
    self.textFieldPMName.text = [[dicInfo objectForKey:@"FILTER_NAME"] length] == 0 ? TEXT_OF_NULL : [dicInfo objectForKey:@"FILTER_NAME"];
    self.textFieldPMQuantity.text = @"1";
    
}

@end
