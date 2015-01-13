//
//  AMVerificationAddTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationAddTableViewCell.h"

@implementation AMVerificationAddTableViewCell

- (void)awakeFromNib
{
    self.labelTAsset.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset #")];
    self.labelTPointOfService.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Point of Service")];
    self.labelTSerial.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Serial #")];
    self.labelTLocation.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location")];
    self.labelTVerificationNotes.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verification Notes")];
    
    [self.btnAdd setTitle:MyLocal(@"ADD") forState:UIControlStateNormal];
    [self.btnAdd setTitle:MyLocal(@"ADD") forState:UIControlStateHighlighted];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
