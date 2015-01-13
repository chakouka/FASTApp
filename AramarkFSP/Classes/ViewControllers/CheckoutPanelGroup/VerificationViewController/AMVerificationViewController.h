//
//  AMVerificationViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMVerificationViewControllerDelegate;

@interface AMVerificationViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>
{
    NSMutableArray *arrVerificationInfos;
}

@property (strong, nonatomic) NSMutableArray *arrVerificationInfos;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, weak) id<AMVerificationViewControllerDelegate> delegate;
@property (strong, nonatomic) NSMutableArray *arrResultAsset;
@property (strong, nonatomic) NSMutableArray *arrResultAssetRequest;

- (IBAction)clickNextBtn:(id)sender;
- (void)setupDataSourceByInfo:(AMWorkOrder *)aWorkOrder;

@end

@protocol AMVerificationViewControllerDelegate <NSObject>

- (void)didClickVerificationViewControllerNextBtn;

@end