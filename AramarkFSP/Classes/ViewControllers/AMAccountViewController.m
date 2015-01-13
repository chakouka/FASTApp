//
//  AMAccountViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/14/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAccountViewController.h"
#import "AMAddNewCaseViewController.h"

@interface AMAccountViewController ()
<
AMNewCaseViewControllerDelegate
>
{
    NSDateFormatter *df;
    AMAddNewCaseViewController *addNewCaseVC;
    
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) AMDBNewCase *aNewCase;

@end

@implementation AMAccountViewController
@synthesize aNewCase;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.nCaesButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0]];
    _pendingWOVC = [[AMRelatedWOViewController alloc] initWithType:AMRelatedWOTypeAccount sectionTitle:nil];
    [self.pendingWOView addSubview:_pendingWOVC.view];
    [self.nationalAccountButton setUserInteractionEnabled:NO];
    df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:AMDATE_FORMATTER_STRING_STANDARD];
    
    self.labelTAccountInfo.text = MyLocal(@"Account Info");
    self.labelTAccountName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Account Name")];
    self.labelTParentAccount.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Parent Account")];
    self.labelTNationalAccount.text = [NSString stringWithFormat:@"%@:",MyLocal(@"National Account")];
    self.labelTKeyAccount.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Key Account")];
    self.labelTNationalAccountName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"National Account Name")];
    self.labelTAccountAtRisk.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Account At Risk")];
    self.labelTAtRistReason.text = [NSString stringWithFormat:@"%@:",MyLocal(@"At Risk Reason")];
    self.labelTSalesConsultant.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Sales Consultant")];
}


- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.superview.frame), CGRectGetHeight(self.view.frame));
    self.pendingWOVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.pendingWOView.superview.frame)- 20, CGRectGetHeight(self.pendingWOVC.view.superview.frame));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setAssignedAccount:(AMAccount *)assignedAccount
{
    _assignedAccount = assignedAccount;
    self.accountNameTF.text = assignedAccount.name;
    self.parentAccountTF.text = assignedAccount.parentAccount;
    [self.nationalAccountButton setSelected:[assignedAccount.isNationalAccount isEqualToNumber:@(1)] ? YES : NO];
    self.nationalAccountName.text = assignedAccount.nationalAccount;
    [self.keyAccountButton setSelected:[assignedAccount.keyAccount isEqualToNumber:@(1)] ? YES : NO];
    self.accountAtRiskTF.text = assignedAccount.atRisk ? [df stringFromDate:assignedAccount.atRisk] : @"";
    self.atRiskReason.text = assignedAccount.atRiskReason;
//    self.NAMTF.text = assignedAccount.nam;
//    self.KAMTF.text = assignedAccount.kam;
    self.salesConsulantTF.text = assignedAccount.fspSalesConsultant;
    _pendingWOVC.pendingWOArray = assignedAccount.pendingWOList;
}

#pragma Private Methods
- (void)reloadRelatedWorkOrders
{
    DLog(@"reloadRelatedWorkOrders called in Account VC");
//    [self performSelector:@selector(reloadWOList) withObject:nil afterDelay:0.5];
    if (_pendingWOVC) {
        _assignedAccount.pendingWOList = [[AMLogicCore sharedInstance] getAccountPendingWorkOrderList:_assignedAccount.accountID];
        _pendingWOVC.pendingWOArray = _assignedAccount.pendingWOList;
    }
}

- (IBAction)clickNewCaseBtn:(UIButton *)sender {
    AMAccount *account = [[AMLogicCore sharedInstance] getAccountInfoByID:_assignedAccount.accountID];
    
    if (!account) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Account can not be nil")];
        return ;
    }
    
      AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:_relatedWOPoS.posID];
    
    if (!pos) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Point of Service can not be nil")];
        return ;
    }
    
    addNewCaseVC = [[AMAddNewCaseViewController alloc] initWithNibName:@"AMAddNewCaseViewController" bundle:nil];
    addNewCaseVC.delegate = self;
    addNewCaseVC.isPop = YES;
    addNewCaseVC.source = AddNewCasePageSource_Account;
    addNewCaseVC.strAccountId = _assignedAccount.accountID;
    
    addNewCaseVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:addNewCaseVC animated:YES completion:nil];
}

- (void)didClickSaveNewCase:(BOOL)success
{
//    [addNewCaseVC dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
