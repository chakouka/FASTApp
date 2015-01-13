//
//  AMContactBlockViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMContactBlockViewController.h"

@interface AMContactBlockViewController ()

@end

@implementation AMContactBlockViewController

- (id)initWithContact:(AMContact *)contact
{
    if (self = [self initWithNibName:NSStringFromClass([AMContactBlockViewController class]) bundle:nil]) {
        self.assignedContact = contact;
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
    //set font
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([[subview subviews] count] > 0) {
            for (UIView *sv in [subview subviews]) {
                if ([sv isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)sv;
                    [label setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
                }
            }
        }
    }
    
    // Do any additional setup after loading the view.
    self.nameTextField.text = self.assignedContact.name;
    self.roleTextField.text = self.assignedContact.role;
    self.phoneTextField.text = self.assignedContact.phone;
    self.emailTextField.text = self.assignedContact.email;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (IBAction)collapseButtonTapped:(id)sender {
   [self.collapseButton setSelected:!self.collapseButton.selected];
}

//- (void)setAssignedContact:(AMContact *)assignedContact
//{
//    _assignedContact = assignedContact;
//}

@end
