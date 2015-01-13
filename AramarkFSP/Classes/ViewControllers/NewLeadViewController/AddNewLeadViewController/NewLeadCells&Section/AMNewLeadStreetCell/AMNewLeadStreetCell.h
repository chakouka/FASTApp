//
//  AMNewLeadStreetCell.h
//  AramarkFSP
//
//  Created by PwC on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//2014 06 23 changed -------------- Begin
//State -> Street2
//2014 06 23 changed -------------- End

@interface AMNewLeadStreetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textFieldStreet;
@property (weak, nonatomic) IBOutlet UITextField *textFieldZipCode;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCity;
@property (weak, nonatomic) IBOutlet UITextField *textFieldState;
@property (weak, nonatomic) IBOutlet UITextField *textFieldCountry;
@property (weak, nonatomic) IBOutlet UITextField *textFieldStateProvince;
@property (weak, nonatomic) IBOutlet UITextView *textViewComments;
@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (weak, nonatomic) IBOutlet UIButton *btnState;

@property (weak, nonatomic) IBOutlet UILabel *labelTAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelTState;
@property (weak, nonatomic) IBOutlet UILabel *labelTAddressLine2;
@property (weak, nonatomic) IBOutlet UILabel *labelTZipCode;
@property (weak, nonatomic) IBOutlet UILabel *labelTCity;
@property (weak, nonatomic) IBOutlet UILabel *labelTCountry;
@property (weak, nonatomic) IBOutlet UILabel *labelTComment;

@end
