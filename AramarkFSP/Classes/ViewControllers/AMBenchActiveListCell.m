//
//  AMBenchActiveListCell.m
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMBenchActiveListCell.h"

@implementation AMBenchActiveListCell
@synthesize strPriority;

- (void)awakeFromNib
{
//    self.lableTContact.text = [NSString stringWithFormat:@"%@ :",MyLocal(@"Contact")];
//    self.lableTOpenSince.text = [NSString stringWithFormat:@"%@ :",MyLocal(@"Open Since")];
    [AMUtilities refreshFontInView:self.contentView];
    [_btnGetAssetInfo setTitle:MyLocal(@"GET ASSET INFO") forState:UIControlStateNormal];
    [_btnStart setTitle:MyLocal(@"START") forState:UIControlStateNormal];
    [_btnStop setTitle:MyLocal(@"STOP") forState:UIControlStateNormal];
    [_btnCheckout setTitle:MyLocal(@"CHECK OUT") forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

-(void)showShadeStatus:(BOOL)isShow
{
    self.viewShade.hidden = !isShow;
//    self.viewRight.hidden = isShow;
}

@end
