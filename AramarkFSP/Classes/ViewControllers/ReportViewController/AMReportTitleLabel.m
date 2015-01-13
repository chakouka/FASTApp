//
//  AMReportTitleLabel.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/12/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMReportTitleLabel.h"

@implementation AMReportTitleLabel

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
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = [UIColor whiteColor];
    self.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0];
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
