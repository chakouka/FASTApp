//
//  AMLeadHistoryCell.h
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMLeadHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *labelFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelCreateDate;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (weak, nonatomic) IBOutlet UILabel *labelEmailAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelErrMessage;

@property (weak, nonatomic) IBOutlet UILabel *labelTFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelTLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelTTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTCreateDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTPhone;
@property (weak, nonatomic) IBOutlet UILabel *labelTEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTAddress;
@end
