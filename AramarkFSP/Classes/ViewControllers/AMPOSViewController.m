//
//  AMPOSViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/14/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

/********************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM00116: Display MEI Number. By Hari Kolasani. 12/9/2014
 ********************************************************************************/

#import "AMPOSViewController.h"
#import "AMAddNewCaseViewController.h"

@interface AMPOSViewController ()
<
AMNewCaseViewControllerDelegate
>
{
    AMAddNewCaseViewController *addNewCaseVC;
}

@property (strong, nonatomic) AMDBNewCase *aNewCase;

@end

@implementation AMPOSViewController
@synthesize aNewCase;

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
    [self.nCaseButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    _pendingWOVC = [[AMRelatedWOViewController alloc] initWithType:AMRelatedWOTypePOS sectionTitle:nil];
    _pendingWOVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.pendingWOView.frame), CGRectGetHeight(self.pendingWOView.frame));
    [self.pendingWOView addSubview:_pendingWOVC.view];
    
    //CHANGE:ITEM00116
    //self.labelTPointOfServiceInfo.text = MyLocal(@"Point of Service Info");
    //self.labelTPointOfServiceName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Point of Service Name")];
    self.labelTPointOfServiceName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"MEI Number")];
    self.labelTMeiNumberName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"MEI Number")];
    self.labelTSegment.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Segment")];
    self.labelTNAM.text = [NSString stringWithFormat:@"%@:",MyLocal(@"NAM")];
    self.labelTKAM.text = [NSString stringWithFormat:@"%@:",MyLocal(@"KAM")];
    self.labelTBDM.text = [NSString stringWithFormat:@"%@:",MyLocal(@"BDM")];
    self.labelTRoute.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Route")];
    self.labelTDriverName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Driver Name")];
    self.labelTNumberOfWork.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Number of Work Orders in the Past 28 Days")];
    
    MyButtonTitle(self.nCaseButton, MyLocal(@"NEW CASE"));
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
    self.pendingWOVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.pendingWOView.superview.frame)- 20, CGRectGetHeight(self.pendingWOVC.view.frame));
    
}

- (void)setAssignedPOS:(AMPoS *)assignedPOS
{
    _assignedPOS = assignedPOS;
    //CHANGE:ITEM00116
    self.labelTPointOfServiceInfo.text = assignedPOS.name;
    //self.posNameLbl.text = assignedPOS.name;
    self.posNameLbl.text = assignedPOS.meiNumber;
    self.meiNumberLbl.text = assignedPOS.meiNumber;
    self.segmentLbl.text = assignedPOS.segment;
    self.NAMLbl.text = assignedPOS.nam;
    self.KAMLbl.text = assignedPOS.kam;
    self.BDMLbl.text = assignedPOS.bdm;
    self.routeNumberLbl.text = assignedPOS.routeLookupName; //replaced with Route
    self.deiverNameLbl.text = assignedPOS.driverName;
    self.workOrderCountLbl.text = [assignedPOS.past28WOCount stringValue];
    _pendingWOVC.pendingWOArray = assignedPOS.pendingWOList;
}

- (void)reloadRelatedWorkOrders
{
    DLog(@"reloadRelatedWorkOrders called in POS VC");
    if (_pendingWOVC) {
        _assignedPOS.pendingWOList = [[AMLogicCore sharedInstance] getPoSPendingWorkOrderList:_assignedPOS.posID];
        _pendingWOVC.pendingWOArray = _assignedPOS.pendingWOList;
    }
}

- (IBAction)clickCreateNewCaseBtn:(id)sender {
    
    AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:_assignedPOS.posID];
    
    if (!pos) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Point of Service can not be nil")];
        return ;
    }
    
    addNewCaseVC = [[AMAddNewCaseViewController alloc] initWithNibName:@"AMAddNewCaseViewController" bundle:nil];
    addNewCaseVC.delegate = self;
    addNewCaseVC.isPop = YES;
    addNewCaseVC.source = AddNewCasePageSource_PoS;
    addNewCaseVC.strPoSId = _assignedPOS.posID;
    addNewCaseVC.strAccountId = _relatedWO.accountID;
    addNewCaseVC.strMEICustomer = _assignedPOS.meiNumber;
    addNewCaseVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:addNewCaseVC animated:YES completion:nil];
}

- (void)didClickSaveNewCase:(BOOL)success
{
    //    [addNewCaseVC dismissViewControllerAnimated:YES completion:nil];
}
@end
