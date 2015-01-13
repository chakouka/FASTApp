//
//  ColumnViewController.h
//  ChartTest
//
//  Created by PwC on 5/28/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColumnInfo;

@protocol ColumnViewControllerDelegate;

@interface ColumnViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) id<ColumnViewControllerDelegate> delegate;

- (void)refreshWithInfo:(ColumnInfo *)aInfo;

@end

@protocol ColumnViewControllerDelegate <NSObject>

- (void)columnViewControllerClickedWithInfo:(ColumnInfo *)aInfo;

@end
