//
//  AMAddNewContactViewController.h
//  AramarkFSP
//
//  Created by bkendall on 3/25/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMAddNewContactViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) AMWorkOrder *selectedWorkOrder;
@property (assign, nonatomic) BOOL isPop;

- (void)refreshWithInfo;
- (IBAction)clickSaveBtn:(id)sender;
@end
