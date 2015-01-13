//
//  AMSectionHeaderAttachmentView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSectionHeaderAttachmentView.h"

@implementation AMSectionHeaderAttachmentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [self.attachmentButton setTitle:MyLocal(@"Attachments") forState:UIControlStateNormal];
    [self.attachmentButton setTitle:MyLocal(@"Cancel") forState:UIControlStateSelected];
    [self.attachmentButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)attachmentButtonTapped:(id)sender {
    [self.attachmentButton setSelected:!self.attachmentButton.isSelected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedOnAttachmentButton:)]) {
        [self.delegate didSelectedOnAttachmentButton:self.attachmentButton.isSelected];
    }
}

@end
