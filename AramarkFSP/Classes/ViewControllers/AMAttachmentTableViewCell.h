//
//  AMAttachmentTableViewCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMAttachmentCollectionViewController.h"
#import "AMWorkOrder.h"

@interface AMAttachmentTableViewCell : UITableViewCell

@property (strong ,nonatomic) AMAttachmentCollectionViewController *collectionVC;
//@property (strong, nonatomic)
//@property (nonatomic, strong) NSArray *existingAttArr;
//@property (nonatomic, strong) NSArray *addNewAttArr;
@property (nonatomic, strong) AMWorkOrder *workOrder;

@end
