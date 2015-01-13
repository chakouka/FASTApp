//
//  AMInvoiceRepairFilterNameCell.h
//  AramarkFSP
//
//  Created by PwC on 6/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMInvoiceRepairFilterNameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTitlePrice;
@property (weak, nonatomic) IBOutlet UILabel *labelFilterName;
@property (weak, nonatomic) IBOutlet UILabel *labelFilterPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelFilterQuantity;

@property (weak, nonatomic) IBOutlet UILabel *labelTFilterName;
@property (weak, nonatomic) IBOutlet UILabel *labelTFilterPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelTFilterQuantity;
@end
