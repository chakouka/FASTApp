//
//  AMInvoiceViewController.h
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AMInvoiceViewControllerDelegate;
@class AMAddNewContactViewController;
@interface AMInvoiceViewController : UIViewController
<
UITableViewDelegate,
UITableViewDataSource
>

@property (strong, nonatomic) NSMutableArray *arrInvoiceInfos;
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewSignature;
@property (weak, nonatomic) id<AMInvoiceViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *viewContact;
@property (weak, nonatomic) IBOutlet UILabel *labelContact;
@property (weak, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldLastName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UITextField *textFieldContactInfo;
@property (weak, nonatomic) IBOutlet UIView *viewPrice;
@property (strong, nonatomic) NSMutableArray *tempInvoiceList;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;

@property (weak, nonatomic) IBOutlet UILabel *labelTTotalPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelTChooseContact;
@property (weak, nonatomic) IBOutlet UILabel *labelTOr;
@property (weak, nonatomic) IBOutlet UILabel *labelTFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelTTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelTContactPhone;
@property (weak, nonatomic) IBOutlet UILabel *labelTContactEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelTClientSignature;
@property (weak, nonatomic) IBOutlet UILabel *labelTMCEmail;

@property (weak, nonatomic) IBOutlet UIImageView *imageSelected;
@property (strong, nonatomic) IBOutlet UITextView *txtSelectedFilters;


- (IBAction)clickSubmitBtn:(UIButton *)sender;
- (IBAction)clickSignatureBtn:(id)sender;
- (void)refreshToInitialization;
- (void)setupDataSourceByInfo:(AMWorkOrder *)aWorkOrder;
- (IBAction)clickContactBtn:(UIButton *)sender;
- (IBAction)clickMCCheckboxBtn:(UIButton *)sender;

@end

@protocol AMInvoiceViewControllerDelegate <NSObject>

- (void)didClickInvoiceViewControllerNextBtn;

@end

@protocol AMAddNewContactViewControllerDelegate <NSObject>

-(void)dismissAMAddNewContactViewController:(AMAddNewContactViewController *)vc dictContactInfo:(NSMutableDictionary *)dictContactInfo;

@end
