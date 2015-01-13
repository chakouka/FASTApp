//
//  AMAddNewCaseViewController.h
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AMNewCaseViewControllerDelegate <NSObject>

- (void)didClickSaveNewCase:(BOOL)success;

@end

typedef NS_ENUM(NSInteger, AddNewCasePageSource) {
    AddNewCasePageSource_Account = 0,
    AddNewCasePageSource_PoS,
    AddNewCasePageSource_History,
    AddNewCasePageSource_New,
    AddNewCasePageSource_Summary,
};

@interface AMAddNewCaseViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSString *strPoSId;
    NSString *strAccountId;
    NSString *strMEICustomer;
    AMDBNewCase *aNewCase;
    BOOL    isPop;
    AddNewCasePageSource source;
}

@property (strong, nonatomic) AMDBNewCase *aNewCase;
@property (strong, nonatomic) NSString *strPoSId;
@property (strong, nonatomic) NSString *strAccountId;
@property (strong, nonatomic) NSString *strMEICustomer;
@property (assign, nonatomic) id<AMNewCaseViewControllerDelegate> delegate;
@property (assign, nonatomic) BOOL    isPop;
@property (assign, nonatomic) AddNewCasePageSource source;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;

- (void)refreshWithInfo;
- (IBAction)clickSaveBtn:(id)sender;
@end
