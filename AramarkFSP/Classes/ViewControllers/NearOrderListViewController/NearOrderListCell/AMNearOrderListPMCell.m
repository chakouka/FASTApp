//
//  AMNearOrderListPMCell.m
//  AramarkFSP
//
//  Created by FYH on 9/3/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNearOrderListPMCell.h"

@implementation AMNearOrderListPMCell
@synthesize strPriority;

- (void)awakeFromNib
{
    self.labelTWorkorderNumber.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Workorder Number")];
    self.labelTEstimatedWorkDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Estimated Work Date")];
    self.labelTMachineType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Machine Type")];
    
    [AMUtilities refreshFontInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

-(void)showShadeStatus:(BOOL)isShow
{
    self.viewShade.hidden = !isShow;
    self.viewRight.hidden = isShow;
}

@end
