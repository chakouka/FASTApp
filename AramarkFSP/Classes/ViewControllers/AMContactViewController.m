//
//  AMContactViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMContactViewController.h"
#import "AMContactBlockViewController.h"
#import "AMContact.h"

@interface AMContactViewController ()

@end

@implementation AMContactViewController

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
    self.contactBlockArr = [NSMutableArray array];
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
    self.scrollContentView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.scrollContentView.frame));
    [self.scrollView setContentSize:self.scrollContentView.bounds.size];
    for (UIView *view in [self.scrollContentView subviews]) {
        CGRect tempRect = view.frame;
        tempRect.size.width = CGRectGetWidth(self.scrollContentView.frame);
        view.frame = tempRect;
    }
}

- (void)setContactArr:(NSArray *)contactArr
{
    if (contactArr == _contactArr) {
        return;
    }
    _contactArr = contactArr;
    for (UIView *view in [self.scrollContentView subviews]) {
        [view removeFromSuperview];
    }
    [self.contactBlockArr removeAllObjects];
    for (int i=0; i < [contactArr count]; i++) {
        AMContact *contact = [contactArr objectAtIndex:i];
        AMContactBlockViewController *blockVC = [[AMContactBlockViewController alloc] initWithContact:contact];
        blockVC.contactNoLabel.text = [NSString stringWithFormat:@"%i", i+1];
        blockVC.view.frame = CGRectMake(0.0, i*CGRectGetHeight(blockVC.view.frame), CGRectGetWidth(blockVC.view.frame), CGRectGetHeight(blockVC.view.frame));
        [self.scrollContentView addSubview:blockVC.view];
        [self.contactBlockArr addObject:blockVC];
    }
}

@end
