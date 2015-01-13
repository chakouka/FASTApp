//
//  AMOrderListCell.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMOrderListCell.h"

@implementation AMOrderListCell
@synthesize strPriority;

- (void)awakeFromNib
{
    self.lableTContact.text = [NSString stringWithFormat:@"%@ :",MyLocal(@"Contact")];
    self.lableTOpenSince.text = [NSString stringWithFormat:@"%@ :",MyLocal(@"Open Since")];
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
