//
//  AMCheckoutTabViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMCheckoutTabViewController.h"

@interface AMCheckoutTabViewController ()

@end

@implementation AMCheckoutTabViewController
@synthesize delegate;
@synthesize checkOutSetp;

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
    
    [self.checkoutButton setImage:[UIImage imageNamed:MyImage(@"verification")] forState:UIControlStateNormal];
    [self.checkoutButton setImage:[UIImage imageNamed:MyImage(@"verification_ON")] forState:UIControlStateSelected];
    
    [self.assetsButton setImage:[UIImage imageNamed:MyImage(@"10-point")] forState:UIControlStateNormal];
    [self.assetsButton setImage:[UIImage imageNamed:MyImage(@"10-point_ON")] forState:UIControlStateSelected];
    
    [self.pointsButton setImage:[UIImage imageNamed:MyImage(@"1--check-out_OFF")] forState:UIControlStateNormal];
    [self.pointsButton setImage:[UIImage imageNamed:MyImage(@"1--check-out")] forState:UIControlStateSelected];
    
    [self.invoiceButton setImage:[UIImage imageNamed:MyImage(@"invoice")] forState:UIControlStateNormal];
    [self.invoiceButton setImage:[UIImage imageNamed:MyImage(@"invoice_on")] forState:UIControlStateSelected];
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
    
    if (delegate && [delegate respondsToSelector:@selector(didSelectCheckoutTabAtTabType:)]) {
        [delegate didSelectCheckoutTabAtTabType:index];
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

- (void)setCheckOutSetp:(AMCheckoutTabType)aCheckOutSetp
{
    self.checkoutButton.enabled = NO;
    self.assetsButton.enabled = NO;
    self.pointsButton.enabled = NO;
    self.invoiceButton.enabled = NO;
    
    checkOutSetp = aCheckOutSetp;
    switch (checkOutSetp) {
        case AMCheckoutTabType_Verification:
        {
            self.checkoutButton.enabled = YES;
        }
            break;
        case AMCheckoutTabType_Points:
        {
            self.checkoutButton.enabled = YES;
            self.assetsButton.enabled = YES;
        }
            break;
        case AMCheckoutTabType_Checkout:
        {
            self.checkoutButton.enabled = YES;
            self.assetsButton.enabled = YES;
            self.pointsButton.enabled = YES;
        }
            break;
        case AMCheckoutTabType_Invoice:
        {
            self.checkoutButton.enabled = NO;
            self.assetsButton.enabled = NO;
            self.pointsButton.enabled = NO;
            self.invoiceButton.enabled = YES;
        }
            break;
        default:
            break;
    }
}

@end
