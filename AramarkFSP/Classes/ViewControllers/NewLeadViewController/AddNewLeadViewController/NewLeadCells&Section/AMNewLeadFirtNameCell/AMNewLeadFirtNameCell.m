//
//  AMNewLeadFirtNameCell.m
//  AramarkFSP
//
//  Created by PwC on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewLeadFirtNameCell.h"

@implementation AMNewLeadFirtNameCell

- (void)awakeFromNib
{
    self.labelTFirstName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"First Name")];
    self.labelTCompanyName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Company Name")];
    self.labelTLastName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Last Name")];
    self.labelTCompanySize.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Company Size")];
    self.labelTPositionTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Position/ Title")];
    self.labelTCurrentProvider.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Current Provider")];
    self.labelTEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Email")];
    self.labelTReferingE.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Refering Employee")];
    self.labelTPhoneNumber.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Phone Number")];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
