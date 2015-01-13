//
//  AMAccountViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/14/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"
#import "AMRelatedWOViewController.h"
#import "AMAccount.h"
#import "AMPoS.h"

@interface AMAccountViewController : AMWOTabBaseViewController
@property (weak, nonatomic) IBOutlet UIView *pendingWOView;
@property (strong, nonatomic) AMRelatedWOViewController *pendingWOVC;

@property (strong, nonatomic) AMAccount *assignedAccount;
@property (strong, nonatomic) AMPoS *relatedWOPoS;
@property (weak, nonatomic) IBOutlet UITextField *parentAccountTF;
@property (weak, nonatomic) IBOutlet UITextField *accountNameTF;
@property (weak, nonatomic) IBOutlet UIButton *nationalAccountButton;
@property (weak, nonatomic) IBOutlet UITextField *nationalAccountName;
@property (weak, nonatomic) IBOutlet UIButton *keyAccountButton;
//@property (weak, nonatomic) IBOutlet UITextField *NAMTF;
//@property (weak, nonatomic) IBOutlet UITextField *KAMTF;
@property (weak, nonatomic) IBOutlet UITextField *salesConsulantTF;
@property (weak, nonatomic) IBOutlet UITextField *accountAtRiskTF;
@property (weak, nonatomic) IBOutlet UITextField *atRiskReason;
@property (weak, nonatomic) IBOutlet UIButton *nCaesButton;

@property (weak, nonatomic) IBOutlet UILabel *labelTAccountName;
@property (weak, nonatomic) IBOutlet UILabel *labelTParentAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelTNationalAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelTKeyAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelTNationalAccountName;
@property (weak, nonatomic) IBOutlet UILabel *labelTAccountAtRisk;
@property (weak, nonatomic) IBOutlet UILabel *labelTAtRistReason;
@property (weak, nonatomic) IBOutlet UILabel *labelTSalesConsultant;
@property (weak, nonatomic) IBOutlet UILabel *labelTAccountInfo;


@end
