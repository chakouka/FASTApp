//
//  AMPendingWOViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMRelatedWOViewController.h"
#import "AMRelatedWOHistoryCellHeaderView.h"
#import "AMRelatedWOHistoryTableViewCell.h"
#import "AMPendingWOHeaderView.h"
#import "AMPendingWOCell.h"
#import "AMAccountPendingWOCell.h"
#import "AMAccountPendingWOHeaderView.h"
#import "AMWorkOrder.h"

static NSString *CellIdentifier = @"PendingWOCell";
static NSString *AccountCellIdentifier = @"AccountPendingWOCell";
static NSString *AssetCellIdentifier = @"AssetRelatedWOCell";

@interface AMRelatedWOViewController ()

@end

@implementation AMRelatedWOViewController

- (id)initWithType:(AMRelatedWOType)type sectionTitle:(NSString *)sectionTitle
{
    self = [self initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.type = type;
        self.sectionTitle = sectionTitle;
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
    self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.view.layer.borderWidth = 1.0;
    //set font
    for (UIView *subview in [self.view subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([[subview subviews] count] > 0) {
            for (UIView *sv in [subview subviews]) {
                if ([sv isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)sv;
                    [label setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
                }
            }
        }
    }
    
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.sectionLabel.text = self.sectionTitle ? self.sectionTitle : MyLocal(@"PENDING WO");
//    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)collapseButtonTapped:(id)sender {
    [self.tableView setHidden:!self.tableView.hidden];
    self.view.layer.borderWidth = self.tableView.hidden ? 0.0 : 1.0;
//    [UIView animateWithDuration:0.3 animations:^{
//        self.tableView.alpha = self.tableView.hidden ? 1.0 : 0.0;
//        self.view.layer.borderWidth = self.tableView.hidden ? 1.0 : 0.0;
//    } completion:^(BOOL finished) {
//        [self.tableView setHidden:!self.tableView.hidden];
//    }];
    
    [self.collapseButton setSelected:!self.collapseButton.selected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTappedOnCollapseButton:)]) {
        [self.delegate performSelector:@selector(didTappedOnCollapseButton:) withObject:self.collapseButton];
    }
}

#pragma Setter/Getter
- (void)setPendingWOArray:(NSArray *)pendingWOArray
{
    _pendingWOArray = pendingWOArray;
    [self.tableView reloadData];
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.pendingWOArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.type) {
        case AMRelatedWOTypeAsset:
        {
            AMRelatedWOHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AssetCellIdentifier];
            if (!cell) {
                cell = (AMRelatedWOHistoryTableViewCell *)[AMUtilities loadViewByClassName:@"AMRelatedWOHistoryTableViewCell" fromXib:nil];
            }
            cell.type = self.type;
            cell.workOrder = [self.pendingWOArray objectAtIndex:indexPath.row];
            return cell;
        }
            break;
        case AMRelatedWOTypeAccount:
        {
            AMAccountPendingWOCell *accountCell = [tableView dequeueReusableCellWithIdentifier:AccountCellIdentifier];
            if (!accountCell) {
                accountCell = (AMAccountPendingWOCell *)[AMUtilities loadViewByClassName:NSStringFromClass([AMAccountPendingWOCell class]) fromXib:nil];
            }
            accountCell.type = self.type;
            accountCell.workOrder = [self.pendingWOArray objectAtIndex:indexPath.row];
            return accountCell;
        }
            break;
        case AMRelatedWOTypeCase:
        case AMRelatedWOTypePOS:
        {
            
        }
            break;
            
        default:
            break;
    }
    AMPendingWOCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = (AMPendingWOCell *)[AMUtilities loadViewByClassName:@"AMPendingWOCell" fromXib:nil];
    }
    cell.type = self.type;
    cell.workOrder = [self.pendingWOArray objectAtIndex:indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (self.type) {
        case AMRelatedWOTypeAsset:
        {
            AMRelatedWOHistoryCellHeaderView *headerView = [AMUtilities loadViewByClassName:@"AMRelatedWOHistoryCellHeaderView" fromXib:nil];
            return headerView;
        }
            break;
        case AMRelatedWOTypeAccount:
        {
            AMAccountPendingWOHeaderView *headerView = [AMUtilities loadViewByClassName:NSStringFromClass([AMAccountPendingWOHeaderView class]) fromXib:nil];
            return headerView;
        }
            break;
        case AMRelatedWOTypeCase:
        case AMRelatedWOTypePOS:
        {
            AMPendingWOHeaderView *headerView = [AMUtilities loadViewByClassName:@"AMPendingWOHeaderView" fromXib:nil];
            return headerView;
        }
            break;
            
        default:
            break;
    }
    //By default
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if ([self.collapseButton isSelected]) {
        [self collapseButtonTapped:nil];
    }
}

@end
