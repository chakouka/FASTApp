//
//  AMNearOrderListAdminCell.m
//  AramarkFSP
//
//  Created by Brian Kendall on 10/13/2015.
//  Copyright (c) 2015 Aramark Inc. All rights reserved.
//

#import "AMNearOrderListAdminCell.h"

@implementation AMNearOrderListAdminCell
@synthesize strPriority;

- (void)awakeFromNib
{
    self.labelTWorkorderNumber.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Workorder Number")];
    self.labelTEstimatedWorkDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Estimated Work Date")];
    self.labelTComplaintCode.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Complaint Code")];
    self.labelTSubject.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Subject")];
    
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
