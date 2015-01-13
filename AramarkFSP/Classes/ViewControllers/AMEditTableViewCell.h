//
//  AMCheckboxTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBaseTableViewCell.h"

@interface AMEditTableViewCell : AMBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelCellTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCellValue;
@property (weak, nonatomic) IBOutlet UIButton *buttonEdit;

@property (nonatomic) BOOL isEditingMode;
@property (weak, nonatomic) id<AMBaseTableViewCellDelegate> delegate;

- (IBAction)editButtonTapped:(id)sender;

@end
