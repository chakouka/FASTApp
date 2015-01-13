//
//  AMReportWOByTypeTodayViewController.h
//  AramarkFSP
//
//  Created by Jonathan.WANG on 7/21/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMReportWOByTypeTodayViewController : UIViewController

@property (nonatomic,strong) NSArray *arr_workOrderToday;

-(void)drawBar;

@end
