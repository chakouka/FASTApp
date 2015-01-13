//
//  AMContactTableViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"

@interface AMContactTableViewController : AMWOTabBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *contactArr;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithContactArray:(NSArray *)cArr;

@end
