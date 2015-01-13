//
//  AMInvoiceCaseTableViewSection.h
//  AramarkFSP
//
//  Created by FYH on 7/28/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMInvoiceCaseTableViewSection : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelCase;
@property (weak, nonatomic) IBOutlet UILabel *labelRequestedBy; //Change Contact Name
@property (weak, nonatomic) IBOutlet UILabel *labelCompletedBy; //Change Created Date
@property (weak, nonatomic) IBOutlet UILabel *labelCaseDate;    //Change Closed Date

@property (weak, nonatomic) IBOutlet UILabel *labelTCase;
@property (weak, nonatomic) IBOutlet UILabel *labelTRequestBy;
@property (weak, nonatomic) IBOutlet UILabel *labelTCreatedDate;
@property (weak, nonatomic) IBOutlet UILabel *labelTClosedDate;
@end
