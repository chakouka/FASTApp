//
//  AMNewCaseCell.h
//  AramarkFSP
//
//  Created by PwC on 6/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//2014 06 23 changed -------------- Begin
//Contact Name -> Priority
//2014 06 23 changed -------------- End

@interface AMNewCaseCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnCaseRecordType;
@property (weak, nonatomic) IBOutlet UIButton *btnType;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseContact;
@property (weak, nonatomic) IBOutlet UIButton *btnChooseAsset;
@property (weak, nonatomic) IBOutlet UIButton *btnPriority;

@property (weak, nonatomic) IBOutlet UILabel *labelChooseContact;
@property (weak, nonatomic) IBOutlet UILabel *labelChooseAsset;

@property (weak, nonatomic) IBOutlet UITextField *textFieldCaseRecordType;
@property (weak, nonatomic) IBOutlet UITextField *textFieldType;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPointOfService;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPriority;
@property (weak, nonatomic) IBOutlet UITextField *textFieldAccount;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMEICustomerNo;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSubject;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldAssetNo;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSerialNo;

@property (weak, nonatomic) IBOutlet UITextView *textViewDescription;

@property (weak, nonatomic) IBOutlet UILabel *labelTCaseRecordType;
@property (weak, nonatomic) IBOutlet UILabel *labelTType;
@property (weak, nonatomic) IBOutlet UILabel *labelTAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelTMeiCustomer;
@property (weak, nonatomic) IBOutlet UILabel *labelTPointOfService;
@property (weak, nonatomic) IBOutlet UILabel *labelTPriority;
@property (weak, nonatomic) IBOutlet UILabel *labelTSubject;
@property (weak, nonatomic) IBOutlet UILabel *labelTChooseContact;
@property (weak, nonatomic) IBOutlet UILabel *labelTOr;
@property (weak, nonatomic) IBOutlet UILabel *labelTFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelTLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelTEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTCaseDescription;
@property (weak, nonatomic) IBOutlet UILabel *labelTChooseAsset;
@property (weak, nonatomic) IBOutlet UILabel *labelTOr2;
@property (weak, nonatomic) IBOutlet UILabel *labelTAssetNo;
@property (weak, nonatomic) IBOutlet UILabel *labelTSerialNo;


@end
