//
//  AMAttachmentCollViewLocalCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAttachmentCollViewLocalCell.h"

@implementation AMAttachmentCollViewLocalCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)awakeFromNib
{
    self.previewImageView.image = [UIImage imageNamed:MyImage(@"preview-button")];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnCell:)];
    [self.imageView addGestureRecognizer:tapGesture];

    [self addGestureRecognizer:tapGesture];
}

- (void)tappedOnCell:(UIGestureRecognizer *)gesture
{
    if (self.imageView.hidden) {
        CGPoint point = [gesture locationInView:self];
        if (point.x > self.frame.size.width/2) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:MyLocal(@"Delete Image") message:MyLocal(@"Are you sure you want to delete this attached image?") delegate:self cancelButtonTitle:MyLocal(@"Cancel")  otherButtonTitles:MyLocal(@"YES"), nil];
            [alertView show];
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnPreviewButton:withIndex:)]) {
                [self.delegate didTappedOnPreviewButton:self.attachment withIndex:self.tag];
            }
        }
    } else {
        self.previewImageView.hidden = NO;
        self.imageView.hidden = YES;
    }
    
}

- (void)tappedOnPreviewImage:(UIGestureRecognizer *)gesture
{
    
    self.previewImageView.hidden = YES;
    self.imageView.hidden = NO;
}

- (void)setAttachment:(AMDBAttachment *)attachment
{
    _attachment = attachment;
    UIImage *image = nil;
    if (attachment.localURL) {
        image = [UIImage imageWithData:[NSData dataWithContentsOfFile:attachment.localURL] scale:1.0];
        self.imageView.hidden = NO;
        self.imageView.image = image;
    }
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnDeleteButton:)]) {
                [self.delegate performSelector:@selector(didTappedOnDeleteButton:) withObject:self.attachment];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
