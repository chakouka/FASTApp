//
//  AMMaintenanceTypeTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMMaintenanceTypeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelPreventiveMaintenance;
@property (weak, nonatomic) IBOutlet UILabel *labelMaintenanceFee;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMaintenanceFee;

@property (weak, nonatomic) IBOutlet UILabel *labelTMaintenanceType;
@property (weak, nonatomic) IBOutlet UILabel *labelTMaintenanceFee;
- (void)refreshData:(NSMutableDictionary *)dicInfo;
@end
