//
//  AMAttachmentCollViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAttachmentCollViewCell.h"

@implementation AMAttachmentCollViewCell

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
    [self.nameLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:14.0]];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setAttachment:(AMDBAttachment *)attachment
{
    _attachment = attachment;
    NSRange range = [attachment.contentType rangeOfString:@"image"];
    if (range.location != NSNotFound) {
        UIImage *image = nil;
        if (attachment.localURL) {
            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:attachment.localURL] scale:0.25];
            if (image) {
                self.nameLabel.hidden = YES;
                self.imageView.hidden = NO;
                self.imageView.image = image;
            } else {
                self.nameLabel.hidden = NO;
                self.imageView.hidden = YES;
                self.nameLabel.text = attachment.name;
            }
            
        } else {
            self.imageView.hidden = YES;
            self.nameLabel.hidden = NO;
            self.nameLabel.text = [NSString stringWithFormat:@"%@...",MyLocal(@"Downloading")];
        }
        
    } else {
        self.imageView.hidden = YES;
        self.nameLabel.hidden = NO;
        self.nameLabel.text = attachment.name;
    }
    
}



@end
