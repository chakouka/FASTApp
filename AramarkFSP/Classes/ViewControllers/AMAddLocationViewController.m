//
//  AMAddLocationViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAddLocationViewController.h"

@interface AMAddLocationViewController (){
    BOOL isMovedInPortrait;
    CGFloat offset;
}

@end

@implementation AMAddLocationViewController

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
    self.locationNameTextField.delegate = self;
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == 10001) {
            for (UIView *btnV in [subview subviews]) {
                if ([btnV isKindOfClass:[UIButton class]]) {
                    UIButton *b = (UIButton *)btnV;
                    [b.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
                }
            }
        } else if (subview.tag == 10002) {
            for (UIView *sv in [subview subviews]) {
                if ([sv isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)sv;
                    [label setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
                } else if ([sv isKindOfClass:[UIButton class]]) {
                    UIButton *b = (UIButton *)sv;
                    [b.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
                } else if ([sv isKindOfClass:[UITextField class]]) {
                    UITextField *tf = (UITextField *)sv;
                    [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
                }
            }
        }
    }
    
    NSString *strT = [NSString stringWithFormat:@"   %@",MyLocal(@"Add Location")];
    MyButtonTitle(self.addLocationButton,strT);
    
    [self.addLocationButton setTitle:[NSString stringWithFormat:@"   %@",MyLocal(@"Cancel")] forState:UIControlStateSelected];
    
    MyButtonTitle(self.btnAdd, MyLocal(@"ADD"));
    self.labelTLocationName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Location Name")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addLocationTapped:(id)sender { //Tap on Add Loaction Button
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    [self.bottomView setHidden:!button.selected];
    [self.locationNameTextField resignFirstResponder];
}

- (IBAction)addButtonTapped:(id)sender {//Tap to Save new location
    if ([self.locationNameTextField.text length] <= 0) {
        return;
    }
    NSString *trimmedStr = [self.locationNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedStr length] == 0) {
//        [SVProgressHUD showErrorWithStatus:MyLocal(@"Please add valid location") duration:2.0];
        [AMUtilities showAlertWithInfo:MyLocal(@"Please add valid location")];
        self.locationNameTextField.text = @"";
        return;
    }
    AMLocation *newLocation = [AMLocation new];
    [newLocation setLocation:self.locationNameTextField.text];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapOnSaveLocation:)]) {
        [self.delegate performSelector:@selector(didTapOnSaveLocation:) withObject:newLocation];
        [self addLocationTapped:self.addLocationButton];
        self.locationNameTextField.text = @"";
        [self.locationNameTextField resignFirstResponder];
    }
}

#pragma UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGFloat originMaxY = CGRectGetMaxY(self.view.frame);
    offset = originMaxY - 230.0; //230.0 means almost the height of parent scroll view / 2
    if (offset > 330.0) {
        offset = 330.0;
    }
    isMovedInPortrait = offset > 0.0 ? YES : NO;
    if (isMovedInPortrait && textField == self.locationNameTextField) {
        [AMUtilities animateView:self.view direction:AnimationDirectionUp distance:offset];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTING_EDITING_MODE object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (isMovedInPortrait && textField == self.locationNameTextField) {
        [AMUtilities animateView:self.view direction:AnimationDirectionDown distance:offset];
    }
}

@end
