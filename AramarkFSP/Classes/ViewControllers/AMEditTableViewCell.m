//
//  AMCheckboxTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMEditTableViewCell.h"

@interface AMEditTableViewCell()

@end

@implementation AMEditTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.isEditingMode = NO;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self.labelCellTitle setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.textFieldCellValue setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.textFieldCellValue setEnabled:NO];
    self.textFieldCellValue.delegate = self;
    self.textFieldCellValue.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setConfiguredCell:(AMConfiguredCell *)configuredCell
{
    [super setConfiguredCell:configuredCell];
    self.labelCellTitle.text = configuredCell.cellTitle;
    self.textFieldCellValue.text = configuredCell.cellValue;
    [self.buttonEdit setHidden:!configuredCell.isEditable];
    self.textFieldCellValue.layer.borderWidth = 0;
    [self.textFieldCellValue setEnabled:NO];
}

- (IBAction)editButtonTapped:(id)sender {
    if (self.isEditingMode) {
        self.textFieldCellValue.layer.borderWidth = 0;
        [self.textFieldCellValue setEnabled:NO];
        self.isEditingMode = NO;
    } else {
        self.textFieldCellValue.layer.borderWidth = 1;
        [self.textFieldCellValue setEnabled:YES];
        self.isEditingMode = YES;
    }
}

#pragma UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldStartEditing:withCellObj:)]){
        [self.delegate textFieldStartEditing:textField withCellObj:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldEndEditing:withCellObj:)]) {
        [self.delegate textFieldEndEditing:textField withCellObj:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:withCellObj:)]) {
        shouldChange = [self.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string withCellObj:self];
    }
    return shouldChange;
}

@end
