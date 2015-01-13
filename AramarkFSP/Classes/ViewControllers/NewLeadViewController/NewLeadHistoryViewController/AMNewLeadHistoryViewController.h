//
//  AMNewLeadHistoryViewController.h
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMNewLeadHistoryViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;

- (void)refreshHistoryListWithInfo:(NSMutableDictionary *)aInfo;

@end
