//
//  AMAccountPendingWOHeaderView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 10/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAccountPendingWOHeaderView.h"

@implementation AMAccountPendingWOHeaderView

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
    self.labelPOS.text = MyLocal(@"POS");
    self.labelWOType.text = MyLocal(@"WO TYPE");
    self.labelComplaintCode.text = MyLocal(@"COMPLAINT CODE");
    self.labelMachineType.text = MyLocal(@"MACHINE TYPE");
//    self.labelStatus.text = MyLocal(@"STATUS");
    self.labelPriority.text = MyLocal(@"PRIORITY");
}

@end
