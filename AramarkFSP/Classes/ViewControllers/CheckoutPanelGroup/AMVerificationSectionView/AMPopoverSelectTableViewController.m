//
//  AMPopoverSelectTableViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMPopoverSelectTableViewController.h"
#import "AMVerificationStatusTableViewCell.h"

@interface AMPopoverSelectTableViewController ()
@property (nonatomic, retain)NSMutableArray *cellSelectedArray;
@end

@implementation AMPopoverSelectTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = CGRectMake(0, 0, 200, [self.arrInfos count] * 44);
    
    self.cellSelectedArray = [NSMutableArray array];

    [self.mainTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if (self.isMultiselect) {
        return [self.arrInfos count];//need done button...
    } else if(self.isAddNew) {
        return [self.arrInfos count];//need add new button
    }else {
        return [self.arrInfos count] - 1 ; //don't show done button
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dicInfo = [self.arrInfos objectAtIndex:indexPath.row];
    
    AMVerificationStatusTableViewCell *cell = (AMVerificationStatusTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMVerificationStatusTableViewCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMVerificationStatusTableViewCell" owner:[AMVerificationStatusTableViewCell class] options:nil];
        cell = (AMVerificationStatusTableViewCell *)[nib objectAtIndex:0];
    }
    
    if (self.isMultiselect) {
        cell.accessoryView.hidden = NO;
        NSDictionary *dict = [self.arrInfos objectAtIndex:indexPath.row];
        cell.tintColor = [UIColor blackColor];
        
        if ([self.cellSelectedArray containsObject:[dict objectForKey:@"VALUE"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    cell.labelText.text = [dicInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMultiselect) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(verificationStatusTableViewController:didSelectMulti:)]) {
            
            if (indexPath.row < self.arrInfos.count-1) {

                NSDictionary *dict = [self.arrInfos objectAtIndex:indexPath.row];
                
                if ([self.cellSelectedArray containsObject:[dict objectForKey:@"VALUE"]]) {
                    //remove it...
                    [self.cellSelectedArray removeObject:[dict objectForKey:@"VALUE"]];
                } else {
                    //add item to array of selected items
                    [self.cellSelectedArray addObject:[dict objectForKey:@"VALUE"]];
                }
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            } else {
                [self.delegate verificationStatusTableViewController:self didSelectMulti:[[NSArray arrayWithArray:self.cellSelectedArray] componentsJoinedByString:@","]];
            }
        }
        
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(verificationStatusTableViewController:didSelected:)]) {
            [self.delegate verificationStatusTableViewController:self didSelected:[self.arrInfos objectAtIndex:indexPath.row]];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedIndex:contentArray:)]) {
            [self.delegate didSelectedIndex:indexPath.row contentArray:self.arrInfos];
        }
    }
}

- (void)setArrInfos:(NSMutableArray *)arrInfos
{
    _arrInfos = arrInfos;
    self.view.frame = CGRectMake(0, 0, 200, [self.arrInfos count] * 44);
    [self.mainTableView reloadData];
    
}

@end
