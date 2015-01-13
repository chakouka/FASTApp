//
//  AMVerificationSectionView.m
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationSectionView.h"
#import "AMAsset.h"

@implementation AMVerificationSectionView
//@synthesize isDropDown;
@synthesize strFlag;
@synthesize delegate;
@synthesize section;

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
    self.labelStatusTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Status")];
    [AMUtilities refreshFontInView:self];
}

- (IBAction)clickStatusBtn:(id)sender {
    DLog(@"clickStatusBtn");
    
    if (delegate && [delegate respondsToSelector:@selector(AMVerificationSectionViewDidClickStatusBtn:)]) {
        [delegate AMVerificationSectionViewDidClickStatusBtn:self];
    }
}

- (IBAction)clickDropBtn:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(verificationSectionViewDidClickDropBtn:)]) {
        [delegate verificationSectionViewDidClickDropBtn:self];
    }
}

- (void)setVerified:(BOOL)aVerified
{
    self.viewBottomLineGreen.hidden = YES;
    self.viewBottomLineRed.hidden = YES;
    
    if (aVerified) {
        self.labelStatus.textColor = COLOR_GREEN;
        self.viewBottomLineGreen.hidden = NO;
    }
    else
    {
        self.labelStatus.textColor = COLOR_RED;
        self.viewBottomLineRed.hidden = NO;
    }
}

- (void)setDrop:(BOOL)aDrop
{
//    self.viewBottomLineGreen.hidden = YES;
//    self.viewBottomLineRed.hidden = YES;
    self.labelStatus.hidden = YES;
    self.labelStatusTitle.hidden = YES;
    
    if (!aDrop) {
        self.imageDrop.image = [UIImage imageNamed:@"arrow-down"];
//        self.viewBottomLineGreen.hidden = NO;
        self.labelStatus.hidden = NO;
        self.labelStatusTitle.hidden = NO;
    }
    else
    {
        self.imageDrop.image = [UIImage imageNamed:@"Arrow-up"];
//         self.viewBottomLineRed.hidden = NO;
        
    }
}

@end
