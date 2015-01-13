//
//  AMPOSViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/14/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

/********************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM00116: Display MEI Number. By Hari Kolasani. 12/9/2014
 *********************************************************************************/

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"
#import "AMRelatedWOViewController.h"
#import "AMPoS.h"

@interface AMPOSViewController : AMWOTabBaseViewController

@property (weak, nonatomic) IBOutlet UITextField *posNameLbl;
@property (weak, nonatomic) IBOutlet UITextField *meiNumberLbl;
@property (weak, nonatomic) IBOutlet UITextField *segmentLbl;
@property (weak, nonatomic) IBOutlet UITextField *NAMLbl;
@property (weak, nonatomic) IBOutlet UITextField *KAMLbl;
@property (weak, nonatomic) IBOutlet UITextField *BDMLbl;
@property (weak, nonatomic) IBOutlet UITextField *routeNumberLbl;
@property (weak, nonatomic) IBOutlet UITextField *deiverNameLbl;
@property (weak, nonatomic) IBOutlet UITextField *workOrderCountLbl;
@property (weak, nonatomic) IBOutlet UIView *pendingWOView;
@property (weak, nonatomic) IBOutlet UIButton *nCaseButton;

@property (strong, nonatomic) AMRelatedWOViewController *pendingWOVC;
@property (strong, nonatomic) AMWorkOrder *relatedWO;
@property (strong, nonatomic) AMPoS *assignedPOS;

@property (weak, nonatomic) IBOutlet UILabel *labelTPointOfServiceInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTPointOfServiceName;
@property (weak, nonatomic) IBOutlet UILabel *labelTMeiNumberName;
@property (weak, nonatomic) IBOutlet UILabel *labelTSegment;
@property (weak, nonatomic) IBOutlet UILabel *labelTNAM;
@property (weak, nonatomic) IBOutlet UILabel *labelTKAM;
@property (weak, nonatomic) IBOutlet UILabel *labelTBDM;
@property (weak, nonatomic) IBOutlet UILabel *labelTRoute;
@property (weak, nonatomic) IBOutlet UILabel *labelTDriverName;
@property (weak, nonatomic) IBOutlet UILabel *labelTNumberOfWork;

- (IBAction)clickCreateNewCaseBtn:(id)sender;

@end
