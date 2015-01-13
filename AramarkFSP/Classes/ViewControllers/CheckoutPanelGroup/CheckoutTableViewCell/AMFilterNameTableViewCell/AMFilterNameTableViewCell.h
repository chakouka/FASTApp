//
//  AMFilterNameTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMFilter;

@interface AMFilterNameTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnQuantity;
@property (weak, nonatomic) IBOutlet UIButton *btnFilterName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFilterName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFilterPrice;
@property (weak, nonatomic) IBOutlet UITextField *textFieldQuantity;
@property (weak, nonatomic) IBOutlet UILabel *labelTPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelTQuantity;

- (void)refreshData:(NSMutableDictionary *)dicInfo;

@end
