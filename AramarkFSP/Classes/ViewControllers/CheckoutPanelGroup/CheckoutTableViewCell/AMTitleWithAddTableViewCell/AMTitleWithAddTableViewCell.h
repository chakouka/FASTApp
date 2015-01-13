//
//  AMTitleWithAddTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMTitleWithAddTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UILabel *labelAdd;

- (void)refreshData:(NSMutableDictionary *)dicInfo;

@end
