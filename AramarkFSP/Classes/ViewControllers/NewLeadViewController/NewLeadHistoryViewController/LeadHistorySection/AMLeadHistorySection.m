//
//  AMLeadHistorySection.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMLeadHistorySection.h"

@implementation AMLeadHistorySection

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [AMUtilities refreshFontInView:self];
          self.labelTitle.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0];
    }
    return self;
}

- (void)awakeFromNib
{
    [AMUtilities refreshFontInView:self];
      self.labelTitle.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0];
}

@end
