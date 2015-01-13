//
//  AMInvoiceTitleTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/22/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMInvoiceTitleTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelCase;
@property (weak, nonatomic) IBOutlet UILabel *labelRequestedBy;
@property (weak, nonatomic) IBOutlet UILabel *labelCompletedBy;
@property (weak, nonatomic) IBOutlet UILabel *labelCaseDate;

@property (weak, nonatomic) IBOutlet UILabel *labelTCase;
@property (weak, nonatomic) IBOutlet UILabel *labelTRequestedBy;
@property (weak, nonatomic) IBOutlet UILabel *labelTCompletedBy;
@property (weak, nonatomic) IBOutlet UILabel *labelTCaseDate;
@end
