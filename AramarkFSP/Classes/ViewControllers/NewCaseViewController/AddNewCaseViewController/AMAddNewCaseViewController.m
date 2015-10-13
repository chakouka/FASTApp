//
//  AMAddNewCaseViewController.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAddNewCaseViewController.h"
#import "AMNewCaseCell.h"
#import "AMNormalTitleSection.h"
#import "AMPopoverSelectTableViewController.h"

#define TEXT_OF_GENERAL_COMPLAINT   @"General Complaints"

typedef NS_ENUM(NSInteger, CaseSection) {
    CaseSection_NewCases = 0,
};

typedef NS_ENUM (NSInteger, AddNewCaseTextInputType) {
	AddNewCaseTextInputType_CaseRecordType = 0,
	AddNewCaseTextInputType_Type,
	AddNewCaseTextInputType_PointOfService,
	AddNewCaseTextInputType_Priority,
	AddNewCaseTextInputType_Account,
	AddNewCaseTextInputType_MEICustomerNo,
	AddNewCaseTextInputType_Subject,
	AddNewCaseTextInputType_FirstName,
	AddNewCaseTextInputType_Email,
	AddNewCaseTextInputType_LastName,
	AddNewCaseTextInputType_AssetNo,
	AddNewCaseTextInputType_SerialNo,
    
	AddNewCaseTextInputType_Description,
};

typedef NS_ENUM (NSInteger, PopViewType) {
	PopViewType_NewCase_CaseRecordType = 1000,
	PopViewType_NewCase_Type,
	PopViewType_NewCase_Contact,
	PopViewType_NewCase_Asset,
    PopViewType_NewCase_Priority,
    PopViewType_NewCase_ComplaintCode,
};

@interface AMAddNewCaseViewController ()
<
UITextFieldDelegate,
UITextViewDelegate,
AMPopoverSelectTableViewControllerDelegate,
UIPopoverControllerDelegate
>
{
    NSMutableDictionary *dicCaseInfo;
    UIPopoverController *aPopoverVC;
    NSMutableArray *arrContacts;
    NSMutableArray *arrAssets;
    AMContact *selectContact;
    AMAsset *selectAsset;
}

@property (nonatomic, strong) AMContact *selectContact;
@property (nonatomic, strong) AMAsset *selectAsset;
@property (nonatomic, strong) UIPopoverController *aPopoverVC;
@property (nonatomic,strong) NSMutableDictionary *dicCaseInfo;
@property (nonatomic, strong) NSMutableArray *arrContacts;
@property (nonatomic, strong) NSMutableArray *arrAssets;
@end

@implementation AMAddNewCaseViewController
@synthesize source;
@synthesize dicCaseInfo;
@synthesize aPopoverVC;
@synthesize arrContacts;
@synthesize arrAssets;
@synthesize strAccountId;
@synthesize strPoSId;
@synthesize delegate;
@synthesize aNewCase;
@synthesize isPop;
@synthesize strMEICustomer;
@synthesize selectAsset;
@synthesize selectContact;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dicCaseInfo = [NSMutableDictionary dictionary];
        arrContacts = [NSMutableArray array];
        arrAssets =[NSMutableArray array];
        source = AddNewCasePageSource_New;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self refreshWithInfo];
    
    MyButtonTitle(self.btnSave, MyLocal(@"SAVE"));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
    //	DLog(@"viewWillLayoutSubviews : AMCheckoutViewController");
	self.view.frame = self.view.superview.bounds;
    self.tableViewMain.frame = self.view.superview.bounds;
}

#pragma mark -

- (void)refreshWithInfo
{
    switch (source) {
        case AddNewCasePageSource_New:
        {
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_RECORD_TYPE];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_TYPE];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_ACCOUNT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_POINT_OF_SERVICE];
            [self.dicCaseInfo setObject:@"Medium" forKey:KEY_OF_CASE_PRIORITY];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_SUBJECT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_CONTACT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_FIRST_NAME];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_LAST_NAME];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_EMAIL];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_DESCRIPTION];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_ASSET];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_ASSET_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_SERIAL_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_COMPLAINT_CODE];
        }
            break;
        case AddNewCasePageSource_Account:
        {
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_RECORD_TYPE];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_TYPE];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_ACCOUNT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_POINT_OF_SERVICE];
            [self.dicCaseInfo setObject:@"Medium" forKey:KEY_OF_CASE_PRIORITY];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_SUBJECT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_CONTACT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_FIRST_NAME];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_LAST_NAME];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_EMAIL];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_DESCRIPTION];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_ASSET];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_ASSET_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_SERIAL_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_COMPLAINT_CODE];
            
            if (strAccountId) {
                AMAccount *account = [[AMLogicCore sharedInstance] getAccountInfoByID:strAccountId];
                [self.dicCaseInfo setObject:[account.name length] == 0 ? @"" : account.name forKey:KEY_OF_CASE_ACCOUNT];
                
                NSArray *arrAsset = [[AMLogicCore sharedInstance] getAssetListByPoSID:strPoSId AccountID:strAccountId];
                
                [arrAssets removeAllObjects];
                
                for (AMAsset *aAsset in arrAsset) {
                    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                    [dicInfo setObject:[NSString stringWithFormat:@"%@%@%@", aAsset.machineNumber ? aAsset.machineNumber : @"", aAsset.machineNumber && aAsset.productName ? @"-" : @"", aAsset.productName ? aAsset.productName : @""] forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
                    [dicInfo setObject:aAsset forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
                    [arrAssets addObject:dicInfo];
                }
            }
        }
            break;
        case AddNewCasePageSource_Summary:
        case AddNewCasePageSource_PoS:
        {
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_RECORD_TYPE];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_TYPE];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_ACCOUNT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_POINT_OF_SERVICE];
            [self.dicCaseInfo setObject:@"Medium" forKey:KEY_OF_CASE_PRIORITY];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_SUBJECT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_CONTACT];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_FIRST_NAME];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_LAST_NAME];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_EMAIL];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_DESCRIPTION];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_ASSET];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_ASSET_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_SERIAL_NO];
            [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_COMPLAINT_CODE];

            if (strPoSId) {
                AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:strPoSId];
                [self.dicCaseInfo setObject:[pos.name length] == 0 ? @"" : pos.name forKey:KEY_OF_CASE_POINT_OF_SERVICE];
                [self.dicCaseInfo setObject:[pos.meiNumber length] == 0 ? @"" : pos.meiNumber forKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
                NSArray *arrContact = [[AMLogicCore sharedInstance] getContactListByPoSID:strPoSId];
                
                [arrContacts removeAllObjects];
                
                for (AMContact *aContact in arrContact) {
                    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                    [dicInfo setObject:aContact.name forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
                    [dicInfo setObject:aContact forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
                    [arrContacts addObject:dicInfo];
                }
            }
            
            if (strAccountId && strPoSId) {
                AMAccount *account = [[AMLogicCore sharedInstance] getAccountInfoByID:strAccountId];
                [self.dicCaseInfo setObject:[account.name length] == 0 ? @"" : account.name forKey:KEY_OF_CASE_ACCOUNT];
                
                NSArray *arrAsset = [[AMLogicCore sharedInstance] getAssetListByPoSID:strPoSId AccountID:strAccountId];
                
                [arrAssets removeAllObjects];
                
                for (AMAsset *aAsset in arrAsset) {
                    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                    [dicInfo setObject:[NSString stringWithFormat:@"%@%@%@", aAsset.machineNumber ? aAsset.machineNumber : @"", aAsset.machineNumber && aAsset.productName ? @"-" : @"", aAsset.productName ? aAsset.productName : @""] forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
                    [dicInfo setObject:aAsset forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
                    [arrAssets addObject:dicInfo];
                }
            }
        }
            break;
        case AddNewCasePageSource_History:
        {
            if ([aNewCase.recordTypeID length] == 0) {
                [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_RECORD_TYPE];
            }
            else
            {
                [self.dicCaseInfo setObject:[[AMLogicCore sharedInstance] getRecordTypeNameById:aNewCase.recordTypeID forObject:RECORD_TYPE_OF_CASE] forKey:KEY_OF_CASE_RECORD_TYPE];
            }
            
            [self.dicCaseInfo setObject:[aNewCase.type length] == 0 ? @"" : aNewCase.type forKey:KEY_OF_CASE_TYPE];
            
            [self.dicCaseInfo setObject:[aNewCase.accountName length] == 0 ? @"" : aNewCase.accountName forKey:KEY_OF_CASE_ACCOUNT];
            [self.dicCaseInfo setObject:[aNewCase.mEI_Customer length] == 0 ? @"" : aNewCase.mEI_Customer forKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
            [self.dicCaseInfo setObject:[aNewCase.posName length] == 0 ? @"" : aNewCase.posName forKey:KEY_OF_CASE_POINT_OF_SERVICE];
            [self.dicCaseInfo setObject:[aNewCase.priority length] == 0 ? @"" : aNewCase.priority forKey:KEY_OF_CASE_PRIORITY];
            [self.dicCaseInfo setObject:[aNewCase.subject length] == 0 ? @"" : aNewCase.subject forKey:KEY_OF_CASE_SUBJECT];
            
            if ([aNewCase.contactID length] == 0) {
                [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_CONTACT];
            }
            else
            {
                AMContact *contact = [[AMLogicCore sharedInstance] getContactInfoByID:aNewCase.contactID];
                [self.dicCaseInfo setObject:contact.name forKey:KEY_OF_CASE_CHOOSE_CONTACT];
            }
            
            [self.dicCaseInfo setObject:[aNewCase.firstName length] == 0 ? @"" : aNewCase.firstName forKey:KEY_OF_CASE_FIRST_NAME];
            [self.dicCaseInfo setObject:[aNewCase.lastName length] == 0 ? @"" : aNewCase.lastName forKey:KEY_OF_CASE_LAST_NAME];
            [self.dicCaseInfo setObject:[aNewCase.contactEmail length] == 0 ? @"" : aNewCase.contactEmail forKey:KEY_OF_CASE_EMAIL];
            [self.dicCaseInfo setObject:[aNewCase.caseDescription length] == 0 ? @"" : aNewCase.caseDescription forKey:KEY_OF_CASE_DESCRIPTION];
            
            if ([aNewCase.assetID length] == 0) {
                [self.dicCaseInfo setObject:@"" forKey:KEY_OF_CASE_CHOOSE_ASSET];
            }
            else
            {
                AMAsset *asset = [[AMLogicCore sharedInstance] getAssetInfoByID:aNewCase.assetID];
                selectAsset = asset;
                [self.dicCaseInfo setObject:asset.assetName forKey:KEY_OF_CASE_CHOOSE_ASSET];
            }
            
            [self.dicCaseInfo setObject:[aNewCase.assetNumber length] == 0 ? @"" : aNewCase.assetNumber forKey:KEY_OF_CASE_ASSET_NO];
            [self.dicCaseInfo setObject:[aNewCase.serialNumber length] == 0 ? @"" : aNewCase.serialNumber forKey:KEY_OF_CASE_SERIAL_NO];
            
            if (strPoSId) {
                AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:strPoSId];
                [self.dicCaseInfo setObject:[pos.name length] == 0 ? @"" : pos.name forKey:KEY_OF_CASE_POINT_OF_SERVICE];
                
                NSArray *arrContact = [[AMLogicCore sharedInstance] getContactListByPoSID:strPoSId];
                
                [arrContacts removeAllObjects];
                
                for (AMContact *aContact in arrContact) {
                    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                    [dicInfo setObject:aContact.name forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
                    [dicInfo setObject:aContact forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
                    [arrContacts addObject:dicInfo];
                }
            }
            
            if (strAccountId && strPoSId) {
                AMAccount *account = [[AMLogicCore sharedInstance] getAccountInfoByID:strAccountId];
                [self.dicCaseInfo setObject:[account.name length] == 0 ? @"" : account.name forKey:KEY_OF_CASE_ACCOUNT];
                
                NSArray *arrAsset = [[AMLogicCore sharedInstance] getAssetListByPoSID:strPoSId AccountID:strAccountId];
                
                [arrAssets removeAllObjects];
                
                for (AMAsset *aAsset in arrAsset) {
                    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                    [dicInfo setObject:[NSString stringWithFormat:@"%@ %@", aAsset.assetName ? aAsset.assetName : @"", aAsset.machineNumber ? aAsset.machineNumber : @""] forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
                    [dicInfo setObject:aAsset forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
                    [arrAssets addObject:dicInfo];
                }
            }
            
        }
            break;
    }
    
    [self.tableViewMain reloadData];
}

#pragma mark -

- (IBAction)clickSaveBtn:(id)sender {
    
    DLog(@"%@",dicCaseInfo);
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_FIRST_NAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input First Name")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_EMAIL] length] != 0 && ![AMUtilities isValidEmailValueTyped:[self.dicCaseInfo objectForKey:KEY_OF_CASE_EMAIL]]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Valid Email Address")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case Record Type")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_TYPE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case Type")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_ACCOUNT] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case Account")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_MEI_CUSTOMER_NO] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case MEI Customer Number")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_POINT_OF_SERVICE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case Point of Service")];
        return;
    }
    
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_SUBJECT] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case Subject")];
        return;
    }
    
    if ([[dicCaseInfo objectForKey:KEY_OF_CASE_DESCRIPTION] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Case Description")];
        return ;
    }
    
    if ([[dicCaseInfo objectForKey:KEY_OF_CASE_LAST_NAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Last Name")];
        return ;
    }
    if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_TYPE] isEqualToString:MyLocal(@"Repair")]) {        
        if ([[dicCaseInfo objectForKey:KEY_OF_CASE_COMPLAINT_CODE] length] == 0) {
            [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Complaint Code")];
            return;
        }
    }
    
    switch (source) {
        case AddNewCasePageSource_New:
        {
        }
            break;
        case AddNewCasePageSource_Account:
        case AddNewCasePageSource_Summary:
        case AddNewCasePageSource_PoS:
        case AddNewCasePageSource_History:
        {
            if (strPoSId) {
                AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:strPoSId];
                
                if (![[self.dicCaseInfo objectForKey:KEY_OF_CASE_POINT_OF_SERVICE] isEqualToString:pos.name]) {
                    self.strPoSId = nil;
                }
            }
            
            if (strAccountId) {
                AMAccount *account = [[AMLogicCore sharedInstance] getAccountInfoByID:strAccountId];
                
                if (![[self.dicCaseInfo objectForKey:KEY_OF_CASE_ACCOUNT] isEqualToString:account.name]) {
                    self.strAccountId = nil;
                }
            }
        }
            break;
    }
    
    [[AMLogicCore sharedInstance] createNewCaseInDBWithSetupBlock:^(AMDBNewCase *newCase) {
        
        newCase.accountID = strAccountId;
        newCase.assetID = selectAsset.assetID;
        
        newCase.caseDescription = [dicCaseInfo objectForKey:KEY_OF_CASE_DESCRIPTION];
        newCase.contactEmail = [dicCaseInfo objectForKey:KEY_OF_CASE_EMAIL];
        newCase.contactID = selectContact.contactID;
        
        newCase.firstName = [dicCaseInfo objectForKey:KEY_OF_CASE_FIRST_NAME];
        newCase.lastName = [dicCaseInfo objectForKey:KEY_OF_CASE_LAST_NAME];
        newCase.mEI_Customer = [dicCaseInfo objectForKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
        newCase.point_of_Service = strPoSId;
        newCase.priority = [dicCaseInfo objectForKey:KEY_OF_CASE_PRIORITY];
        newCase.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:[dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE] forObject:RECORD_TYPE_OF_CASE];
        newCase.recordTypeName = [dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE];
        newCase.serialNumber = [dicCaseInfo objectForKey:KEY_OF_CASE_SERIAL_NO];
        newCase.subject = [dicCaseInfo objectForKey:KEY_OF_CASE_SUBJECT];
        newCase.type = [dicCaseInfo objectForKey:KEY_OF_CASE_TYPE];
        newCase.accountName = [dicCaseInfo objectForKey:KEY_OF_CASE_ACCOUNT];
        newCase.posID = strPoSId;
        newCase.posName = [dicCaseInfo objectForKey:KEY_OF_CASE_POINT_OF_SERVICE];
        newCase.assetNumber = [dicCaseInfo objectForKey:KEY_OF_CASE_ASSET_NO];
        newCase.complaintCode = [dicCaseInfo objectForKey:KEY_OF_CASE_COMPLAINT_CODE];
        
    } completion:^(NSInteger type, NSError *error) {
        MAIN(^{
            if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
                return ;
            }
            else{
                
                [UIAlertView showWithTitle:@""
                                   message:MyLocal(@"New Case is created successfully but not synced.")
                         cancelButtonTitle:MyLocal(@"OK")
                         otherButtonTitles:nil
                                  tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          if (isPop) {
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                          }
                                          else
                                          {
                                              
                                          }
                                          if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSaveNewCase:)]) {
                                              //
                                              [self.delegate didClickSaveNewCase:YES];
                                          }
                                      }
                                  }];
            }
            
        });
    }];
}

- (void)clickCaseRecordBtn:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewCase_CaseRecordType;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Equipment") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Equipment"}];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_GENERAL_COMPLAINT) ,kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_GENERAL_COMPLAINT}];
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)clickCaseTypeBtn:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewCase_Type;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    if ([[dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE] isEqualToString:@"Equipment"]) {
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Swap") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Swap" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Repair") , kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Repair"}];
    }
    else if([[dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE] isEqualToString:TEXT_OF_GENERAL_COMPLAINT])
    {
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_GENERAL_COMPLAINT) ,kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_GENERAL_COMPLAINT}];
    }
    else
    {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Choose Case Record Type First")];
        return ;
    }
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

- (void)clickCaseContactBtn:(UIButton *)sender
{
    
    [self.tableViewMain endEditing:YES];
    
    if ([arrContacts count] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Contact List Empty")];
        return;
    }
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewCase_Contact;
	popView.arrInfos = arrContacts;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)clickCaseAssetBtn:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    if ([arrAssets count] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Asset List Empty")];
        return;
    }
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewCase_Asset;
	popView.arrInfos = arrAssets;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)clickComplaintCodeBtn:(UIButton *)sender
{
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
    popView.delegate = self;
    popView.tag = PopViewType_NewCase_ComplaintCode;
    
    NSMutableArray *arrInfos = [NSMutableArray array];

    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Bad Taste"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Bad Taste") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Bad Taste")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Brewing Problem"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Brewing Problem") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Brewing Problem")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Desiginated Shop Time"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Desiginated Shop Time") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Desiginated Shop Time")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Dripping"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Dripping") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Dripping")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Equipment Exchange"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Equipment Exchange") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Equipment Exchange")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Filter Exchange"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Filter Exchange") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Filter Exchange")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Hot Shot"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Hot Shot") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Hot Shot")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Install Equipment"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Install Equipment") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Install Equipment")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Machine Leaking"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Machine Leaking") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Machine Leaking")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Micro Market Kiosk"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Micro Market Kiosk") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Micro Market Kiosk")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Move Equipment"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Move Equipment") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Move Equipment")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"No Hot Water"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"No Hot Water") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"No Hot Water")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"No Ice Coming Out"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"No Ice Coming Out") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"No Ice Coming Out")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Pick-up Equipment"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Pick-up Equipment") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Pick-up Equipment")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Preventative Maintenance"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Preventative Maintenance") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Preventative Maintenance")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Site Survey"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Site Survey") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Site Survey")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Vending Machine Problem"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Vending Machine Problem") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Vending Machine Problem")}];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Water Dispenser Slow"),kAMPOPOVER_DICTIONARY_KEY_DATA : MyLocal(@"Water Dispenser Slow") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Water Dispenser Slow")}];
    
    popView.arrInfos = arrInfos;
    aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
    [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
    aPopoverVC.delegate = self;
    [aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
}

- (void)clickPriorityBtn:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewCase_Priority;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"High"),kAMPOPOVER_DICTIONARY_KEY_DATA : @"High" ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"High"}];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Medium"),kAMPOPOVER_DICTIONARY_KEY_DATA : @"Medium" ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Medium"}];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Low"),kAMPOPOVER_DICTIONARY_KEY_DATA : @"Low" ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Low"}];
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case CaseSection_NewCases:
        {
            AMNewCaseCell *cell = (AMNewCaseCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNewCaseCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNewCaseCell" owner:[AMNewCaseCell class] options:nil];
                cell = (AMNewCaseCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			[cell.btnCaseRecordType addTarget:self action:@selector(clickCaseRecordBtn:) forControlEvents:UIControlEventTouchUpInside];
			[cell.btnType addTarget:self action:@selector(clickCaseTypeBtn:) forControlEvents:UIControlEventTouchUpInside];
			[cell.btnChooseAsset addTarget:self action:@selector(clickCaseAssetBtn:) forControlEvents:UIControlEventTouchUpInside];
			[cell.btnChooseContact addTarget:self action:@selector(clickCaseContactBtn:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnPriority addTarget:self action:@selector(clickPriorityBtn:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnComplaintCode addTarget:self action:@selector(clickComplaintCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.textFieldCaseRecordType.delegate = self;
            cell.textFieldComplaintCode.delegate = self;
            cell.textFieldCaseRecordType.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_CaseRecordType);
            cell.textFieldCaseRecordType.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE] length] == 0 ? TEXT_OF_NULL : MyLocal([self.dicCaseInfo objectForKey:KEY_OF_CASE_RECORD_TYPE]);
            
            cell.textFieldType.delegate = self;
            cell.textFieldType.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_Type);
            cell.textFieldType.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_TYPE] length] == 0 ? TEXT_OF_NULL : MyLocal([self.dicCaseInfo objectForKey:KEY_OF_CASE_TYPE]);
            
            cell.textFieldPointOfService.delegate = self;
            cell.textFieldPointOfService.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_PointOfService);
            cell.textFieldPointOfService.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_POINT_OF_SERVICE] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_POINT_OF_SERVICE];
            
            cell.textFieldPriority.delegate = self;
            cell.textFieldPriority.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_Priority);
            cell.textFieldPriority.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_PRIORITY] length] == 0 ? TEXT_OF_NULL : MyLocal([self.dicCaseInfo objectForKey:KEY_OF_CASE_PRIORITY]);
            
            cell.textFieldAccount.delegate = self;
            cell.textFieldAccount.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_Account);
            cell.textFieldAccount.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_ACCOUNT] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_ACCOUNT];
            
            cell.textFieldMEICustomerNo.delegate = self;
            cell.textFieldMEICustomerNo.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_MEICustomerNo);
            cell.textFieldMEICustomerNo.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_MEI_CUSTOMER_NO] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
            
            cell.textFieldSubject.delegate = self;
            cell.textFieldSubject.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_Subject);
            cell.textFieldSubject.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_SUBJECT] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_SUBJECT];
            
            cell.textFieldFirstName.delegate = self;
            cell.textFieldFirstName.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_FirstName);
            cell.textFieldFirstName.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_FIRST_NAME] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_FIRST_NAME];
            
            cell.textFieldEmail.delegate = self;
            cell.textFieldEmail.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_Email);
            cell.textFieldEmail.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_EMAIL] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_EMAIL];
            
            cell.textFieldLastName.delegate = self;
            cell.textFieldLastName.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_LastName);
            cell.textFieldLastName.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_LAST_NAME] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_LAST_NAME];
            
            cell.textFieldAssetNo.delegate = self;
            cell.textFieldAssetNo.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_AssetNo);
            cell.textFieldAssetNo.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_ASSET_NO] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_ASSET_NO];
            
            cell.textFieldSerialNo.delegate = self;
            cell.textFieldSerialNo.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_SerialNo);
            cell.textFieldSerialNo.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_SERIAL_NO] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_SERIAL_NO];
            
            cell.textViewDescription.delegate = self;
            cell.textViewDescription.tag = (indexPath.section * 1000 + AddNewCaseTextInputType_Description);
            cell.textViewDescription.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_DESCRIPTION] length] == 0 ? TEXT_OF_WRITE_NOTE : [self.dicCaseInfo objectForKey:KEY_OF_CASE_DESCRIPTION];
            
            cell.labelChooseAsset.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_CHOOSE_ASSET] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_CHOOSE_ASSET];
            
            cell.labelChooseContact.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_CHOOSE_CONTACT] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_CHOOSE_CONTACT];
            
            cell.textFieldComplaintCode.text = [[self.dicCaseInfo objectForKey:KEY_OF_CASE_COMPLAINT_CODE] length] == 0 ? TEXT_OF_NULL : [self.dicCaseInfo objectForKey:KEY_OF_CASE_COMPLAINT_CODE];
            
            
            if ([[self.dicCaseInfo objectForKey:KEY_OF_CASE_TYPE] length] == 0 || ![[self.dicCaseInfo objectForKey:KEY_OF_CASE_TYPE] isEqualToString:MyLocal(@"Repair")])
            {
                [cell.viewComplaintCodeRequired setHidden:YES];
            } else {
                [cell.viewComplaintCodeRequired setHidden:NO];
            }
            switch (source) {
                case AddNewCasePageSource_New:
                {
                    
                }
                    break;
                case AddNewCasePageSource_Account:
                {
                    cell.textFieldAccount.enabled = NO;
                }
                    break;
                case AddNewCasePageSource_Summary:
                case AddNewCasePageSource_PoS:
                {
                    cell.textFieldAccount.enabled = NO;
                    cell.textFieldPointOfService.enabled = NO;
                    cell.textFieldMEICustomerNo.enabled = NO;
                }
                    break;
                case AddNewCasePageSource_History:
                {
                    
                }
                    break;
            }
            
            return cell;
        }
            break;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 575.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNormalTitleSection" owner:[AMNormalTitleSection class] options:nil];
    AMNormalTitleSection *aView = (AMNormalTitleSection *)[nib objectAtIndex:0];
    aView.labelTitle.text = MyLocal(@"New Case");
    
    [aView.btnCancel addTarget:self action:@selector(clickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    
    aView.viewCancel.hidden = !isPop;
    
	return aView;
}

#pragma mark -

- (void)clickCancelBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([textView.text isEqualToString:TEXT_OF_WRITE_NOTE]) {
		textView.text = @"";
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([AMUtilities isEmpty:textView.text] || [textView.text isEqualToString:TEXT_OF_WRITE_NOTE]) {
		textView.text = TEXT_OF_WRITE_NOTE;
		return;
	}
    
    NSInteger iType = textView.tag % 1000;
    
	switch (iType) {
		case AddNewCaseTextInputType_Description:
		{
            [self.dicCaseInfo setObject:textView.text forKey:KEY_OF_CASE_DESCRIPTION];
		}
            break;
            
		default:
			break;
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
	if ([textField.text isEqualToString:TEXT_OF_NULL]) {
		textField.text = @"";
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
	NSInteger iType = textField.tag % 1000;
    
    switch (iType) {
        case AddNewCaseTextInputType_CaseRecordType:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_RECORD_TYPE];
        }
            break;
        case AddNewCaseTextInputType_Type:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_LASTNAME];
        }
            break;
        case AddNewCaseTextInputType_PointOfService:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_POINT_OF_SERVICE];
        }
            break;
        case AddNewCaseTextInputType_Priority:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_PRIORITY];
        }
            break;
        case AddNewCaseTextInputType_Account:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_ACCOUNT];
        }
            break;
        case AddNewCaseTextInputType_MEICustomerNo:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_MEI_CUSTOMER_NO];
        }
            break;
        case AddNewCaseTextInputType_Subject:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_SUBJECT];
        }
            break;
        case AddNewCaseTextInputType_FirstName:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_FIRST_NAME];
        }
            break;
        case AddNewCaseTextInputType_Email:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_EMAIL];
        }
            break;
        case AddNewCaseTextInputType_LastName:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_LAST_NAME];
        }
            break;
        case AddNewCaseTextInputType_AssetNo:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_ASSET_NO];
        }
            break;
        case AddNewCaseTextInputType_SerialNo:
        {
            [self.dicCaseInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CASE_SERIAL_NO];
        }
            break;
    }
    
    if ([textField.text length] == 0) {
		textField.text = TEXT_OF_NULL;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	return YES;
}

- (NSString *)strChange:(NSString *)aString
{
    if ([AMUtilities isEmpty:aString] || [aString isEqualToString:TEXT_OF_NULL]) {
        return @"";
    }
    else
    {
        return aString;
    }
}

#pragma mark -

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
	if (aVerificationStatusTableViewController.tag == PopViewType_NewCase_CaseRecordType) {
        
		NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
		[self.dicCaseInfo setObject:strInfo forKey:KEY_OF_CASE_RECORD_TYPE];
        
        if ([strInfo isEqualToString:@"Equipment"]) {
            [self.dicCaseInfo setObject:@"Swap" forKey:KEY_OF_CASE_TYPE];
        }
        else if([strInfo isEqualToString:TEXT_OF_GENERAL_COMPLAINT])
        {
            [self.dicCaseInfo setObject:TEXT_OF_GENERAL_COMPLAINT forKey:KEY_OF_CASE_TYPE];
        }
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_NewCase_Type) {
        
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
		[self.dicCaseInfo setObject:strInfo forKey:KEY_OF_CASE_TYPE];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_NewCase_Contact) {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        selectContact = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
		[self.dicCaseInfo setObject:strInfo forKey:KEY_OF_CASE_CHOOSE_CONTACT];
        
        [self.dicCaseInfo setObject:[selectContact.firstName length] == 0 ? @"" : selectContact.firstName forKey:KEY_OF_CASE_FIRST_NAME];
        [self.dicCaseInfo setObject:[selectContact.lastName length] == 0 ? @"" : selectContact.lastName forKey:KEY_OF_CASE_LAST_NAME];
        [self.dicCaseInfo setObject:[selectContact.email length] == 0 ? @"" : selectContact.email forKey:KEY_OF_CASE_EMAIL];

		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_NewCase_Asset) {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        selectAsset = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
		[self.dicCaseInfo setObject:strInfo forKey:KEY_OF_CASE_CHOOSE_ASSET];
        [self.dicCaseInfo setObject:[selectAsset.machineNumber length] == 0 ? @"" : selectAsset.machineNumber forKey:KEY_OF_CASE_ASSET_NO];
        [self.dicCaseInfo setObject:[selectAsset.serialNumber length] == 0 ? @"" : selectAsset.serialNumber forKey:KEY_OF_CASE_SERIAL_NO];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
    else if(aVerificationStatusTableViewController.tag == PopViewType_NewCase_Priority){
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
		[self.dicCaseInfo setObject:strInfo forKey:KEY_OF_CASE_PRIORITY];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(aVerificationStatusTableViewController.tag == PopViewType_NewCase_ComplaintCode) {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        [self.dicCaseInfo setObject:strInfo forKey:KEY_OF_CASE_COMPLAINT_CODE];
        
        NSLog(@"didSelected : %@", aInfo);
        [aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark -

-(void) keyboardWillShow:(NSNotification *)note{
    
    if (CGRectGetHeight(self.tableViewMain.frame) < 300) {
        return;
    }
    
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect btnFrame = self.view.frame;
    btnFrame.size.height = btnFrame.size.height - keyboardBounds.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    [UIView setAnimationDelegate:self];
    self.tableViewMain.frame = btnFrame;
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    CGRect btnFrame = self.view.frame;
    btnFrame.size.height = self.view.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.tableViewMain.frame = btnFrame;
    [UIView commitAnimations];
}

@end
