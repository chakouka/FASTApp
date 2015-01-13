//
//  AMPendingWOHeaderView.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMPendingWOHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *labelWO;
@property (weak, nonatomic) IBOutlet UILabel *labelWOType;
@property (weak, nonatomic) IBOutlet UILabel *labelComplaintCode;
@property (weak, nonatomic) IBOutlet UILabel *labelMachineType;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelPriority;

@end
