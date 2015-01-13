//
//  AMAttachmentCollectionViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 6/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMPopoverSelectTableViewController.h"
#import "AMWorkOrder.h"
#import "AMAttachmentCollViewLocalCell.h"
#import <QuickLook/QuickLook.h>

@interface AMAttachmentCollectionViewController : UICollectionViewController<AMPopoverSelectTableViewControllerDelegate, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AMAttachmentCollViewLocalCellDelegate>

@property (nonatomic, strong) NSArray *remoteAttArr;
@property (nonatomic, strong) NSArray *localAttArr;
@property (nonatomic, strong) AMWorkOrder *workOrder;

@end
