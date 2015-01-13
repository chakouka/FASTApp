//
//  AMUpdateSiteSurveyViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/3/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMUpdateSiteSurveyViewController.h"
#import "AMProtocolManager.h"

@interface AMUpdateSiteSurveyViewController (){
    NSDateFormatter *df;
    UIPopoverController *aPopoverVC; //Electric Outlet Type
    UIPopoverController *bPopoverVC; //Elevator or Stairs
}

@end

@implementation AMUpdateSiteSurveyViewController

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
    self.addtionalNoteParentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.addtionalNoteParentView.layer.borderWidth = 1.0;
    self.specialInstructionParentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.specialInstructionParentView.layer.borderWidth = 1.0;
    // Do any additional setup after loading the view from its nib.
    self.addtionalNoteTA.delegate = self;
    self.specialInstructionTV.delegate = self;
    self.cabinetHeightTF.delegate = self;
    self.doorwayWidthTF.delegate = self;
    self.elevatorSizeTF.delegate = self;
    self.roomMeasurementTF.delegate = self;
    self.siteSurveyDateTF.delegate = self;//set current date by default
    self.typtOfFlooringTF.delegate = self;
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:AMDATE_FORMATTER_STRING_DEFAULT];
//    self.siteSurveyDateTF.text = [df stringFromDate:[NSDate date]];
    [self.submitButton.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:17.0]];
    
    MyButtonTitle(self.submitButton, MyLocal(@"SUBMIT"));
    
    self.labelTAddtionalNote.text = MyLocal(@"Additional Notes");
    self.labelTBadgeNeeded.text = MyLocal(@"Badge Needed for Access?");
    self.labelTCabinetHeight.text = MyLocal(@"Cabinet Height(Inches)?");
    self.labelTDockAvailable.text = MyLocal(@"Dock Available?");
    self.labelTDoorsToBeRemoved.text = MyLocal(@"Doors to be Removed for Vending Equip?");
    self.labelTDoorwayWidth.text = MyLocal(@"Doorway Width [inches]");
    self.labelTElectricOutlet.text = MyLocal(@"Electric Outlet Type");
    self.labelTEletricityWithin.text = MyLocal(@"Eletricity Within 3ft?");
    self.labelElevatorOrStairs.text = MyLocal(@"Elevator or Stairs?");
    self.labelTElevatorSize.text = MyLocal(@"Elevator Size [feet]");
    self.labelTFrightElevator.text = MyLocal(@"Freight Elevator Available?");
    self.labelTPersonalProtection.text = MyLocal(@"Personal Protection Equipment Required?");
    self.labelTRequiredElectrical.text = MyLocal(@"Required Electrical in Place?");
    self.labelTRequiresVisitByService.text = MyLocal(@"Requires Visit by Service Department?");
    self.labelTSiteLevelAndLighted.text = MyLocal(@"Site Level and Lighted?");
    self.labelTSiteSurveyDate.text = MyLocal(@"Site Survey Date");
    self.labelTRoomMeasurement.text = MyLocal(@"Room Measurement for Equipment");
    self.labelTSpecificSafety.text = MyLocal(@"Specific Safety Training Required?");
    self.labelTTypeOfFlooring.text = MyLocal(@"Type of Flooring");
    self.labelTWaterSource.text = MyLocal(@"Water Source within 10ft?");
    self.labelTSpecialInstruction.text = MyLocal(@"Special Instruction/Notes");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Private Methods
- (void)populateValue:(AMLocation *)location
{
    //UITextView
    self.addtionalNoteTA.text = location.addtionalNotes;
    self.specialInstructionTV.text = location.specialNotes;
    //UIButton
    [self.badgeNeededBtn setSelected:[location.badgeNeeded boolValue]];
    [self.dockAvailableButton setSelected:[location.dockAvailable boolValue]];
    [self.doorToBeRemovedBtn setSelected:[location.doorsRemoved boolValue]];
    [self.eletricityWith3ftBtn setSelected:[location.electricity3ft boolValue]];
    [self.freightElevatorAvailableBtn setSelected:[location.freightElevator boolValue]];
    [self.PersonalProBtn setSelected:[location.personalProtection boolValue]];
    [self.RequiredEletricalBtn setSelected:[location.electricalInPlace boolValue]];
    [self.requiredVisitBtn setSelected:[location.visitByServiceDep boolValue]];
    [self.siteLevelBtn setSelected:[location.siteLevel boolValue]];
    [self.wateSourceBtn setSelected:[location.waterSource boolValue]];
    [self.specificSafetyTrainingReqedBtn setSelected:[location.safetyTraining boolValue]];
    //UITextField
    self.cabinetHeightTF.text = [location.cabinetHeight stringValue];
    self.doorwayWidthTF.text = [location.doorwayWidth stringValue];
    self.elevatorSizeTF.text = [location.elevatorSize stringValue];
    self.siteSurveyDateTF.text = location.siteSurveyDate ? [df stringFromDate:location.siteSurveyDate] : [df stringFromDate:[NSDate date]];
    self.location.siteSurveyDate = [df dateFromString:self.siteSurveyDateTF.text];
    self.roomMeasurementTF.text = [location.roomMeasurement stringValue];
    //dropDown
    self.electricOutletTypeLabel.text = location.electricOutlet;
    self.elevatorOrStairLabel.text = [location.elevatorStairs length] == 0 ? @"" : MyLocal(location.elevatorStairs);
    self.typtOfFlooringTF.text = location.typeFlooring;
    
}

#pragma Setter/Getter
- (void)setLocation:(AMLocation *)location
{
    _location = location;
    [self populateValue:location];
}

#pragma Target-Action
//This method should be called checkboxTapped, will make more sense
- (IBAction)badgeNeededButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setSelected:!button.selected];
    NSNumber *numberValue = [NSNumber numberWithBool:button.selected];
    if (button == self.badgeNeededBtn) {
        self.location.badgeNeeded = numberValue;
    } else if (button == self.dockAvailableButton) {
        self.location.dockAvailable = numberValue;
    } else if (button == self.doorToBeRemovedBtn) {
        self.location.doorsRemoved = numberValue;
    } else if (button == self.eletricityWith3ftBtn) {
        self.location.electricity3ft = numberValue;
    } else if (button == self.freightElevatorAvailableBtn) {
        self.location.freightElevator = numberValue;
    } else if (button == self.PersonalProBtn) {
        self.location.personalProtection = numberValue;
    } else if (button == self.RequiredEletricalBtn) {
        self.location.electricalInPlace = numberValue;
    } else if (button == self.requiredVisitBtn) {
        self.location.visitByServiceDep = numberValue;
    } else if (button == self.siteLevelBtn) {
        self.location.siteLevel = numberValue;
    } else if (button == self.wateSourceBtn) {
        self.location.waterSource = numberValue;
    } else if (button == self.specificSafetyTrainingReqedBtn) {
        self.location.safetyTraining = numberValue;
    }
}

- (IBAction)electricOutletTypeDropdownTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.arrInfos = [self popoverContentArrWithType:AMPopoverTypeElectricOutletType];
    if (!aPopoverVC) {
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
    }
    //	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (NSMutableArray *)popoverContentArrWithType:(AMPopoverType)popoverType
{
    NSMutableArray *arr;
    switch (popoverType) {
        case AMPopoverTypeElectricOutletType:
            arr = [NSMutableArray arrayWithArray:@[@{kAMPOPOVER_DICTIONARY_KEY_INFO: @"110V"}, @{kAMPOPOVER_DICTIONARY_KEY_INFO: @"220V"}]];
            break;
         
        case AMPopoverTypeElevatorOrStair:
            arr = [NSMutableArray arrayWithArray:@[
                  @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"Elevator"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"Elevator"},
                  @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"Stairs"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"Stairs"},
                  @{kAMPOPOVER_DICTIONARY_KEY_INFO: MyLocal(@"Both"),kAMPOPOVER_DICTIONARY_KEY_VALUE: @"Both"},
                  @{kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"None"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"None"}]
                   ];
            break;
            
        default:
            break;
    }

    return arr;
}

- (IBAction)elevatorOrStairTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (!bPopoverVC) {
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.arrInfos = [self popoverContentArrWithType:AMPopoverTypeElevatorOrStair];
        bPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [bPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
    }
    //	aPopoverVC.delegate = self;
	[bPopoverVC presentPopoverFromRect:button.frame inView:button.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (IBAction)submitBtnTapped:(id)sender {
    [[AMLogicCore sharedInstance] updateLocation:self.location completionBlock:^(NSInteger type, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [SVProgressHUD showErrorWithStatus:MyLocal(@"Save Fail")];
            } else {
                [SVProgressHUD showSuccessWithStatus:MyLocal(@"Save Success")];
                if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnSubmit:)]) {
                    [self.delegate performSelector:@selector(didTappedOnSubmit:) withObject:error];
                }
            }
        });
    }];
}

#pragma AMPopoverSelectTableViewControllerDelegate
- (void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray
{
    if (aPopoverVC.popoverVisible) {
        NSString *selectedStr = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        self.electricOutletTypeLabel.text = selectedStr;
        self.location.electricOutlet = selectedStr;
        [aPopoverVC dismissPopoverAnimated:YES];
    } else if (bPopoverVC.popoverVisible) {
        NSString *selectedStr = [[aArray objectAtIndex:aIndex] objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
        self.elevatorOrStairLabel.text = selectedStr;
        self.location.elevatorStairs = selectedStr;
        [bPopoverVC dismissPopoverAnimated:YES];
    }
}

#pragma UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTING_EDITING_MODE object:nil];
    if (textField == self.doorwayWidthTF) {
        [AMUtilities animateView:self.view direction:AnimationDirectionUp distance:100.0];
    } else if (textField == self.elevatorSizeTF) {
        [AMUtilities animateView:self.view direction:AnimationDirectionUp distance:250.0];
    } else if (textField == self.roomMeasurementTF) {
        [AMUtilities animateView:self.view direction:AnimationDirectionUp distance:350.0];
    } else if (textField == self.typtOfFlooringTF) {
        [AMUtilities animateView:self.view direction:AnimationDirectionUp distance:350.0];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *numberValue = [nf numberFromString:textField.text];
    if (textField == self.cabinetHeightTF) {
        self.location.cabinetHeight = numberValue;
    } else if (textField == self.doorwayWidthTF) {
        self.location.doorwayWidth = numberValue;
        if (textField == self.doorwayWidthTF) {
            [AMUtilities animateView:self.view direction:AnimationDirectionDown distance:100.0];
        }
    } else if (textField == self.elevatorSizeTF) {
        self.location.elevatorSize = numberValue;
        [AMUtilities animateView:self.view direction:AnimationDirectionDown distance:250.0];
    } else if (textField == self.roomMeasurementTF) {
        self.location.roomMeasurement = numberValue;
        [AMUtilities animateView:self.view direction:AnimationDirectionDown distance:350.0];
    } else if (textField == self.typtOfFlooringTF) {
        self.location.typeFlooring = textField.text;
        [AMUtilities animateView:self.view direction:AnimationDirectionDown distance:350.0];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.cabinetHeightTF || textField == self.doorwayWidthTF || textField == self.elevatorSizeTF)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        BOOL isValid;
        if ([newString length] == 0) {
            isValid = YES;
        } else {
            isValid = [AMUtilities isValidIntegerValueTyped:newString];
        }
        if (isValid) {
            if ([textField.text isEqualToString:@"0"]) {
                textField.text = @"";
            }
        }
        return isValid && [newString length] <= 3;
    } else if (textField == self.roomMeasurementTF) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        BOOL isValid;
        if ([newString length] == 0) {
            isValid = YES;
        } else {
            isValid = [AMUtilities isValidFloatingValueTyped:newString];
        }
        if (isValid) {
            if ([textField.text isEqualToString:@"0"]) {
                textField.text = @"";
            }
        }
        return isValid && [newString length] <= 7;
    }
    
    return YES;
}

#pragma UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.specialInstructionTV) {
        [AMUtilities animateView:self.view direction:AnimationDirectionUp distance:350.0];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView == self.addtionalNoteTA) {
        self.location.addtionalNotes = textView.text;
    } else if (textView == self.specialInstructionTV) {
        self.location.specialNotes = textView.text;
        [AMUtilities animateView:self.view direction:AnimationDirectionDown distance:350.0];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView == self.addtionalNoteTA || textView == self.specialInstructionTV) {
        NSString *textString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        return [textString length] < 255;
    }
    return YES;
}
@end
