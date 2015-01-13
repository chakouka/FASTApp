//
//  AMCheckBoxTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMConfiguredCell.h"

@protocol AMCheckBoxTableViewCellDelegate;

@interface AMCheckBoxTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;
@property (strong, nonatomic) AMConfiguredCell *configuredCell;
@property (nonatomic) BOOL isChecked;

@property (weak, nonatomic) id<AMCheckBoxTableViewCellDelegate> delegate;

@end

@protocol AMCheckBoxTableViewCellDelegate <NSObject>

- (void)checkboxIsChecked:(BOOL)boolValue cellObj:(AMCheckBoxTableViewCell *)cellObj;

@end