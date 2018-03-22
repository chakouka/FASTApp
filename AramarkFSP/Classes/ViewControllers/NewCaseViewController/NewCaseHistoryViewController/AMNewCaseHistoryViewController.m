//
//  AMNewCaseHistoryViewController.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewCaseHistoryViewController.h"
#import "AMCaseHistoryCell.h"
#import "AMLeadHistorySection.h"
#import "AMAddNewCaseViewController.h"
#import "AMLeadEmptyListCell.h"

@interface AMNewCaseHistoryViewController ()
<
AMNewCaseViewControllerDelegate
>
{
    NSString *strTitle;
    NSMutableArray *arrList;
    AMAddNewCaseViewController *addNewCaseVC;
    
    BOOL isEmpty;
}

@property(nonatomic,strong) NSMutableArray *arrList;
@property(nonatomic,strong) NSString *strTitle;
@end

@implementation AMNewCaseHistoryViewController
@synthesize arrList;
@synthesize strTitle;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)refreshHistoryListWithInfo:(NSMutableDictionary *)aInfo
{
    NSDateFormatter *formatterDate = [NSDateFormatter new];
    formatterDate.dateStyle = NSDateFormatterMediumStyle;
    formatterDate.timeStyle = NSDateFormatterNoStyle;
    formatterDate.timeZone =[[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    NSString *titleString =[formatterDate stringFromDate:[[aInfo allKeys] firstObject]];
    
    self.strTitle = titleString;
    self.arrList = [aInfo objectForKey:[[aInfo allKeys] firstObject]];
    
    if ([arrList count] == 0) {
        isEmpty = YES;
    }
    else
    {
        isEmpty = NO;
    }
    
    [self.tableViewMain reloadData];
}

- (void)clickModifyBtn:(UIButton *)sender
{
    addNewCaseVC = [[AMAddNewCaseViewController alloc] initWithNibName:@"AMAddNewCaseViewController" bundle:nil];
    addNewCaseVC.delegate = self;
    addNewCaseVC.isPop = YES;
    addNewCaseVC.source = AddNewCasePageSource_History;
    addNewCaseVC.aNewCase = [arrList objectAtIndex:sender.tag];
    addNewCaseVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:addNewCaseVC animated:YES completion:nil];
}

#pragma mark -

-(NSString *)strWithEntityStatus:(EntityStatus)status
{
    NSString *strInfo = nil;
    
    switch (status) {
        case EntityStatusNew:
        {
            strInfo = @"New";
        }
            break;
        case EntityStatusCreated:
        {
            strInfo = @"Created";
        }
            break;
        case EntityStatusModified:
        {
            strInfo = @"Modified";
        }
            break;
        case EntityStatusDeleted:
        {
            strInfo = @"Deleted";
        }
            break;
        case EntityStatusSyncSuccess:
        {
            strInfo = @"Success";
        }
            break;
        case EntityStatusSyncFail:
        {
            strInfo = @"Fail";
        }
            break;
        case EntityStatusFromSalesforce:
        {
            strInfo = @"Form Salesforce";
        }
            break;
    }
    
    return MyLocal(strInfo);
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isEmpty) {
        AMLeadEmptyListCell *cell = (AMLeadEmptyListCell *)[tableView dequeueReusableCellWithIdentifier:@"AMLeadEmptyListCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMLeadEmptyListCell" owner:[AMLeadEmptyListCell class] options:nil];
            cell = (AMLeadEmptyListCell *)[nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.labelTips.text = MyLocal(@"No Cases");
        
        return cell;
    }
    
    AMCaseHistoryCell *cell = (AMCaseHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"AMCaseHistoryCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMCaseHistoryCell" owner:[AMCaseHistoryCell class] options:nil];
        cell = (AMCaseHistoryCell *)[nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AMDBNewCase *newCase = [arrList objectAtIndex:indexPath.row];

    NSString *strCaseRecordType = [[AMLogicCore sharedInstance] getRecordTypeNameById:newCase.recordTypeID forObject:RECORD_TYPE_OF_CASE];
    cell.labelCaseRecordType.text = MyLocal(strCaseRecordType);
    cell.labelType.text = MyLocal(newCase.type);
    cell.labelAccount.text = newCase.accountName;
    cell.labelPoS.text = newCase.posName;
    cell.labelSubject.text = newCase.subject;
    cell.labelCase.text = newCase.caseNumber;
    
    cell.labelDescription.text = newCase.caseDescription;
    
    if ([newCase.dataStatus integerValue] == EntityStatusSyncFail) {
        cell.btnModify.hidden = NO;
        cell.btnModify.tag = indexPath.row;
        [cell.btnModify addTarget:self action:@selector(clickModifyBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *strInfo = [self strWithEntityStatus:(int)[newCase.dataStatus integerValue]];
        
        if ([newCase.errorMessage length] != 0) {
            strInfo = [strInfo stringByAppendingString:[NSString stringWithFormat:@" - %@",newCase.errorMessage]];
        }
        
        cell.labelStatus.textColor = [UIColor redColor];
        cell.labelStatus.text = strInfo;
    }
    else
    {
        cell.labelStatus.text = [self strWithEntityStatus:(int)[newCase.dataStatus integerValue]];
        cell.labelStatus.textColor = [UIColor blackColor];
        cell.btnModify.hidden = YES;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return isEmpty ? 1 : [arrList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMLeadHistorySection" owner:[AMLeadHistorySection class] options:nil];
    AMLeadHistorySection *aView = (AMLeadHistorySection *)[nib objectAtIndex:0];
    NSString *title = [NSString stringWithFormat:@"<     %@     >",self.strTitle];
    aView.labelTitle.text = title;
	return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

#pragma mark -

-(void)didClickSaveNewCase:(BOOL)success
{
    [addNewCaseVC dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RELOAD_CASE_HISTORY_LIST object:nil userInfo:nil];
}

@end
