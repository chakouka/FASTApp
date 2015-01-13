//
//  AMSectionFooterView.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/23/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AMSectionFooterViewDelegate;

@interface AMSectionFooterView : UIView

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) id<AMSectionFooterViewDelegate> delegate;

@end

@protocol AMSectionFooterViewDelegate<NSObject>

@optional
- (void)didTappedOnSaveButton;

- (void)didTappedOnCreateButton;

@end