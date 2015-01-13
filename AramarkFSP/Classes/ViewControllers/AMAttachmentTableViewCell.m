//
//  AMAttachmentTableViewCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAttachmentTableViewCell.h"

@implementation AMAttachmentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.collectionVC = [[AMAttachmentCollectionViewController alloc] initWithNibName:@"AMAttachmentCollectionViewController" bundle:nil];
        self.collectionVC.collectionView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame));
        [self.contentView addSubview:self.collectionVC.collectionView];
    }
    return self;
}

- (void)awakeFromNib
{

}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    
//    self.collectionVC.view.frame = self.contentView.bounds;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)setExistingAttArr:(NSArray *)existingAttArr
//{
//    _existingAttArr = existingAttArr;
//    self.collectionVC.existingAttArr = existingAttArr;
//
//}
//
//- (void)setAddNewAttArr:(NSArray *)addNewAttArr
//{
//    _addNewAttArr = addNewAttArr;
//    self.collectionVC.addNewAttArr = [NSMutableArray arrayWithArray:addNewAttArr];
//}
//
- (void)setWorkOrder:(AMWorkOrder *)workOrder
{
    _workOrder = workOrder;
    self.collectionVC.workOrder = workOrder;
}

@end
