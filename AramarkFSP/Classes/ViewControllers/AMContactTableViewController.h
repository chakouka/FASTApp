//
//  AMContactTableViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"
#import "AMWorkOrder.h"

@interface AMContactTableViewController : AMWOTabBaseViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *contactArr;
@property (strong, nonatomic) AMWorkOrder *selectedWorkOrder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithContactArray:(NSArray *)cArr;
- (id)initWithWorkOrder:(AMWorkOrder *)wo;

@end
