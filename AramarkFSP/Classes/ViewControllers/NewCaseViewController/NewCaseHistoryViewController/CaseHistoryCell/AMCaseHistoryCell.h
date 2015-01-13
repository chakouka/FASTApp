//
//  AMCaseHistoryCell.h
//  AramarkFSP
//
//  Created by PwC on 7/8/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMCaseHistoryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelCaseRecordType;
@property (weak, nonatomic) IBOutlet UILabel *labelType;
@property (weak, nonatomic) IBOutlet UILabel *labelAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelPoS;
@property (weak, nonatomic) IBOutlet UILabel *labelSubject;
@property (weak, nonatomic) IBOutlet UILabel *labelCase;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnModify;
@property (weak, nonatomic) IBOutlet UILabel *labelErrMessage;

@property (weak, nonatomic) IBOutlet UILabel *labelTType;
@property (weak, nonatomic) IBOutlet UILabel *labelTAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelTPos;
@property (weak, nonatomic) IBOutlet UILabel *labelTSubject;
@property (weak, nonatomic) IBOutlet UILabel *labelTCase;
@property (weak, nonatomic) IBOutlet UILabel *labelTStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelTDescription;
@end
