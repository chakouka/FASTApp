//
//  AMSectionHeaderView.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMSectionHeaderView.h"
@interface AMSectionHeaderView(){
    NSMutableArray *contentArr;
}

@end

@implementation AMSectionHeaderView

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
    NSString *strT = [NSString stringWithFormat:@"  %@",MyLocal(@"Cancel")];
    MyButtonTitle(self.buttonDropDown, strT);
    self.labelSectionTitle.text = MyLocal(@"Work Order");
    [self.labelSectionTitle setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.recordTypeButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.buttonDropDown.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setIsExpanded:(BOOL)isExpanded
{
    _isExpanded = isExpanded;
    UIImage *dropDownImage = [UIImage imageNamed:isExpanded ? @"arrow-up" : @"arrow-down"];
    [_buttonDropDown setImage:dropDownImage forState:UIControlStateNormal];
}

//For Cancel Creating New Work Order
- (IBAction)dropDownButtonTapped:(id)sender {
//    self.isExpanded = !_isExpanded;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelCreatingNewWO)]) {
        [self.delegate performSelector:@selector(didCancelCreatingNewWO) withObject:nil];
    }
}

- (IBAction)recordTypeButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([_popoverCon isPopoverVisible]) {
        [_popoverCon dismissPopoverAnimated:YES];
        return;
    } else {
        if (!_popoverCon) {
            AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
            popView.delegate = self;
            popView.arrInfos = self.popoverContentArr;
            _popoverCon = [[UIPopoverController alloc] initWithContentViewController:popView];
            [_popoverCon setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), 200.0)];
        }
        [_popoverCon presentPopoverFromRect:button.frame inView:self permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}


- (NSMutableArray *)popoverContentArr
{
    if ([contentArr count] > 0) {
        return contentArr;
    }
//    contentArr = [NSMutableArray arrayWithArray:@[@{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_REPAIR}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_SWAP}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_SITESURVEY}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_REMOVAL}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_PM}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_MOVE}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_INSTALL}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_EXCHANGE}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: kAMWORK_ORDER_TYPE_ASSETVERIFICATION}]];
    
	/*
	contentArr = [NSMutableArray arrayWithArray:@[@{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(kAMWORK_ORDER_TYPE_REPAIR), kAMPOPOVER_DICTIONARY_KEY_VALUE : kAMWORK_ORDER_TYPE_REPAIR},
                                                  @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(kAMWORK_ORDER_TYPE_SWAP), kAMPOPOVER_DICTIONARY_KEY_VALUE : kAMWORK_ORDER_TYPE_SWAP},
                                                  @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(kAMWORK_ORDER_TYPE_REMOVAL), kAMPOPOVER_DICTIONARY_KEY_VALUE : kAMWORK_ORDER_TYPE_REMOVAL},
                                                  @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(kAMWORK_ORDER_TYPE_MOVE), kAMPOPOVER_DICTIONARY_KEY_VALUE : kAMWORK_ORDER_TYPE_MOVE}]];
    */

    return contentArr;
}

#pragma AMPopoverSelectTableViewControllerDelegate
- (void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray
{
    if (_popoverCon) {
        [_popoverCon dismissPopoverAnimated:YES];
    }
    NSString *recordTypeStr = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
    [self.recordTypeButton setTitle:[NSString stringWithFormat:@"[%@ ⌄]", recordTypeStr] forState:UIControlStateNormal];
//    WORKORDERType type = -1;
//    if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_REPAIR]) {
//        type = WORKORDERType_Repair;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_SWAP]) {
//        type = WORKORDERType_Swap;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_SITESURVEY]) {
//        type = WORKORDERType_SiteSurvey;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_REMOVAL]) {
//        type = WORKORDERType_Removal;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_PM]) {
//        type = WORKORDERType_PM;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_MOVE]) {
//        type = WORKORDERType_Move;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_INSTALL]) {
//        type = WORKORDERType_Install;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_EXCHANGE]) {
//        type = WORKORDERType_Exchange;
//    } else if ([recordTypeStr isEqualToString:kAMWORK_ORDER_TYPE_ASSETVERIFICATION]) {
//        type = WORKORDERType_AssetVerification;
//    }
    //Pass english work for record type to salesforce, not localized string
    NSString *recordTypeStrValue = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnPopoverRecordType:)]) {
        [self.delegate didTappedOnPopoverRecordType:recordTypeStrValue];
    }
}

@end
