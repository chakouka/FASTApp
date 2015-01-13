//
//  AMRepairTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMRepairTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnRepairCode;
@property (weak, nonatomic) IBOutlet UILabel *labelRepairCode;
@property (weak, nonatomic) IBOutlet UILabel *labelTRepairCode;

- (void)refreshData:(NSMutableDictionary *)dicInfo;

@end
