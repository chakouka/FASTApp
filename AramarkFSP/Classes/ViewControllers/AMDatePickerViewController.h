//
//  AMDatePickerViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 7/9/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol AMDatePickerViewControllerDelegate <NSObject>

- (void)didTappedOnOKButton:(NSDate *)date;

- (void)didTappedOnCancelButton;

@end

@interface AMDatePickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) id<AMDatePickerViewControllerDelegate> delegate;

@end
