//
//  AMVerificationTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationTableViewCell.h"
#import "AMAsset.h"

@implementation AMVerificationTableViewCell

- (void)awakeFromNib
{
    self.labelTMachineType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Machine Type")];
    self.labelTVerificationStatus.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verification Status")];
    self.labelTLocation.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location")];
    self.labelTVerifiedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verified Date")];
    self.labelTAsset.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset #")];
    self.labelTSerial.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Serial #")];
    self.labelTUpdatedAsset.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Updated Asset #")];
    self.labelTUpdatedSerial.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Updated Serial #")];
    self.labelTVerificationNotes.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verification Notes")];
    
    [self.btnUpdateDate setTitle:MyLocal(@"VERIFY EQUIPMENT") forState:UIControlStateNormal];
    [self.btnUpdateDate setTitle:MyLocal(@"VERIFY EQUIPMENT") forState:UIControlStateHighlighted];
    
     [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)enableEdit:(BOOL)enable
{
    self.contentView.userInteractionEnabled = enable;
}

@end
