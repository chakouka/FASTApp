//
//  AMPopoverViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWOPopoverViewController.h"

@interface AMWOPopoverViewController (){
    NSDateFormatter *df;
}

@end

@implementation AMWOPopoverViewController

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
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subview;
            [btn.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0]];
        }
    }
    switch (self.popoverType) {
        case AMRelatedWOTypeAccount:
            [self.assignToSelf setHidden:NO];
            [self.assignToLabel setHidden:YES];
            [self.assignToTitleLabel setHidden:YES];
            self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 135);
            break;
            
        case AMRelatedWOTypePOS:
            [self.assignToSelf setHidden:NO];
            [self.assignToLabel setHidden:YES];
            [self.assignToTitleLabel setHidden:YES];
            self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 135);
            break;
            
        case AMRelatedWOTypeAsset:
            [self.assignToSelf setHidden:YES];
            [self.assignToLabel setHidden:YES];
            [self.assignToTitleLabel setHidden:YES];
            self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 100);
            break;
        
        case AMRelatedWOTypeCase:
        {
            [self.assignToSelf setHidden:YES];
            [self.assignToLabel setHidden:NO];
            [self.assignToTitleLabel setHidden:NO];
            self.view.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), 135.0);
        }
            break;
        default:
            
            break;
    }
    
    self.labelTWo.text = MyLocal(@"WO #");
    self.labelTDescription.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Description")];
    self.labelTDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Date")];
    self.labelTAssigned.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Assigned To")];
    [self.assignToSelf setTitle:MyLocal(@"Assign to My Self") forState:UIControlStateNormal];
    [self.assignToSelf setTitle:MyLocal(@"Assign to My Self") forState:UIControlStateHighlighted];
}

- (void)setWorkOrder:(AMWorkOrder *)workOrder
{
    _workOrder = workOrder;
    [self populateValue];
    
    NSString *loggedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USRDFTSELFUID];
    if ([self.workOrder.ownerID isEqualToString:loggedUserId]) {
        [self.assignToSelf setEnabled:NO];
    } else {
        [self.assignToSelf setEnabled:YES];
    }
}

- (void)populateValue
{
    self.woNumberLabel.text = _workOrder.woNumber;
    self.descriptionLabel.text = _workOrder.workOrderDescription;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:AMDATE_FORMATTER_STRING_DEFAULT];
    }
    self.dateLabel.text = [df stringFromDate:_workOrder.createdDate];
    self.assignToLabel.text = _workOrder.ownerName;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)assignToMyselfTapped:(id)sender {
    [[AMLogicCore sharedInstance] assignWorkOrderToSelf:self.workOrder completionBlock:^(NSInteger type, NSError *error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(assignToMyselfTapped:)]) {
            [self.delegate performSelector:@selector(assignToMyselfTapped:) withObject:error];
        }
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dismissPopover)]) {
        [self.delegate performSelector:@selector(dismissPopover) withObject:nil];
    }
}

@end
