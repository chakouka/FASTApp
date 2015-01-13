 //
//  AMDropDownTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/13/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDropdownTableViewCell.h"
#import "AMDBPicklist.h"

@interface AMDropdownTableViewCell(){
    UIPopoverController *aPopoverVC;
    NSDateFormatter *df;
    NSMutableArray *popoverArr_priority;
    NSMutableArray *popoverArr_preferredTime;
    NSMutableArray *popoverArr_complaintCode;
    NSMutableArray *popoverArr_AssetLocation;
    NSMutableArray *popoverArr_AssetList;
}

@end

@implementation AMDropdownTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:AMDATE_FORMATTER_STRING_STANDARD];
    [df setTimeZone:[[AMLogicCore sharedInstance] timeZoneOnSalesforce]];
    [self.cellTitle setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
    [self.cellValue setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setConfiguredCell:(AMConfiguredCell *)configuredCell
{
    _configuredCell = configuredCell;
    self.cellTitle.text = configuredCell.cellTitle;
    self.cellValue.text = MyLocal(configuredCell.cellValue);
    [self.dropDownButton setHidden:!configuredCell.isEditable];
    
}

- (IBAction)dropDownButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([@"estimatedDate" isEqualToString:_configuredCell.propertyName]) {
        AMDatePickerViewController *datePickerVC = [[AMDatePickerViewController alloc] initWithNibName:@"AMDatePickerViewController" bundle:nil];
        datePickerVC.delegate = self;
        aPopoverVC = nil;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:datePickerVC];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(datePickerVC.view.frame), CGRectGetHeight(datePickerVC.view.frame))];
        [aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        if (_configuredCell.cellValue) {
            [datePickerVC.datePicker setDate:[df dateFromString:_configuredCell.cellValue] animated:YES];
        }
    } else if ([@"complaintCode" isEqualToString:_configuredCell.propertyName]) {
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.arrInfos = self.popoverContentArrForComplaintCode;
        aPopoverVC = nil;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), 200.0)];
        //	aPopoverVC.delegate = self;
        [aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    } else if ([@"toLocationID" isEqualToString:_configuredCell.propertyName]) {
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.arrInfos = self.popoverContentArrForAssetLocation;
        aPopoverVC = nil;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), 200.0)];
        //	aPopoverVC.delegate = self;
        [aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    } else if ([@"assetID" isEqualToString:_configuredCell.propertyName]) {
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.arrInfos = self.popoverContentArrForAssetList;
        aPopoverVC = nil;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame) + 50.0, 200.0)];
        //	aPopoverVC.delegate = self;
        [aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    } else if ([@"priority" isEqualToString:_configuredCell.propertyName]) {
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.arrInfos = self.popoverContentArrForPriority;
        aPopoverVC = nil;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame) + 50.0, 200.0)];
        //	aPopoverVC.delegate = self;
        [aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    } else {
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.arrInfos = self.popoverContentArr;
        aPopoverVC = nil;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
        //	aPopoverVC.delegate = self;
        [aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    }
    
}

- (NSMutableArray *)popoverContentArrForPriority {
    if (!popoverArr_priority) {
        popoverArr_priority = [NSMutableArray arrayWithArray:@[@{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"Critical"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"Critical"},
                                                          @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"High"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"High"},
                                                          @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"Medium"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"Medium"},
                                                          @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"Low"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"Low"}]];
    }
    return popoverArr_priority;
}

- (NSMutableArray *)popoverContentArrForAssetList {
    popoverArr_AssetList = [[NSMutableArray alloc] init];
    NSArray *contentArr = [[AMLogicCore sharedInstance] getAssetListByPoSID:self.posId AccountID:self.accountId];
    for (AMAsset *asset in contentArr) {
        [popoverArr_AssetList addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : [NSString stringWithFormat:@"%@%@%@", asset.machineNumber ? asset.machineNumber : @"", asset.machineNumber && asset.productName ? @"-" : @"", asset.productName ? asset.productName : @""], kAMPOPOVER_DICTIONARY_KEY_DATA : asset }];
    }
    return popoverArr_AssetList;
}

- (NSMutableArray *)popoverContentArrForAssetLocation {
    popoverArr_AssetLocation = [[NSMutableArray alloc] init];
    NSArray *contentArr = [[AMLogicCore sharedInstance] getLocationListByAccountID:self.accountId];
    for (AMLocation *locationInfo in contentArr) {
        [popoverArr_AssetLocation addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : [NSString stringWithFormat:@"%@", locationInfo.location], kAMPOPOVER_DICTIONARY_KEY_DATA : locationInfo }];
    }
    return popoverArr_AssetLocation;
}

- (NSMutableArray *)popoverContentArrForComplaintCode {
    if (!popoverArr_complaintCode) {
        popoverArr_complaintCode = [[NSMutableArray alloc] init];
        NSArray *contentArr = [[AMLogicCore sharedInstance] getPicklistOfComplaintCodeInWorkOrder];
        for (AMDBPicklist *pl in contentArr) {
            [popoverArr_complaintCode addObject:@{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(pl.fieldValue), kAMPOPOVER_DICTIONARY_KEY_VALUE: pl.fieldValue}];
        }
    }
    return popoverArr_complaintCode;
}

- (NSMutableArray *)popoverContentArr
{
    if (!popoverArr_preferredTime) {
        popoverArr_preferredTime = [NSMutableArray arrayWithArray:@[@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"08:00"},@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"09:00"}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: @"10:00"}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: @"11:00"},@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"12:00"}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: @"13:00"},@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"14:00"}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: @"15:00"},@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"16:00"}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: @"17:00"},@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"18:00"}]];
    }
    return popoverArr_preferredTime;
}

#pragma AMPopoverSelectTableViewControllerDelegate
- (void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray
{
    self.cellValue.text = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
    [aPopoverVC dismissPopoverAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectPopoverDictionary:cellObj:)]) {
        [self.delegate didSelectPopoverDictionary:[aArray objectAtIndex:aIndex] cellObj:self];
    }
}



#pragma mark - AMDatePickerViewControllerDelegate
- (void)didTappedOnOKButton:(NSDate *)date
{
    self.cellValue.text = [df stringFromDate:date];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dateChoosed:cellObj:)]) {
        [self.delegate dateChoosed:date cellObj:self];
    }
    [aPopoverVC dismissPopoverAnimated:YES];
}

- (void)didTappedOnCancelButton
{
    [aPopoverVC dismissPopoverAnimated:YES];
}


@end
