//
//  AMPopoverViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWorkOrder.h"

@protocol AMWOPopoverViewControllerDelegate;
@interface AMWOPopoverViewController : UIViewController

@property (strong, nonatomic) AMWorkOrder *workOrder;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *woNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *assignToSelf;
@property (weak, nonatomic) IBOutlet UILabel *assignToLabel;
@property (weak, nonatomic) IBOutlet UILabel *assignToTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *labelTWo;
@property (weak, nonatomic) IBOutlet UILabel *labelTDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelTDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTAssigned;

@property (nonatomic) AMRelatedWOType popoverType;
@property (weak, nonatomic) id<AMWOPopoverViewControllerDelegate> delegate;

@end

@protocol AMWOPopoverViewControllerDelegate <NSObject>

@optional
- (void)assignToMyselfTapped:(NSError *)error;
- (void)dismissPopover;

@end
