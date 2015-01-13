//
//  AMAddNewLeadViewController.h
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMNewLeadViewControllerDelegate <NSObject>

- (void)didClickSaveNewLead:(BOOL)success;

@end

@interface AMAddNewLeadViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;
@property (assign, nonatomic) id<AMNewLeadViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

- (void)refreshWithInfo:(NSMutableDictionary *)aInfo;
- (IBAction)clickSaveBtn:(id)sender;

@end
