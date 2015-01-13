//
//  AMBaseTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/27/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMBaseTableViewCell.h"

@implementation AMBaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
