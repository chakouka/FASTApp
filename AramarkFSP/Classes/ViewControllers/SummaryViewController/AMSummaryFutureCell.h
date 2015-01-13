//
//  AMSummaryFutureCell.h
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMSummaryLabel.h"

@protocol AMSummaryFutureCellDelegate <NSObject>

-(void)didWorkNowButtonClicked:self;

@end

@interface AMSummaryFutureCell : UITableViewCell

@property(nonatomic,assign)id<AMSummaryFutureCellDelegate> delegate;

@property (nonatomic,strong) AMWorkOrder *order;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_number;
@property (weak, nonatomic) IBOutlet UIButton *btnWorkNow;

@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTEstimatedStartTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTEstimatedEndTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTCaseNo;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTContact;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTWoCreatedDate;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTPriority;

@end
