//
//  AMNewLeadHistoryViewController.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMNewLeadHistoryViewController.h"
#import "AMLeadHistoryCell.h"
#import "AMLeadHistorySection.h"
#import "AMLeadEmptyListCell.h"

@interface AMNewLeadHistoryViewController ()
{
    NSString *strTitle;
    NSMutableArray *arrList;
    BOOL isEmpty;
}

@property(nonatomic,strong) NSMutableArray *arrList;
@property(nonatomic,strong) NSString *strTitle;
@end

@implementation AMNewLeadHistoryViewController
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

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isEmpty) {
        AMLeadEmptyListCell *cell = (AMLeadEmptyListCell *)[tableView dequeueReusableCellWithIdentifier:@"AMLeadEmptyListCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMLeadEmptyListCell" owner:[AMLeadEmptyListCell class] options:nil];
            cell = (AMLeadEmptyListCell *)[nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        cell.labelTips.text = MyLocal(@"No Leads");
        
        return cell;
    }
    
    AMLeadHistoryCell *cell = (AMLeadHistoryCell *)[tableView dequeueReusableCellWithIdentifier:@"AMLeadHistoryCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMLeadHistoryCell" owner:[AMLeadHistoryCell class] options:nil];
        cell = (AMLeadHistoryCell *)[nib objectAtIndex:0];
    }
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    AMDBNewLead *newLead = [arrList objectAtIndex:indexPath.row];
    
    NSTimeZone *aZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
    
    cell.labelCompanyName.text = newLead.companyName;
    cell.labelFirstName.text = newLead.firstName;
    cell.labelLastName.text = newLead.lastName;
    cell.labelTitle.text = newLead.title;
    cell.labelCreateDate.text = [newLead.createdDate formattedDateWithFormat:@"yyyy.MM.dd" timeZone:aZone];
    
    NSString *strAddress = @"";
    
    if ([newLead.street2 length] != 0) {
        strAddress = [strAddress stringByAppendingString:[NSString stringWithFormat:@"%@ , ",newLead.street2]];
    }
    
    if ([newLead.street length] != 0) {
        strAddress = [strAddress stringByAppendingString:[NSString stringWithFormat:@"%@ , ",newLead.street]];
    }
    
    if ([newLead.city length] != 0) {
        strAddress = [strAddress stringByAppendingString:[NSString stringWithFormat:@"%@ , ",newLead.city]];
    }
    
    if ([newLead.stateProvince length] != 0) {
        strAddress = [strAddress stringByAppendingString:[NSString stringWithFormat:@"%@ , ",newLead.stateProvince]];
    }
    
    if ([newLead.country length] != 0) {
        strAddress = [strAddress stringByAppendingString:newLead.country];
    }
    
    cell.labelAddress.text = strAddress;
    cell.labelPhone.text = newLead.phoneNumber;
    cell.labelEmailAddress.text = newLead.emailAddress;
    cell.labelErrMessage.text = newLead.errorMessage;
    
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


@end
