//
//  AMPendingWOViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPendingWOViewController.h"
#import "AMPendingWOHeaderView.h"
#import "AMPendingWOCell.h"
#import "AMWorkOrder.h"

@interface AMPendingWOViewController ()

@end

@implementation AMPendingWOViewController

- (id)initWithType:(AMPendingWOType)type
{
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.type = type;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    AMWorkOrder *wo = [[AMWorkOrder alloc] init];
    wo.woID = @"00001";
    wo.woType = @"Repair";
    wo.complaintCode = @"1111";
    wo.machineType = @"Test Machine Type";
    wo.status = @"Queued";
    wo.priority = @"Normal";
    self.pendingWOArray = [NSMutableArray arrayWithObject:wo];
//    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)collapseButtonTapped:(id)sender {
    [self.tableView setHidden:!self.tableView.hidden];
    [self.collapseButton setSelected:!self.collapseButton.selected];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pendingWOArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PendingWOCell";
    AMPendingWOCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = (AMPendingWOCell *)[AMUtilities loadViewByClassName:@"AMPendingWOCell" fromXib:nil];
    }
    cell.workOrder = [self.pendingWOArray objectAtIndex:indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AMPendingWOHeaderView *headerView = [AMUtilities loadViewByClassName:@"AMPendingWOHeaderView" fromXib:nil];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

@end
