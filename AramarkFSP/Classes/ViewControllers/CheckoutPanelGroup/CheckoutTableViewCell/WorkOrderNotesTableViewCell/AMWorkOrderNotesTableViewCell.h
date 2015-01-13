//
//  AMWorkOrderNotesTableViewCell.h
//  AramarkFSP
//
//  Created by PwC on 5/29/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMWorkOrderNotesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *textViewWorkOrderNotes;
@property (weak, nonatomic) IBOutlet UILabel *labelTWorkOrderNotes;

- (void)refreshData:(NSMutableDictionary *)dicInfo;

@end
