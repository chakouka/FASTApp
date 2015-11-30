//
//  AMNewContactCell.m
//  AramarkFSP
//
//  Created by bkendall on 3/25/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

#import "AMNewContactCell.h"

@implementation AMNewContactCell

- (void)awakeFromNib
{

    self.labelTChooseRoles.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Choose Role")];
    self.labelTFirstName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"First Name")];
    self.labelTLastName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Last Name")];
    self.labelTEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Email")];
    self.labelTTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Title")];
    self.labelTPhone.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Phone")];
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
