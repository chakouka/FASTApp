//
//  AMAssetsViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAssetsViewController.h"

@interface AMAssetsViewController (){
    NSDateFormatter *df;
    NSArray *locationArr;
    UIPopoverController *bPopoverVC;
    AMPopoverSelectTableViewController *popView;
}

@end

@implementation AMAssetsViewController

- (id)initWithAsset:(AMAsset *)asset
{
    if (self = [self initWithNibName:@"AMAssetsViewController" bundle:nil]) {
        self.assignedAsset = asset;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.labelTAssetInfo.text = MyLocal(@"Asset Info");
    self.labelTAssetName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset Name")];
    self.labelTSerialNumber.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Serial Number")];
    self.labelTInstallDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Install Date")];
    self.labelTAssetNumber.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Asset Number")];
    self.labelTMachineType.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Machine Type")];
    self.labelTManufacturer.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Cashless Card Serial Number")];
    self.labelTVendKey.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Vend Key")];
    self.labelTNextPMDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Next PM Date")];
    self.labelTLocation.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location")];
    self.labelTLastVerifiedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Last Verified Date")];
    
    MyButtonTitle(self.saveButton, MyLocal(@"SAVE"));
    [self.saveButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:17.0]];
    self.vendKeyTF.delegate = self;
    _relatedWOVC = [[AMRelatedWOViewController alloc] initWithType:AMRelatedWOTypeAsset sectionTitle:MyLocal(@"REPAIR WO HISTORY")];
    _relatedWOVC.view.frame = CGRectMake(_relatedWOVC.view.frame.origin.x, _relatedWOVC.view.frame.origin.y, CGRectGetWidth(self.relatedWOView.frame), CGRectGetHeight(self.relatedWOView.frame));
    _relatedWOVC.delegate = self;
    [self.relatedWOView addSubview:_relatedWOVC.view];
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:AMDATE_FORMATTER_STRING_STANDARD];
    [self populateValue];
}

- (void)populateValue
{
    self.assetNameTF.text = _assignedAsset.assetName;
    self.serialNumberTF.text = _assignedAsset.serialNumber;
    self.installDateTF.text = [df stringFromDate:_assignedAsset.installDate];
    self.machineNumberTF.text = _assignedAsset.machineNumber;
    self.machineTypeTF.text = _assignedAsset.productName;
    self.vendKeyTF.text = _assignedAsset.vendKey;
//    AMLocation *location = [[AMLogicCore sharedInstance] getLocationByID:_assignedAsset.locationID];
//    self.locationTF.text = location.location;
    self.locationTF.text = _assignedAsset.locationName;
    self.nextPMDate.text = [df stringFromDate:_assignedAsset.nextPMDate];
    self.verifiedDateTF.text = [df stringFromDate:_assignedAsset.lastVerifiedDate];
    [self.websiteButton setTitle:_assignedAsset.manufacturerWebsite forState:UIControlStateNormal];
    _relatedWOVC.pendingWOArray = _assignedAsset.repairWOHistory;
}

- (void)setAssignedAsset:(AMAsset *)assignedAsset
{
    if (_assignedAsset && _assignedAsset == assignedAsset) {
        return;
    }
    _assignedAsset = assignedAsset;
    [self populateValue];
    [self.locationDropdown setEnabled:assignedAsset ? YES : NO];
    [self.vendKeyTF setEnabled:assignedAsset ? YES : NO];
    [self.saveButton setEnabled:assignedAsset ? YES : NO];
}

- (void)reloadRelatedWorkOrders
{
    DLog(@"reloadRelatedWorkOrders called in Asset VC");
    if (_relatedWOVC) {
        _assignedAsset.repairWOHistory = [[AMLogicCore sharedInstance] getAssetPast6MonthsRepairWorkOrderList:_assignedAsset.assetID];
        _relatedWOVC.pendingWOArray = _assignedAsset.repairWOHistory;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.superview.frame), CGRectGetHeight(self.view.frame));
    if ([self.view.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *sView = (UIScrollView *)self.view.superview;
        [sView setContentSize:self.view.frame.size];
    }
    self.relatedWOVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.relatedWOView.superview.frame)- 20, CGRectGetHeight(self.relatedWOView.frame));
}

- (IBAction)locationDropdownTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    locationArr = [[AMLogicCore sharedInstance] getLocationListByAccountID:self.accountId];
    if ([locationArr count] == 0) {
        [SVProgressHUD showErrorWithStatus:MyLocal(@"Don't have associated location")];
        return;
    }
    if (!bPopoverVC) {
        popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        
        bPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [bPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), 200.0)];
    }
    popView.arrInfos = [self buildUpPopoverDataSource];
    //	aPopoverVC.delegate = self;
	[bPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (NSMutableArray *)buildUpPopoverDataSource
{
    NSMutableArray *mArray = [NSMutableArray array];
    for (AMLocation *loc in locationArr) {
        if (loc.locationID && loc.location) {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
            [mDic setObject:loc.locationID forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
            [mDic setObject:loc.location forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
            [mArray addObject:mDic];
        }
    }
    return mArray;
}

#pragma mark - AMRelatedWOViewControllerDelegate
- (void)didTappedOnCollapseButton:(UIButton *)collapseBtn
{
    CGRect oriRect = self.saveButton.frame;
    oriRect.origin.y += collapseBtn.isSelected ? - (CGRectGetHeight(self.relatedWOView.frame) - 40.0) : (CGRectGetHeight(self.relatedWOView.frame) - 40.0);
    [UIView animateWithDuration:0.3 animations:^{
        self.saveButton.frame = oriRect;
    }];
}

#pragma mark - AMPopoverSelectTableViewControllerDelegate
- (void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray
{
    if (bPopoverVC) {
        [bPopoverVC dismissPopoverAnimated:YES];
    }
    self.locationTF.text = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
    self.assignedAsset.locationName = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
    self.assignedAsset.locationID = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
}

- (IBAction)saveButtonTapped:(id)sender {
    [self.vendKeyTF resignFirstResponder];
    [[AMLogicCore sharedInstance] updateAsset:self.assignedAsset completionBlock:^(NSInteger type, NSError *error) {
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:MyLocal(@"Save Success")];
        } else {
            [SVProgressHUD showErrorWithStatus:MyLocal(@"Save Fail")];
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.vendKeyTF) {
        self.assignedAsset.vendKey = textField.text;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.vendKeyTF)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        BOOL isValid;
        if ([newString length] == 0) {
            isValid = YES;
        } else {
            isValid = [AMUtilities isValidIntegerValueTyped:newString];
        }
//        if (isValid) {
//            if ([textField.text isEqualToString:@"0"]) {
//                textField.text = @"";
//            }
//        }
        return isValid && [newString length] <= 12;
    }
    
    return YES;
}

- (IBAction)manufacturerWebsiteButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text length] == 0) {
        return;
    }
    NSMutableString *urlStr = [NSMutableString stringWithString:button.titleLabel.text];
    if (![urlStr hasPrefix:@"http://"]) {
        [urlStr insertString:@"http://" atIndex:0];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
