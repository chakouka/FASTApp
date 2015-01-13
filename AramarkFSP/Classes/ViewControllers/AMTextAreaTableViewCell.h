//
//  AMTextAreaTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/13/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMBaseTableViewCell.h"


@interface AMTextAreaTableViewCell : AMBaseTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *valueTextView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (nonatomic) BOOL isEditingMode;
@property (weak, nonatomic) id<AMBaseTableViewCellDelegate> delegate;

- (IBAction)editButtonTapped:(id)sender;
@end
