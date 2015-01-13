//
//  AMDropDownTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/13/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMConfiguredCell.h"
#import "AMPopoverSelectTableViewController.h"
#import "AMDatePickerViewController.h"

@protocol AMDropdownTableViewCellDelegate;

@interface AMDropdownTableViewCell : UITableViewCell <AMPopoverSelectTableViewControllerDelegate, AMDatePickerViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *dropDownButton;
@property (weak, nonatomic) IBOutlet UILabel *cellValue;
@property (weak, nonatomic) IBOutlet UILabel *cellTitle;

@property (strong, nonatomic) AMConfiguredCell *configuredCell;
@property (strong, nonatomic) NSMutableArray *popoverContentArr;
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *posId;

@property (weak, nonatomic) id<AMDropdownTableViewCellDelegate> delegate;

@end

@protocol AMDropdownTableViewCellDelegate <NSObject>
@optional
- (void)didSelectPopoverDictionary:(NSDictionary *)dicValue cellObj:(AMDropdownTableViewCell *)cellObj;
- (void)dateChoosed:(NSDate *)date cellObj:(AMDropdownTableViewCell *)cellObj;

@end
