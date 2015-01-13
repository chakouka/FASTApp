//
//  AMSectionHeaderView.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMPopoverSelectTableViewController.h"

@protocol AMSectionHeaderViewDelegate;
@interface AMSectionHeaderView : UIView<AMPopoverSelectTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *buttonDropDown;
@property (weak, nonatomic) IBOutlet UILabel *labelSectionTitle;
@property (weak, nonatomic) IBOutlet UIButton *recordTypeButton;

@property (strong, nonatomic) UIPopoverController *popoverCon;

@property (weak, nonatomic) id<AMSectionHeaderViewDelegate> delegate;

@property (nonatomic) BOOL isExpanded;

@end

@protocol AMSectionHeaderViewDelegate <NSObject>

- (void)didTappedOnPopoverRecordType:(NSString *)recordType;

- (void)didCancelCreatingNewWO;

@end
