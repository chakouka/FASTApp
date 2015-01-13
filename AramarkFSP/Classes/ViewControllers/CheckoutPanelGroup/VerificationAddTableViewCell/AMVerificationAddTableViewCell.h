//
//  AMVerificationAddTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/30/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMVerificationAddTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textFieldAsset;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSerial;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPoint;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLocation;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
//@property (weak, nonatomic) IBOutlet UIButton *btnLocation;
//@property (weak, nonatomic) IBOutlet UILabel *labelLocation;
@property (weak, nonatomic) IBOutlet UITextView *textViewNote;

@property (weak, nonatomic) IBOutlet UILabel *labelTAsset;
@property (weak, nonatomic) IBOutlet UILabel *labelTPointOfService;
@property (weak, nonatomic) IBOutlet UILabel *labelTSerial;
@property (weak, nonatomic) IBOutlet UILabel *labelTLocation;
@property (weak, nonatomic) IBOutlet UILabel *labelTVerificationNotes;

@end
