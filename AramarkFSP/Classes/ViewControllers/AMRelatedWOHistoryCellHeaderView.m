//
//  AMRelatedWOHistoryCellHeaderView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 7/2/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMRelatedWOHistoryCellHeaderView.h"

@implementation AMRelatedWOHistoryCellHeaderView

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
    for (id subV in [self subviews]) {
        if ([subV isKindOfClass:[UILabel class]]) {
            UILabel *lable = (UILabel *)subV;
            [lable setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:16.0]];
        }
    }
    
    self.labelTWO.text = MyLocal(@"WO #");
    self.labelTWOType.text = MyLocal(@"WO TYPE");
    self.labelTRepairCode.text = MyLocal(@"REPAIR CODE");
    self.labelTAssinedTo.text = MyLocal(@"ASSIGNED TO");
    self.labelTWODate.text = MyLocal(@"WO DATE");
    self.labelTPriority.text = MyLocal(@"PRIORITY");
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
