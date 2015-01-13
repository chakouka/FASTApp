//
//  AMPendingWOViewController.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/15/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AMRelatedWOViewControllerDelegate;

@interface AMRelatedWOViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *collapseButton;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *pendingWOArray;
@property (strong, nonatomic) NSString *sectionTitle;
@property (nonatomic) AMRelatedWOType type;
@property (weak, nonatomic) id<AMRelatedWOViewControllerDelegate> delegate;

- (id)initWithType:(AMRelatedWOType)type sectionTitle:(NSString *)sectionTitle;

@end

@protocol AMRelatedWOViewControllerDelegate <NSObject>

@optional
- (void)didTappedOnCollapseButton:(UIButton *)collapseBtn;

@end
