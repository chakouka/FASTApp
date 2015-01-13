//
//  AMCasesViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"
#import "AMRelatedWOViewController.h"
#import "AMCase.h"

@interface AMCasesViewController : AMWOTabBaseViewController
@property (weak, nonatomic) IBOutlet UIView *relatedWOView;
@property (strong, nonatomic) AMRelatedWOViewController *relatedWOVC;
@property (weak, nonatomic) IBOutlet UITextField *caseOwnerTF;
@property (weak, nonatomic) IBOutlet UITextField *caseNumberTF;
@property (weak, nonatomic) IBOutlet UITextField *subjectTF;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTF;
@property (weak, nonatomic) IBOutlet UITextField *priorityTF;
@property (weak, nonatomic) IBOutlet UITextField *statusTF;

@property (weak, nonatomic) IBOutlet UILabel *labelTCaseInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTCaseOwner;
@property (weak, nonatomic) IBOutlet UILabel *labelTCaseNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelTSubject;
@property (weak, nonatomic) IBOutlet UILabel *labelTDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelTPriority;
@property (weak, nonatomic) IBOutlet UILabel *labelTStatus;


@property (strong, nonatomic) AMCase *assignedCase;

@end
