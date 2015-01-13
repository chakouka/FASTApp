//
//  AMSectionHeaderAttachmentView.h
//  AramarkFSP
//
//  Created by Aaron Hu on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMSectionHeaderAttachmentViewDelegate <NSObject>

- (void)didSelectedOnAttachmentButton:(BOOL)isSelected;

@end

@interface AMSectionHeaderAttachmentView : UIView

@property (weak, nonatomic) id<AMSectionHeaderAttachmentViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *attachmentButton;

@end
