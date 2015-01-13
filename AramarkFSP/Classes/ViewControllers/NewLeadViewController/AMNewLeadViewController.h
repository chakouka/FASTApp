//
//  AMNewLeadViewController.h
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AMNewLeadViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewMain;
@property (weak, nonatomic) IBOutlet UIView *viewAddNewPanel;
@property (weak, nonatomic) IBOutlet UIButton *btnHistory;
@property (weak, nonatomic) IBOutlet UIButton *btnAddNew;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIImageView *imageDivCancel;

- (void)refreshNewLeadView;
- (IBAction)clickHistoryBtn:(UIButton *)sender;
- (IBAction)clickCancelBtn:(UIButton *)sender;
- (IBAction)clickAddBtn:(UIButton *)sender;

@end
