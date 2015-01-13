//
//  AMLocationViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMWOTabBaseViewController.h"
#import "AMAddLocationViewController.h"
#import "AMCustomCellView.h"
#import "AMUpdateSiteSurveyViewController.h"
#import "AMWorkOrder.h"

@interface AMLocationViewController : AMWOTabBaseViewController<AMAddLocationViewControllerDelegate, AMCustomCellViewDelegate, AMUpdateSiteSurveyViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *locationListScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *updateSiteSurveyScrollView;
@property (weak, nonatomic) IBOutlet UIButton *cancelSurvey;
@property (strong, nonatomic) NSArray *locationArr;
@property (strong, nonatomic) NSMutableArray *locationsView;
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) AMAddLocationViewController *addLocationVC;
@property (strong, nonatomic) AMUpdateSiteSurveyViewController *updateSiteSurveyVC;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (strong, nonatomic) AMWorkOrder *relatedWO;

@end
