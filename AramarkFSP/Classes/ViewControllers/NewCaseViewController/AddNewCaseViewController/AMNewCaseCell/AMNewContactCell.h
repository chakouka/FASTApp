//
//  AMNewContactCell.h
//  AramarkFSP
//
//  Created by bkendall on 3/25/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AMNewContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnChooseRoles;



@property (weak, nonatomic) IBOutlet UILabel *labelChooseRoles;

@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhone;

@property (weak, nonatomic) IBOutlet UILabel *labelTChooseRoles;
@property (weak, nonatomic) IBOutlet UILabel *labelTFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelTLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelTEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTPhone;

@end
