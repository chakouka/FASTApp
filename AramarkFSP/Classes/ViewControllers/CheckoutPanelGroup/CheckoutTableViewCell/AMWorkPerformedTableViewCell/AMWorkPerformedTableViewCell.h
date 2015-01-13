//
//  AMWorkPerformedTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/20/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMWorkPerformedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelWorkPerformed;
@property (weak, nonatomic) IBOutlet UIButton *btnHoursRate;
@property (weak, nonatomic) IBOutlet UIButton *btnHoursWorked;
@property (weak, nonatomic) IBOutlet UITextField *textFieldHoursRate;

@property (weak, nonatomic) IBOutlet UILabel *labelTLaborCharge;
@property (weak, nonatomic) IBOutlet UILabel *labelTHoursWorked;
@property (weak, nonatomic) IBOutlet UILabel *labelTHoursRate;

- (void)refreshData:(NSMutableDictionary *)dicInfo;

@end
