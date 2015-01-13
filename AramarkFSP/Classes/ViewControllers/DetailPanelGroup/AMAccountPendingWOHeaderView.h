//
//  AMAccountPendingWOHeaderView.h
//  AramarkFSP
//
//  Created by Aaron Hu on 10/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMAccountPendingWOHeaderView : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelWO;
@property (weak, nonatomic) IBOutlet UILabel *labelWOType;
@property (weak, nonatomic) IBOutlet UILabel *labelComplaintCode;
@property (weak, nonatomic) IBOutlet UILabel *labelMachineType;
//@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelPriority;
@property (weak, nonatomic) IBOutlet UILabel *labelPOS;

@end
