//
//  AMFilterNameTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMFilterNameTableViewCell.h"

@implementation AMFilterNameTableViewCell

- (void)awakeFromNib
{
    self.labelTPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Price")];
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
    self.textFieldFilterName.text = [[dicInfo objectForKey:@"FILTER_NAME"] length] == 0 ? TEXT_OF_NULL : [dicInfo objectForKey:@"FILTER_NAME"];
    self.textFieldFilterPrice.text = [[dicInfo objectForKey:@"FILTER_PRICE"] length] == 0 ? TEXT_OF_NULL : [dicInfo objectForKey:@"FILTER_PRICE"];
    self.textFieldQuantity.text = [[dicInfo objectForKey:KEY_OF_FILTER_QUANTITY] length] == 0 ? TEXT_OF_NULL : [dicInfo objectForKey:KEY_OF_FILTER_QUANTITY];
}

@end
