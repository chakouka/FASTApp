//
//  AMContactTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMContactTableViewCell.h"

@implementation AMContactTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    for (UIView *subview in [self.contentView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([[subview subviews] count] > 0) {
            for (UIView *sv in [subview subviews]) {
                if ([sv isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)sv;
                    [label setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
                }
            }
        }
    }
    
    self.labelTContactRole.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact Role")];
    self.labelTContactPhone.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact Phone")];
    self.labelTContactEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact Email")];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAssignedContact:(AMContact *)assignedContact
{
    if (assignedContact == _assignedContact) {
        return;
    }
    _assignedContact = assignedContact;
    self.nameTextField.text = assignedContact.name;
    self.roleTextField.text = assignedContact.role;
    self.phoneTextField.text = assignedContact.phone;
    self.emailTextField.text = assignedContact.email;
}

@end
