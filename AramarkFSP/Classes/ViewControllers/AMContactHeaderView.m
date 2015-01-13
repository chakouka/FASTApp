//
//  AMContactHeaderView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/18/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMContactHeaderView.h"

@implementation AMContactHeaderView

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
    [self.contactNameLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:17.0]];
}

@end
