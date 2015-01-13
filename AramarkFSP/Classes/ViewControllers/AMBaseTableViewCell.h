//
//  AMBaseTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/27/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMConfiguredCell.h"

@protocol  AMBaseTableViewCellDelegate;

@interface AMBaseTableViewCell : UITableViewCell <UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) AMConfiguredCell *configuredCell;

@end

@protocol AMBaseTableViewCellDelegate <NSObject>

@optional
- (void)textFieldStartEditing:(UITextField *)textField withCellObj:(AMBaseTableViewCell *)cellObj;
- (void)textFieldEndEditing:(UITextField *)textField withCellObj:(AMBaseTableViewCell *)cellObj;
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string withCellObj:(AMBaseTableViewCell *)cellObj;

- (void)textViewStartEditing:(UITextView *)textView withCellObj:(AMBaseTableViewCell *)cellObj;
- (void)textViewEndEditing:(UITextView *)textView withCellObj:(AMBaseTableViewCell *)cellObj;



@end