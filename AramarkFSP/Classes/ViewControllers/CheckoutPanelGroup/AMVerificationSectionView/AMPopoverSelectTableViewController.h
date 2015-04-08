//
//  AMPopoverSelectTableViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAMPOPOVER_DICTIONARY_KEY_INFO @"INFO"  //Use for showing info
#define kAMPOPOVER_DICTIONARY_KEY_DATA @"DATA"  //Use for extra data
#define kAMPOPOVER_DICTIONARY_KEY_VALUE @"VALUE"  //Use for Sepcial value

@protocol AMPopoverSelectTableViewControllerDelegate;

@interface AMPopoverSelectTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) NSIndexPath *aIndexPath;
@property (nonatomic, strong)NSMutableArray *arrInfos;
@property (assign, nonatomic) NSInteger tag;
@property (nonatomic, readwrite) BOOL isMultiselect;
@property (nonatomic, readwrite) BOOL isAddNew;
@property (weak, nonatomic) id<AMPopoverSelectTableViewControllerDelegate> delegate;

@end


@protocol AMPopoverSelectTableViewControllerDelegate <NSObject>

@optional
- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo;
- (void)didSelectedIndex:(NSInteger)aIndex contentArray:(NSArray *)aArray;

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelectMulti:(NSString *)selectionString;
@end