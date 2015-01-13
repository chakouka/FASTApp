//
//  AMInvoiceCodeTableViewCell.h
//  AramarkFSP
//
//  Created by FYH on 7/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMInvoiceCodeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnInvoiceCode;
@property (weak, nonatomic) IBOutlet UITextField *textFieldInvoiceCode;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPrice;

@property (weak, nonatomic) IBOutlet UILabel *labelTPrice;
@end
