//
//  AMDetailTabViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/8/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDetailTabViewController.h"
#import "AMLabelCount.h"

@interface AMDetailTabViewController (){
    AMLabelCount *accountLabel;
    AMLabelCount *posLabel;
    AMLabelCount *caseLabel;
}

@end

@implementation AMDetailTabViewController

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

    [self.workOrderDetailBtn setImage:[UIImage imageNamed:MyImage(@"workOrder")] forState:UIControlStateNormal];
    [self.workOrderDetailBtn setImage:[UIImage imageNamed:MyImage(@"workOrder_selected")] forState:UIControlStateSelected];
 
    [self.accountButton setImage:[UIImage imageNamed:MyImage(@"account_1")] forState:UIControlStateNormal];
    [self.accountButton setImage:[UIImage imageNamed:MyImage(@"account")] forState:UIControlStateSelected];
    
    [self.posButton setImage:[UIImage imageNamed:MyImage(@"pos_icon_1")] forState:UIControlStateNormal];
    [self.posButton setImage:[UIImage imageNamed:MyImage(@"pos_icon")] forState:UIControlStateSelected];
    
    [self.locationButton setImage:[UIImage imageNamed:MyImage(@"location_icon_1")] forState:UIControlStateNormal];
    [self.locationButton setImage:[UIImage imageNamed:MyImage(@"location_icon")] forState:UIControlStateSelected];
    
    [self.contactButton setImage:[UIImage imageNamed:MyImage(@"contacts_icon")] forState:UIControlStateNormal];
    [self.contactButton setImage:[UIImage imageNamed:MyImage(@"contacts_icon_1")] forState:UIControlStateSelected];
    
    [self.assetsButton setImage:[UIImage imageNamed:MyImage(@"assets_icon")] forState:UIControlStateNormal];
    [self.assetsButton setImage:[UIImage imageNamed:MyImage(@"assets_icon_1")] forState:UIControlStateSelected];
    
    [self.casesButton setImage:[UIImage imageNamed:MyImage(@"cases_icon")] forState:UIControlStateNormal];
    [self.casesButton setImage:[UIImage imageNamed:MyImage(@"cases_icon_1")] forState:UIControlStateSelected];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedOnDetailTabs:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag;
    if (_selectedIndex == index) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectTabAtTabType:)]) {
        [self.delegate didSelectTabAtTabType:index];
        self.selectedIndex = index;
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    NSArray *subViews = [self.view subviews];
    for (id subView in subViews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subView;
            if (button.tag == selectedIndex) {
                [button setSelected:YES];
            } else {
                [button setSelected:NO];
            }
        }
    }
}

- (void)populateCountNumber:(AMWorkOrder *)workOrder
{
    if (workOrder) {
        if (!accountLabel) {
            accountLabel = [[AMLabelCount alloc] initWithCountNumber:[workOrder.woAccount.pendingWOList count]];
            [self.accountButton addSubview:accountLabel];
        }
        [accountLabel setCountNumber:[workOrder.woAccount.pendingWOList count]];
        
        if (!posLabel) {
            posLabel = [[AMLabelCount alloc] initWithCountNumber:[workOrder.woPoS.pendingWOList count]];
            [self.posButton addSubview:posLabel];
        }
        [posLabel setCountNumber:[workOrder.woPoS.pendingWOList count]];
        
        if (!caseLabel) {
            caseLabel = [[AMLabelCount alloc] initWithCountNumber:0];
            [self.casesButton addSubview:caseLabel];
        }
        [caseLabel setCountNumber:[[[AMLogicCore sharedInstance] getCaseOpenWorkOrderList:workOrder.caseID] count]];
    }
}


@end
