//
//  AMCasesViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMCasesViewController.h"

@interface AMCasesViewController ()

@end

@implementation AMCasesViewController

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
    _relatedWOVC = [[AMRelatedWOViewController alloc] initWithType:AMRelatedWOTypeCase sectionTitle:MyLocal(@"RELATED WO")];
    [self.relatedWOView addSubview:_relatedWOVC.view];
    
    self.labelTCaseInfo.text = MyLocal(@"Case Info");
    self.labelTCaseOwner.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case Owner")];
    self.labelTCaseNumber.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case Number")];
    self.labelTSubject.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Subject")];
    self.labelTDescription.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Description")];
    self.labelTPriority.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Priority")];
    self.labelTStatus.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Status")];
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
    self.relatedWOVC.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.relatedWOView.superview.frame)- 20, CGRectGetHeight(self.relatedWOView.frame));
}

- (void)setAssignedCase:(AMCase *)assignedCase
{
    if (_assignedCase && _assignedCase == assignedCase) {
        return;
    }
    _assignedCase = assignedCase;
    [self populateValue];
}

- (void)populateValue
{
    self.caseOwnerTF.text = _assignedCase.owner;
    self.caseNumberTF.text = _assignedCase.caseNumber;
    self.subjectTF.text = _assignedCase.subject;
    self.descriptionTF.text = _assignedCase.caseDescription;
    self.priorityTF.text = MyLocal(_assignedCase.priority);
    self.statusTF.text = MyLocal(_assignedCase.status);
    self.relatedWOVC.pendingWOArray = _assignedCase.woList;
}

- (void)reloadRelatedWorkOrders
{
    DLog(@"reloadRelatedWorkOrders called in Case VC");
    if (_relatedWOVC) {
        _assignedCase.woList = [[AMLogicCore sharedInstance] getCaseWorkOrderList:_assignedCase.caseID];
        _relatedWOVC.pendingWOArray = _assignedCase.woList;
    }
}


@end
