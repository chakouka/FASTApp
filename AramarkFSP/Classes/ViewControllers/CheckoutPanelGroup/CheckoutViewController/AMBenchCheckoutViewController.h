//
//  AMBenchCheckoutViewController.h
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
@protocol  AMBenchCheckoutViewControllerDelegate;

@interface AMBenchCheckoutViewController : UIViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIPopoverControllerDelegate
>
{
        NSMutableArray *arrInvoiceItems;
        NSMutableArray *arrResultAssetRequest;
        NSString *strSelectedFilters;
}

@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *arrInvoiceItems;
@property (strong, nonatomic) NSMutableArray *arrCheckoutInfos;
@property (strong, nonatomic) AMWorkOrder *workOrder;
@property (weak, nonatomic) id<AMBenchCheckoutViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *strNotes;
@property (strong, nonatomic) NSString *strRepairCode;
@property (strong, nonatomic) NSMutableArray *arrResultAssetRequest;

- (id)initWithWorkOrder:(NSDictionary *)aWorkOrder;
- (IBAction)clickSubmitBtn:(UIButton *)sender;
- (void)setupDataSourceByWorkOrder:(NSDictionary *)aWorkOrder;
- (void)refreshToInitialization;

@end

@protocol AMBenchCheckoutViewControllerDelegate <NSObject>

- (void)didClickCheckoutViewControllerNextBtn;

@end