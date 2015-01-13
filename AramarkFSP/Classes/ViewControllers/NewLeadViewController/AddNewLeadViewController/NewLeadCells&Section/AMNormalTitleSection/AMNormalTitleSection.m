//
//  AMNormalTitleSection.m
//  AramarkFSP
//
//  Created by PwC on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNormalTitleSection.h"

@implementation AMNormalTitleSection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            [AMUtilities refreshFontInView:self];
    }
    return self;
}

- (void)awakeFromNib
{
    NSString *strT = [NSString stringWithFormat:@"  %@",MyLocal(@"Cancel")];
    MyButtonTitle(self.btnCancel, strT);
    
    [AMUtilities refreshFontInView:self];
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
