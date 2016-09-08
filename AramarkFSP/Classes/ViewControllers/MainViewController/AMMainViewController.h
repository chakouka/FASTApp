//
//  AMMainViewController.h
//  AramarkFSP
//
//  Created by PwC on 4/23/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AMMainViewController : GAITrackedViewController
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UIView *viewLeftPanel;
@property (weak, nonatomic) IBOutlet UIView *viewMainPanel;
@property (weak, nonatomic) IBOutlet UIView *viewCheckoutPanel;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *viewLeftListPanel;
@property (weak, nonatomic) IBOutlet UIView *viewDetailPanel;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imageHead;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIView *viewLogOut;
//@property (weak, nonatomic) IBOutlet UIButton *clearCacheButton; //duplicate button
@property (weak, nonatomic) IBOutlet UIView *viewAlert;
@property (weak, nonatomic) IBOutlet UILabel *labelAlertTip;
@property (weak, nonatomic) IBOutlet UILabel *labelWelcome;
@property (weak, nonatomic) IBOutlet UIView *viewReportPanel;
@property (weak, nonatomic) IBOutlet UIView *viewSummaryPanel;
@property (weak, nonatomic) IBOutlet UIView *viewLeadPanel;
@property (weak, nonatomic) IBOutlet UIView *viewCasePanel;
@property (weak, nonatomic) IBOutlet UIView *viewNearMePanel;
@property (weak, nonatomic) IBOutlet UIView *viewBenchPanel;
@property (weak, nonatomic) IBOutlet UIView *viewActiveBenchPanel;
@property (weak, nonatomic) IBOutlet UIView *viewActiveDetailBenchPanel;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchAssetNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchSerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchMachineType;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchPOSName;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchTechName;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchAVNotes;
@property (weak, nonatomic) IBOutlet UILabel *labelBenchRepairMatrixNTE;

@property (weak, nonatomic) IBOutlet UILabel *lblDtlName;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlSerialNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlInstallDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlAssetNumber;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlMachineType;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlManufacturerWebsite;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlVendKey;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlNextPMDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDtlLocation;

@property (weak, nonatomic) IBOutlet UIScrollView *scrHistoryScroller;


@property (weak, nonatomic) NSString *selectedAssetID;
@property (weak, nonatomic) NSString *selectedWorkorderID;

- (IBAction)clickLoginBtn:(UIButton *)sender;
- (IBAction)clickLogOutBtn:(UIButton *)sender;

- (void)userInteractionEnabled:(BOOL)enable;

@end
