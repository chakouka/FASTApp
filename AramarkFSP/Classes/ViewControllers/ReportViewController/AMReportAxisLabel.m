//
//  AMReportAxisLabel.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/5/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMReportAxisLabel.h"

@implementation AMReportAxisLabel

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
    self.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0];
    self.adjustsFontSizeToFitWidth = YES;
    self.minimumScaleFactor = 0.5;
    self.textAlignment = NSTextAlignmentCenter;
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
