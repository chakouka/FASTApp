//
//  AMPendingWOHeaderView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPendingWOHeaderView.h"

@implementation AMPendingWOHeaderView

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
    
    self.labelWO.text = MyLocal(@"WO #");
    self.labelWOType.text = MyLocal(@"WO TYPE");
    self.labelComplaintCode.text = MyLocal(@"COMPLAINT CODE");
    self.labelMachineType.text = MyLocal(@"MACHINE TYPE");
    self.labelStatus.text = MyLocal(@"STATUS");
    self.labelPriority.text = MyLocal(@"PRIORITY");
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
