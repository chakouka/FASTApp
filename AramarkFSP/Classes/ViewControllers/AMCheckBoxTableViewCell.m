//
//  AMCheckBoxTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMCheckBoxTableViewCell.h"

@interface AMCheckBoxTableViewCell(){
    
}

@end

@implementation AMCheckBoxTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setConfiguredCell:(AMConfiguredCell *)configuredCell
{
    _configuredCell = configuredCell;
    self.titleLabel.text = configuredCell.cellTitle;
    _isChecked = [configuredCell.cellValue isEqualToLocalizedString:kAMBOOL_STRING_YES] ? YES : NO;
    [self.checkBoxButton setSelected:_isChecked];
    [self.checkBoxButton setUserInteractionEnabled:configuredCell.isEditable];
}

- (IBAction)checkBoxButtonTapped:(id)sender {
    _isChecked = !_isChecked;
    [self.checkBoxButton setSelected:_isChecked];
    if (self.delegate && [self.delegate respondsToSelector:@selector(checkboxIsChecked:cellObj:)]) {
        [self.delegate checkboxIsChecked:_isChecked cellObj:self];
    }
}

@end
