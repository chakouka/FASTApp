//
//  AMPendingWOViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

typedef enum {
    AMPendingWOTypeAccount,
    AMPendingWOTypePOS
} AMPendingWOType;

#import <UIKit/UIKit.h>

@interface AMPendingWOViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *pendingWOArray;
@property (nonatomic) AMPendingWOType type;

- (id)initWithType:(AMPendingWOType)type;

@end
