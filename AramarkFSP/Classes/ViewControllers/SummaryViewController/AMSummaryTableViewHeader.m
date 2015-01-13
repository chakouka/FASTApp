//
//  AMSummaryTableViewHeader.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/3/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSummaryTableViewHeader.h"


@interface AMSummaryTableViewHeader ()

@end

@implementation AMSummaryTableViewHeader

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
    self.lbl_title.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0];
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
