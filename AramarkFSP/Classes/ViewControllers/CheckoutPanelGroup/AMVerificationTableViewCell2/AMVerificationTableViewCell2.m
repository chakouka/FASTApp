//
//  AMVerificationTableViewCell2.m
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationTableViewCell2.h"
#import "AMAsset.h"

@implementation AMVerificationTableViewCell2

- (void)awakeFromNib
{
    self.labelTMachineType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Machine Type")];
    self.labelTVerivicationStatus.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verification Status")];
    self.labelTLocation.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location")];
    self.labelTVerifiedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verified Date")];
    self.labelTAsset.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset #")];
    self.labelTSerial.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Serial #")];
    self.labelTUpdateMachineType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Updated Machine #")];
    self.labelTUpdateSerial.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Updated Serial #")];
     [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData:(AMAsset *)aAsset
{
}

@end
