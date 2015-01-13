//
//  AMVerificationNewAddAssetTableViewCell.m
//  AramarkFSP
//
//  Created by PwC on 6/11/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationNewAddAssetTableViewCell.h"

@implementation AMVerificationNewAddAssetTableViewCell

- (void)awakeFromNib
{
    self.labelTAsset.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset #")];
    self.labelTPointOfService.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Point of Service")];
    self.labelTSerial.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Serial #")];
    self.labelTLocation.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location")];
    self.labelTVerificationNotes.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Verification Notes")];
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
