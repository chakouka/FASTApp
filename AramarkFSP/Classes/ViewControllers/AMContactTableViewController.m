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

#import "AMAddContactTableViewCell.h"
#import "AMAddNewContactViewController.h"

static NSString *TableIdentifier_Cell = @"ContactTableCell";

@interface AMContactTableViewController ()

@end

@implementation AMContactTableViewController
- (id)initWithWorkOrder:(AMWorkOrder *)wo
{
    self = [self initWithNibName:NSStringFromClass([AMContactTableViewController class]) bundle:nil];
    if (self) {
        self.contactArr = wo.woPoS.contactList;
        self.selectedWorkOrder = wo;
    }
    return self;
}

- (id)initWithContactArray:(NSArray *)cArr
{
    self = [self initWithNibName:NSStringFromClass([AMContactTableViewController class]) bundle:nil];
    if (self) {
        self.contactArr = cArr;

    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self adjustHeightOfTableview];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"AMContactTableViewCell" bundle:nil] forCellReuseIdentifier:TableIdentifier_Cell];
    [self.tableView registerNib:[UINib nibWithNibName:@"AMAddContactTableViewCell" bundle:nil] forCellReuseIdentifier:@"AddContactTableViewCell"];
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
    if (!(indexPath.section >= [self.contactArr count])) {
        return 110.0;
    } else {
        return 40.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!(section >= [self.contactArr count])) {
        return 36.0;
    } else {
        return 12.0;
    }
}

- (void)adjustHeightOfTableview
{
    CGFloat height = self.tableView.contentSize.height;
    CGFloat maxHeight = self.tableView.superview.frame.size.height - self.tableView.frame.origin.y;
    
    // if the height of the content is greater than the maxHeight of
    // total space on the screen, limit the height to the size of the
    // superview.
    
    if (height > maxHeight)
        height = maxHeight;
    
    // now set the frame accordingly
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height = height;
        self.tableView.frame = frame;
        
        // if you have other controls that should be resized/moved to accommodate
        // the resized tableview, do that here, too
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.contactArr count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Section = %d", indexPath.section);
    NSLog(@"self.contactArr.count = %d", self.contactArr.count);
    if (!(indexPath.section >= [self.contactArr count])) {
        AMContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier_Cell forIndexPath:indexPath];
        cell.assignedContact = [self.contactArr objectAtIndex:indexPath.section];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
        
    } else {
        UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        recognizer.delegate = self;
        
        AMAddContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddContactTableViewCell" forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        [cell addGestureRecognizer:recognizer];
        return cell;
    }

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.contactArr && (section < [self.contactArr count])) {
        AMContactHeaderView *headerView = [AMUtilities loadViewByClassName:NSStringFromClass([AMContactHeaderView class]) fromXib:nil];
        AMContact *contact = [self.contactArr objectAtIndex:section];
        headerView.contactNameLabel.text = contact.name;

        return headerView;
    }
    return nil;
}
-(void)handleTap:(UIGestureRecognizer *) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    //AMAddContactTableViewCell *tappedCell = (AMAddContactTableViewCell *)[self.tableView cellForRowAtIndexPath:tappedIndexPath];

    if ((tappedIndexPath.section >= [self.contactArr count])) {

        
        //Show Create Contact ViewController
        //TODO bkk 3/25/2015
        
        AMAddNewContactViewController *ancVC = [[AMAddNewContactViewController alloc] initWithNibName:@"AMAddNewContactViewController" bundle:nil];
        ancVC.isPop = YES;
        ancVC.modalPresentationStyle = UIModalPresentationPageSheet;
        ancVC.selectedWorkOrder = self.selectedWorkOrder;
        
        [self presentViewController:ancVC animated:YES completion:nil];
//        [[AMLogicCore sharedInstance] createNewContactInDBWithSetupBlock:^(AMDBNewContact *newContact) {
//            newContact.createdDate = [NSDate date];
//            newContact.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
//            newContact.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];;
//            newContact.accountID = self.selectedWorkOrder.accountID;// @"xxxxxx";
//            //newContact.contactID = @"xxxx";
//            newContact.posID = @"";
//            newContact.phone = @"2222222222";
//            newContact.name = @"Brian Kendall";
//            newContact.LastName = @"Kendall";
//            newContact.FirstName = @"Brian";
//            newContact.email = @"kendall-brian@aramark.com";
//            newContact.role = @"Decision Maker;Order Contact";
//            newContact.title = @"Purchasing Agent";
//            
//        } completion:^(NSInteger type, NSError *error) {
//            //todo Error stuff
//            
//        }];
    }
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.tableView.superview.frame), CGRectGetWidth(self.tableView.superview.frame));
}


@end
