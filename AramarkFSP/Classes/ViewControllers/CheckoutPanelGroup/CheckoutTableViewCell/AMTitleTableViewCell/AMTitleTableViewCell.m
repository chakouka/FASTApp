//
//  AMTitleTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMTitleTableViewCell.h"

@implementation AMTitleTableViewCell

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
    self.labelTitle.text = MyLocal(@"WO #");
     [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
