//
//  AMSummaryTVC.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/3/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMSummaryFutureCell.h"

@protocol AMSummaryTVCDelegate <NSObject>

- (void)didWorkNowClicked:(AMWorkOrder *)workOrder;

@end

@interface AMSummaryTVC : UITableViewController<AMSummaryFutureCellDelegate>

@property (nonatomic,assign) id<AMSummaryTVCDelegate> delegate;

@property (nonatomic, strong) NSArray *oneDayOrders;
@property (nonatomic,strong) NSDate *date;
@property (nonatomic) BOOL isHistoryDate;
@property (nonatomic) NSInteger tag;


@end
