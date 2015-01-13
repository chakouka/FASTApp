//
//  AMAttachmentCollViewLocalCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 7/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMDBAttachment.h"

@protocol AMAttachmentCollViewLocalCellDelegate <NSObject>

- (void)didTappedOnDeleteButton:(AMDBAttachment *)attachment;

- (void)didTappedOnPreviewButton:(AMDBAttachment *)attachment withIndex:(NSInteger)index;

@end

@interface AMAttachmentCollViewLocalCell : UICollectionViewCell<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) AMDBAttachment *attachment;

@property (weak, nonatomic) id<AMAttachmentCollViewLocalCellDelegate> delegate;

@end
