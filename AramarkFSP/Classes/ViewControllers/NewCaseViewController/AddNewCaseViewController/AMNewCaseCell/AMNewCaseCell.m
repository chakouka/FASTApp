//
//  AMNewCaseCell.m
//  AramarkFSP
//
//  Created by PwC on 6/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewCaseCell.h"

@implementation AMNewCaseCell

- (void)awakeFromNib
{
    self.labelTCaseRecordType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case Record Type")];
    self.labelTType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Type")];
    self.labelTAccount.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Account")];
    self.labelTMeiCustomer.text = [NSString stringWithFormat:@"%@:",MyLocal(@"MEI Customer #")];
    self.labelTPointOfService.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Point of Service")];
    self.labelTPriority.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Priority")];
    self.labelTSubject.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Subject")];
    self.labelTChooseContact.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Choose Contact")];
    self.labelTOr.text = MyLocal(@"OR");
    self.labelTFirstName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"First Name")];
    self.labelTLastName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Last Name")];
    self.labelTEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Email")];
    self.labelTCaseDescription.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case Description")];
    self.labelTChooseAsset.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Choose Asset")];
    self.labelTOr2.text = MyLocal(@"OR");
    self.labelTAssetNo.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset #")];
    self.labelTSerialNo.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Serial #")];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
