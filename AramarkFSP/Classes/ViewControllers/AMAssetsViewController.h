//
//  AMAssetsViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"
#import "AMRelatedWOViewController.h"
#import "AMPopoverSelectTableViewController.h"
#import "AmAsset.h"

@interface AMAssetsViewController : AMWOTabBaseViewController<AMRelatedWOViewControllerDelegate, AMPopoverSelectTableViewControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *relatedWOView;
@property (weak, nonatomic) IBOutlet UITextField *assetNameTF;
@property (weak, nonatomic) IBOutlet UITextField *serialNumberTF;
@property (weak, nonatomic) IBOutlet UITextField *installDateTF;
@property (weak, nonatomic) IBOutlet UITextField *machineNumberTF;
@property (weak, nonatomic) IBOutlet UITextField *machineTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *vendKeyTF;
@property (weak, nonatomic) IBOutlet UITextField *locationTF;
@property (weak, nonatomic) IBOutlet UITextField *verifiedDateTF;
@property (weak, nonatomic) IBOutlet UITextField *nextPMDate;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *locationDropdown;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;

@property (strong, nonatomic) AMAsset *assignedAsset;
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) AMRelatedWOViewController *relatedWOVC;

@property (weak, nonatomic) IBOutlet UILabel *labelTAssetInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTAssetName;
@property (weak, nonatomic) IBOutlet UILabel *labelTSerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelTInstallDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTAssetNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelTMachineType;
@property (weak, nonatomic) IBOutlet UILabel *labelTManufacturer;
@property (weak, nonatomic) IBOutlet UILabel *labelTVendKey;
@property (weak, nonatomic) IBOutlet UILabel *labelTNextPMDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelTLastVerifiedDate;


- (id)initWithAsset:(AMAsset *)asset;

@end
