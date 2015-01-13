//
//  AMCustomCellView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMCustomCellView.h"

@implementation AMCustomCellView

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
    self.titleLabel.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location Name")];
    NSString *strT = [NSString stringWithFormat:@"  %@  ",MyLocal(@"Update Site Survey")];
    MyButtonTitle(self.updateSiteSurveyButton, strT);
    
    [self.updateSiteSurveyButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.valueTextField setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    
//    for (UIView *subview in [self subviews]) {
//        if ([subview isKindOfClass:[UILabel class]]) {
//            UILabel *lbl = (UILabel *)subview;
//            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
//        } else if ([subview isKindOfClass:[UITextField class]]) {
//            UITextField *tf = (UITextField *)subview;
//            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
//        } else if ([[subview subviews] count] > 0) {
//            for (UIView *sv in [subview subviews]) {
//                if ([sv isKindOfClass:[UILabel class]]) {
//                    UILabel *label = (UILabel *)sv;
//                    [label setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
//                }
//            }
//        }
//    }
}


- (void)setAssignedLocation:(AMLocation *)assignedLocation
{
    _assignedLocation = assignedLocation;
    self.valueTextField.text = assignedLocation.location;
}

- (IBAction)didTappedOnUpdateSurvey:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnUpdateSiteSurvey:)]) {
        [self.delegate performSelector:@selector(didTappedOnUpdateSiteSurvey:) withObject:self.assignedLocation];
    }
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
