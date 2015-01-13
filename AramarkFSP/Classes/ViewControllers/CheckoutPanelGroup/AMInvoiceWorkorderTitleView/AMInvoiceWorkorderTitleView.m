//
//  AMInvoiceWorkorderTitleView.m
//  AramarkFSP
//
//  Created by FYH on 8/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceWorkorderTitleView.h"

@implementation AMInvoiceWorkorderTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.labelTPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"PRICE")];
       [AMUtilities refreshFontInView:self];
    }
    return self;
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
