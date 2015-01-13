//
//  AMAttachmentCollViewAddCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/1/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAttachmentCollViewAddCell.h"

@implementation AMAttachmentCollViewAddCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    self.labelTAdd.text = MyLocal(@"Add");
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
