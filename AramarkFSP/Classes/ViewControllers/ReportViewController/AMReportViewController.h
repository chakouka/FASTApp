//
//  AMReportViewController.h
//  AramarkFSP
//
//  Created by PwC on 4/29/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMPieChart.h"
#import "AMPopoverSelectTableViewController.h"
#import "GAITrackedViewController.h"

@interface AMReportViewController : GAITrackedViewController<AMPieChartDataSource,AMPieChartDelegate,AMPopoverSelectTableViewControllerDelegate>

@end
