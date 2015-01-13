//
//  AMWOTabBaseViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMWOTabBaseViewController.h"

@interface AMWOTabBaseViewController ()

@end

@implementation AMWOTabBaseViewController

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
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRelatedWorkOrders) name:NOTIFICATION_RELOAD_RELATED_WORKORDER_LIST object:nil];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RELOAD_RELATED_WORKORDER_LIST object:nil];
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

#pragma Private Methods
- (void)keyboardDidShow
{
    
}

- (void)keyboardDidHidden
{
    
}

//should overwrite this method in sub class if need reload data
- (void)reloadRelatedWorkOrders
{
    
}

@end
