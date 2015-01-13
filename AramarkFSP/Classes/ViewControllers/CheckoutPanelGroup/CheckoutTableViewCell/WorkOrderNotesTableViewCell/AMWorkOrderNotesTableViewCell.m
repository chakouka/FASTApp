//
//  AMWorkOrderNotesTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWorkOrderNotesTableViewCell.h"

@implementation AMWorkOrderNotesTableViewCell

- (void)awakeFromNib
{
    self.labelTWorkOrderNotes.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Work Order Notes")];
     [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData:(NSMutableDictionary *)dicInfo
{
    self.textViewWorkOrderNotes.text = [[dicInfo objectForKey:KEY_OF_WORKORDER_NOTES] length] == 0 ? TEXT_OF_WRITE_NOTE : [dicInfo objectForKey:KEY_OF_WORKORDER_NOTES];
}

@end
