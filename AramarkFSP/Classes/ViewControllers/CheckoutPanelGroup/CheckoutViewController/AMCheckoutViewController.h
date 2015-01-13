//
//  AMCheckoutViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

/***************************************************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM000121: Check Out on Install WO Adding Asset and Warning. By Hari Kolasani. 12/9/2014
 ***************************************************************************************************************/

#import <UIKit/UIKit.h>

@class AMWorkOrder;
@protocol  AMCheckoutViewControllerDelegate;

@interface AMCheckoutViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate
>
{
        NSMutableArray *arrInvoiceItems;
        NSMutableArray *arrResultAssetRequest;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *arrInvoiceItems;
@property (strong, nonatomic) NSMutableArray *arrCheckoutInfos;
@property (strong, nonatomic) AMWorkOrder *workOrder;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) id<AMCheckoutViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateNew;
@property (weak, nonatomic) IBOutlet UILabel *labelSubTitle;
@property (strong, nonatomic) NSString *strNotes;
@property (strong, nonatomic) NSString *strRepairCode;

@property (strong, nonatomic) NSMutableArray *arrResultAssetRequest;

- (id)initWithWorkOrder:(AMWorkOrder *)aWorkOrder;
- (IBAction)clickSubmitBtn:(UIButton *)sender;
- (void)setupDataSourceByWorkOrder:(AMWorkOrder *)aWorkOrder;
- (void)refreshToInitialization;
- (IBAction)clickCreatNewBtn:(UIButton *)sender;
@end

@protocol AMCheckoutViewControllerDelegate <NSObject>

- (void)didClickCheckoutViewControllerNextBtn;

- (void)didClickCheckoutViewControllerCreatNewBtn;

@end