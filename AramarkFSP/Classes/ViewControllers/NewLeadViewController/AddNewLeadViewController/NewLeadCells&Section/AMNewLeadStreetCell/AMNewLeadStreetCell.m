//
//  AMNewLeadStreetCell.m
//  AramarkFSP
//
//  Created by PwC on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewLeadStreetCell.h"

@implementation AMNewLeadStreetCell

- (void)awakeFromNib
{
    self.labelTAddress.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Address")];
    self.labelTState.text = [NSString stringWithFormat:@"%@:",MyLocal(@"State")];
    self.labelTAddressLine2.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Address Line 2")];
    self.labelTZipCode.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Zip Code")];
    self.labelTCity.text = [NSString stringWithFormat:@"%@:",MyLocal(@"City")];
    self.labelTCountry.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Country")];
    self.labelTComment.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Comments")];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
