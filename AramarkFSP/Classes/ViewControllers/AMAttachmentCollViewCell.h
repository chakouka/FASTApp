//
//  AMAttachmentCollViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMDBAttachment.h"

@interface AMAttachmentCollViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) AMDBAttachment *attachment;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
