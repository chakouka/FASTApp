//
//  AMCustomCellView.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/19/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMLocation.h"

@protocol AMCustomCellViewDelegate;

@interface AMCustomCellView : UIView


@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueTextField;

@property (weak, nonatomic) IBOutlet UIButton *updateSiteSurveyButton;
@property (strong, nonatomic) AMLocation *assignedLocation;
@property (weak, nonatomic) id<AMCustomCellViewDelegate> delegate;

@end


@protocol AMCustomCellViewDelegate <NSObject>

- (void)didTappedOnUpdateSiteSurvey:(AMLocation *)location;

@end