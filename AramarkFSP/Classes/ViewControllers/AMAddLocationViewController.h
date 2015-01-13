//
//  AMAddLocationViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMLocation.h"

@protocol AMAddLocationViewControllerDelegate;

@interface AMAddLocationViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *locationNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *addLocationButton;

@property (weak, nonatomic) id<AMAddLocationViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UILabel *labelTLocationName;

@end

@protocol AMAddLocationViewControllerDelegate <NSObject>

- (void)didTapOnSaveLocation:(AMLocation *)newLocation;

@end
