//
//  AMPMsNameTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMFilter;

@interface AMPMsNameTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *textFieldPMQuantity;

@property (weak, nonatomic) IBOutlet UIButton *btnPreventativeMaintenance;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPMName;
@property (weak, nonatomic) IBOutlet UILabel *labelTPrice;

- (void)refreshData:(NSMutableDictionary *)dicInfo;

@end
