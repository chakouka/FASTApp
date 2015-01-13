//
//  AMSectionFooterView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSectionFooterView.h"

@implementation AMSectionFooterView

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
    MyButtonTitle(self.saveButton, MyLocal(@"SAVE WORK ORDER"));
    NSString *strCT = [NSString stringWithFormat:@" + %@",MyLocal(@"CREATE NEW WORK ORDER")];
    MyButtonTitle(self.createButton,strCT);
    [self.saveButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    [self.createButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)didTappedOnSaveButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnSaveButton)]) {
        [self.delegate performSelector:@selector(didTappedOnSaveButton) withObject:nil];
    }
}

- (IBAction)didTappedOnCreateButton:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnCreateButton)]) {
        [self.delegate performSelector:@selector(didTappedOnCreateButton) withObject:nil];
    }
}

@end
