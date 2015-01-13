//
//  AMSummaryLabel.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/4/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSummaryLabel.h"

@implementation AMSummaryLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

-(void)setup
{
    self.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:self.font.pointSize];
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
