//
//  AMSummaryCell.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/3/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMSummaryLabel.h"

@interface AMSummaryCell : UITableViewCell
@property (nonatomic, strong) AMWorkOrder *order;

@property (weak, nonatomic) IBOutlet AMSummaryLabel *lbl_number;
@property (weak, nonatomic) IBOutlet UIButton *btnNewCase;

@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTCheckInTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTCheckOutTime;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTCaseNo;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTContact;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTWoCreatedDate;
@property (weak, nonatomic) IBOutlet AMSummaryLabel *labelTRespondAndRecove;


//@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) NSArray *itemSizes; // of NSValue in CGSize format


// helper method
//-(NSArray *)cellHeightAndCollectionItemSizesForOrder:(AMWorkOrder *)order;

@end
