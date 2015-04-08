//
//  AMAddNewContactViewController.h
//  AramarkFSP
//
//  Created by bkendall on 3/25/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AMAddNewContactViewControllerDelegate;


@interface AMAddNewContactViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
        NSMutableDictionary *dicContactInfo;
}
@property (weak, nonatomic) IBOutlet UITableView *tableViewMain;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) AMWorkOrder *selectedWorkOrder;
@property (strong, nonatomic) AMContact *selectedContact;
@property (assign, nonatomic) BOOL isPop;
@property (nonatomic, strong) NSMutableDictionary *dicContactInfo;
@property (weak, nonatomic) id<AMAddNewContactViewControllerDelegate> delegate;
- (void)refreshWithInfo;
- (IBAction)clickSaveBtn:(id)sender;
@end

@protocol AMAddNewContactViewControllerDelegate <NSObject>
@optional
- (void)dismissAMAddNewContactViewController:(AMAddNewContactViewController *)vc dictContactInfo:(NSMutableDictionary *)dictContactInfo;
@end

