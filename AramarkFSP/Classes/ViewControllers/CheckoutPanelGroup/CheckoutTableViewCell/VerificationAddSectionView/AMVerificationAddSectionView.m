//
//  AMVerificationAddSectionView.m
//  AramarkFSP
//
//  Created by PwC on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationAddSectionView.h"

@implementation AMVerificationAddSectionView
@synthesize isAdd;
@synthesize delegate;

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
    self.labelTCancel.text = MyLocal(@"Cancel");
    self.labelTStatus.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Status")];
    self.labelTAdd.text = MyLocal(@"Add");
    
    [AMUtilities refreshFontInView:self];
}

- (void)setAdd:(BOOL)add
{
    isAdd = add;
    self.viewAdd.hidden = add;
    self.viewCancel.hidden = !add;
}

- (IBAction)clickAddBtn:(UIButton *)sender {
    
    if ([self.strWOType isEqualToString:MyLocal(@"Filter Exchange"])) {
        [UIAlertView showWithTitle:@"Warning" message:@"This is a filter exchange, you should not be installing equipment on the filter account" style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        }];
        
    } else {
        [self setAdd:NO];
        
        if (delegate && [delegate respondsToSelector:@selector(verificationSectionViewDidClickAddBtn:)]) {
            [delegate verificationSectionViewDidClickAddBtn:self];
        }
    }
}

- (IBAction)clickCancelBtn:(UIButton *)sender {
    [self setAdd:YES];
    
    if (delegate && [delegate respondsToSelector:@selector(verificationSectionViewDidClickCancelBtn:)]) {
        [delegate verificationSectionViewDidClickCancelBtn:self];
    }
}

@end
