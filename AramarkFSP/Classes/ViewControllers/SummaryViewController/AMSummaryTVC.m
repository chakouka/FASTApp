//
//  AMSummaryTVC.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/3/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//


#import "AMSummaryTVC.h"
#import "AMSummaryCell.h"
#import "AMSummaryTableViewHeader.h"
#import "AMProtocolParser.h"
#import "AMSummaryEmptyListCell.h"
#import "AMAddNewCaseViewController.h"
#import "AMSummaryFutureCell.h"

#define CELL_SUMMARY   @"AMSummaryCell"
#define CELL_SUMMARY_FUTURE @"AMSummaryFutureCell"
#define CELL_EMPTY_SUMMARY @"AMSummaryEmptyListCell"

#define INFORMATION_NO_WORK_ORDER  MyLocal(@"No Work Orders")
#define numberOfPastDaysDisplayed 14

@interface AMSummaryTVC ()
<
AMNewCaseViewControllerDelegate
>
{
    AMAddNewCaseViewController *addNewCaseVC;
}

@property (nonatomic, strong) AMSummaryCell *cellForHeightCalculation;
@property (nonatomic, strong) NSArray *cellHeights;
@property (nonatomic) BOOL hasOrderList;
@end

@implementation AMSummaryTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:CELL_SUMMARY bundle:nil] forCellReuseIdentifier:CELL_SUMMARY];
    [self.tableView registerNib:[UINib nibWithNibName:CELL_EMPTY_SUMMARY bundle:nil] forCellReuseIdentifier:CELL_EMPTY_SUMMARY];
    [self.tableView registerNib:[UINib nibWithNibName:CELL_SUMMARY_FUTURE bundle:nil] forCellReuseIdentifier:CELL_SUMMARY_FUTURE];
}

-(void)didMoveToParentViewController:(UIViewController *)parent{
    
}


#pragma mark - Properties

-(void)setOneDayOrders:(NSArray *)oneDayOrders
{
    _oneDayOrders = oneDayOrders;
    if (oneDayOrders != nil && [oneDayOrders count] > 0) {
        self.hasOrderList = YES;
    }else{
        self.hasOrderList = NO;
    }
    [[self tableView]reloadData];
}

#pragma mark - UI

#pragma mark - Click

- (void)clickNewCaseBtn:(UIButton *)sender
{
    AMWorkOrder *workOrder = self.oneDayOrders[sender.tag];
    
    AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:workOrder.posID];
    
    if (!pos) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Point of Service can not be nil")];
        return ;
    }
    
    addNewCaseVC = [[AMAddNewCaseViewController alloc] initWithNibName:@"AMAddNewCaseViewController" bundle:nil];
    addNewCaseVC.delegate = self;
    addNewCaseVC.isPop = YES;
    addNewCaseVC.source = AddNewCasePageSource_Summary;
    addNewCaseVC.strPoSId = pos.posID;
    addNewCaseVC.strAccountId = workOrder.accountID;
    addNewCaseVC.strMEICustomer = pos.meiNumber;
    addNewCaseVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:addNewCaseVC animated:YES completion:nil];

}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.hasOrderList) {
        return self.oneDayOrders.count;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.hasOrderList) {
        if (self.isHistoryDate) {
            AMSummaryCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUMMARY forIndexPath:indexPath];
            [self setDataForCell:cell forIndexPath:indexPath];
            return cell;
        }else{
            AMSummaryFutureCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_SUMMARY_FUTURE forIndexPath:indexPath];
            [self setDataForFutureCell:cell forIndexPath:indexPath];
            cell.delegate = self;
            return cell;
        }
        
    }else{
        AMSummaryEmptyListCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_EMPTY_SUMMARY forIndexPath:indexPath];
        [self setDataForEmptyCell:cell forIndexPath:indexPath];
        return cell;
    }
    

    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 170;
}

-(void)setDataForEmptyCell:(AMSummaryEmptyListCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.lbl_noWOInformation.text = INFORMATION_NO_WORK_ORDER;
}

-(void)setDataForCell:(AMSummaryCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.order = self.oneDayOrders[indexPath.row];
    cell.lbl_number.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cell.btnNewCase.tag = indexPath.row;
    
    NSInteger daysFromToday = self.tag - (numberOfPastDaysDisplayed-1);
    
    if (daysFromToday != 0)
    {
        cell.btnNewCase.hidden = YES;
    }
    else
    {
        cell.btnNewCase.hidden = NO;
    }
    
    [cell.btnNewCase addTarget:self action:@selector(clickNewCaseBtn:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setDataForFutureCell:(AMSummaryFutureCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    cell.order = self.oneDayOrders[indexPath.row];
    cell.lbl_number.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    
}


-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AMSummaryTableViewHeader *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AMSummaryTableViewHeader" owner:nil options:nil] firstObject];

    NSDateFormatter *formatterDate = [NSDateFormatter new];
    formatterDate.dateStyle = NSDateFormatterMediumStyle;
    formatterDate.timeStyle = NSDateFormatterNoStyle;
    formatterDate.timeZone =[[AMProtocolParser sharedInstance]timeZoneOnSalesforce];
    
    NSString *titleString =[formatterDate stringFromDate:self.date];
    NSInteger daysFromToday = self.tag - (numberOfPastDaysDisplayed-1);
    
    NSString *daysFromTodayString = @"";
    if (daysFromToday < 0) {
        daysFromToday = daysFromToday * (-1);
        daysFromTodayString = [NSString stringWithFormat:@"   %d %@ %@",daysFromToday,daysFromToday==1?MyLocal(@"day"):MyLocal(@"days"),MyLocal(@"ago")];
    }else if (daysFromToday == 0){
        daysFromTodayString = [NSString stringWithFormat:@"   %@",MyLocal(@"Today")];
    }else{
        daysFromTodayString = [NSString stringWithFormat:@"   %ld %@ %@",(long)daysFromToday,daysFromToday==1?MyLocal(@"day"):MyLocal(@"days"),MyLocal(@"later")];
    }
    titleString = [titleString stringByAppendingString:daysFromTodayString];
    headerView.lbl_title.text = titleString;
    headerView.lbl_title.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:18.0];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    AMSummaryTableViewHeader *headerView = [[[NSBundle mainBundle] loadNibNamed:@"AMSummaryTableViewHeader" owner:nil options:nil] firstObject];
    return headerView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark -

- (void)didClickSaveNewCase:(BOOL)success
{
    //
}

#pragma mark - Summary Future Cell Delegate
-(void)didWorkNowButtonClicked:(AMSummaryFutureCell *)futureCell{
    AMWorkOrder *clickedWorkOrder = futureCell.order;
    [self.delegate didWorkNowClicked:clickedWorkOrder];
}

@end








