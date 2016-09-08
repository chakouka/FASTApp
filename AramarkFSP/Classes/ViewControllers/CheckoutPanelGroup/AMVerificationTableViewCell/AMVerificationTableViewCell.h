//
//  AMVerificationTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMAsset;
@interface AMVerificationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textFieldMachineType;
@property (weak, nonatomic) IBOutlet UITextField *textFieldAsset;
@property (weak, nonatomic) IBOutlet UILabel *labelVerificationStatus;
@property (weak, nonatomic) IBOutlet UITextField *textFieldVerifiedDate;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSerial;
@property (weak, nonatomic) IBOutlet UIButton *btnVerification;
@property (weak, nonatomic) IBOutlet UITextView *textViewNote;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUpdatedAsset;
@property (weak, nonatomic) IBOutlet UITextField *textFieldUpdateSerial;
@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateDate;

@property (weak, nonatomic) IBOutlet UILabel *labelTMachineType;
@property (weak, nonatomic) IBOutlet UILabel *labelTVerificationStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelTVerifiedDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTAsset;
@property (weak, nonatomic) IBOutlet UILabel *labelTSerial;
@property (weak, nonatomic) IBOutlet UILabel *labelTUpdatedAsset;
@property (weak, nonatomic) IBOutlet UILabel *labelTUpdatedSerial;
@property (weak, nonatomic) IBOutlet UILabel *labelTVerificationNotes;

- (void)enableEdit:(BOOL)enable;

@end
