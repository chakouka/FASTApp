//
//  AMNewLeadFirtNameCell.h
//  AramarkFSP
//
//  Created by PwC on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//2014 06 23 changed -------------- Begin
//Lead Owner -> Current Provider
//Lead Source -> Refering Employee
//2014 06 23 changed -------------- End

@interface AMNewLeadFirtNameCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCompanyName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCompanySize;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCurrentProvider;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *textFieldReferingEmployee;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhoneNumber;
//@property (weak, nonatomic) IBOutlet UITextField *textFieldReferingEmplyee;
@property (weak, nonatomic) IBOutlet UIButton *btnFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelFIrstName;
@property (weak, nonatomic) IBOutlet UIButton *btnCompanySize;

@property (weak, nonatomic) IBOutlet UILabel *labelTFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelTCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *labelTLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelTCompanySize;
@property (weak, nonatomic) IBOutlet UILabel *labelTPositionTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTCurrentProvider;
@property (weak, nonatomic) IBOutlet UILabel *labelTEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTReferingE;
@property (weak, nonatomic) IBOutlet UILabel *labelTPhoneNumber;
@end
