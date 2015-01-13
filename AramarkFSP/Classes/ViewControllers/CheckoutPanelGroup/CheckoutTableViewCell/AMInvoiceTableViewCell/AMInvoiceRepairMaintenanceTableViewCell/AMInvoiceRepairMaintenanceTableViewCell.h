//
//  AMInvoiceRepairTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMInvoiceRepairMaintenanceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTitlePrice;
@property (weak, nonatomic) IBOutlet UILabel *labelWorkPerformed;
@property (weak, nonatomic) IBOutlet UILabel *labelHoursWorked;
@property (weak, nonatomic) IBOutlet UILabel *labelHoursRate;
@property (weak, nonatomic) IBOutlet UILabel *labelMaintenanceType;
@property (weak, nonatomic) IBOutlet UILabel *labelMaintenanceFee;

@property (weak, nonatomic) IBOutlet UILabel *labelTPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelTMaintenanceType;
@property (weak, nonatomic) IBOutlet UILabel *labelTMaintenanceFee;
@end
