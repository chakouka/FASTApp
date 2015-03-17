//
//  AMContactTableViewController.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMContactTableViewController.h"
#import "AMContactTableViewCell.h"
#import "AMContactHeaderView.h"

static NSString *TableIdentifier_Cell = @"ContactTableCell";

@interface AMContactTableViewController ()

@end

@implementation AMContactTableViewController

- (id)initWithContactArray:(NSArray *)cArr
{
    self = [self initWithNibName:NSStringFromClass([AMContactTableViewController class]) bundle:nil];
    if (self) {
        self.contactArr = cArr;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"AMContactTableViewCell" bundle:nil] forCellReuseIdentifier:TableIdentifier_Cell];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView registerClass:[AMContactSectionHeaderView class] forHeaderFooterViewReuseIdentifier:TableIdentifier_Cell];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setContactArr:(NSArray *)contactArr
{
    _contactArr = contactArr;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 36.0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.contactArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier_Cell forIndexPath:indexPath];
    cell.assignedContact = [self.contactArr objectAtIndex:indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [[AMLogicCore sharedInstance] createNewContactInDBWithSetupBlock:^(AMDBNewContact *newContact) {
        newContact.createdDate = [NSDate date];
        //newContact.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
        newContact.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];;
        newContact.accountID = @"xxxxxx";
        newContact.contactID = @"xxxx";
        newContact.posID = @"";
        newContact.phone = @"2222222222";
        newContact.name = @"brian kendall";
        newContact.lastName = @"kendall";
        newContact.firstName = @"brian";
        newContact.email = @"kendall-brian@aramark.com";
        newContact.role = @"Decision Maker;Order Contact";
        newContact.title = @"Purchasing Agent";
        
    } completion:^(NSInteger type, NSError *error) {
        //todo Error stuff
        
    }];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    AMContactHeaderView *headerView = [AMUtilities loadViewByClassName:NSStringFromClass([AMContactHeaderView class]) fromXib:nil];
    AMContact *contact = [self.contactArr objectAtIndex:section];
    headerView.contactNameLabel.text = contact.name;

    return headerView;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.superview.frame), CGRectGetWidth(self.tableView.superview.frame));
}


@end
