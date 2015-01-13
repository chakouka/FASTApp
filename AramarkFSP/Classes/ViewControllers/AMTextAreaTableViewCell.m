//
//  AMTextAreaTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/13/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMTextAreaTableViewCell.h"

@implementation AMTextAreaTableViewCell

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
    self.valueTextView.delegate = self;
    [self.valueTextView setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    self.valueTextView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setConfiguredCell:(AMConfiguredCell *)configuredCell
{
    [super setConfiguredCell:configuredCell];
    self.titleLabel.text = configuredCell.cellTitle;
    self.valueTextView.text = configuredCell.cellValue;
    self.valueTextView.layer.borderWidth = 0;
    [self.editButton setHidden:!configuredCell.isEditable];
    [self.valueTextView setEditable:NO];
}

- (IBAction)editButtonTapped:(id)sender {
    if (self.isEditingMode) {
        self.valueTextView.layer.borderWidth = 0;
        [self.valueTextView setEditable:NO];
        self.isEditingMode = NO;
    } else {
        self.valueTextView.layer.borderWidth = 1;
        [self.valueTextView setEditable:YES];
        self.isEditingMode = YES;
    }
}

#pragma UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewStartEditing:withCellObj:)]) {
        [self.delegate textViewStartEditing:textView withCellObj:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(textViewEndEditing:withCellObj:)]) {
        [self.delegate textViewEndEditing:textView withCellObj:self];
    }
}
@end
