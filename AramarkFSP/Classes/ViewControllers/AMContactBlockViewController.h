//
//  AMContactBlockViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMContact.h"

@interface AMContactBlockViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *contactNoLabel;
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *roleTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@property (strong, nonatomic) AMContact *assignedContact;

- (id)initWithContact:(AMContact *)contact;

@end
