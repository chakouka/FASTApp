//
//  AMInvoiceViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceViewController.h"
#import "AMInvoiceRepairTableViewCell.h"
#import "AMInvoiceTitleTableViewCell.h"
#import "AMPopoverSelectTableViewController.h"
#import "AMInvoiceRepairFilterNameCell.h"
#import "AMInvoiceRepairMaintenanceTableViewCell.h"
#import "AMInvoiceCodeTableViewSection.h"
#import "AMInvoiceCodeTableViewCell.h"
#import "AMInvoiceCaseTableViewSection.h"
#import "AMInvoiceWorkorderTitleView.h"
#import "NSDate+DateTools.h"
#import "AMAddNewContactViewController.h"
#import "AMSyncingManager.h"

#define KEY_OF_TITLE    @"TITLE"
#define KEY_OF_DATE     @"DATA"

typedef NS_ENUM (NSInteger, InvoiceTextInputType) {
	InvoiceTextInputType_FirstName = 11,
	InvoiceTextInputType_LastName,
	InvoiceTextInputType_Title,
	InvoiceTextInputType_ContactInfo,
};

typedef NS_ENUM (NSInteger, PopViewType) {
	PopViewType_Select_InvoiceCode = 1000,
	PopViewType_Select_Contact,
};

@interface AMInvoiceViewController ()
<
    UITextFieldDelegate,
    AMPopoverSelectTableViewControllerDelegate,
    UIPopoverControllerDelegate,
    AMAddNewContactViewControllerDelegate
>
{
	AMWorkOrder *workOrder;
	NSMutableArray *arrContacts;
	UIPopoverController *aPopoverVC;
	AMCase *aCase;
    BOOL isHiddenMoney;
    NSMutableArray *arrCodeItems;
    NSMutableArray *arrCodePriceList;
    NSMutableArray *arrSections;
    NSArray *arrInvoiceInfoGroups;
    AMInvoiceCodeTableViewSection *invoiceSectionView;
    AMInvoiceCaseTableViewSection *invoiceCaseSectionView;
    BOOL isMCEmailSelected;
    
    UIAlertView *syncAlertview;
    
}

@property (nonatomic, strong) AMWorkOrder *workOrder;
@property (nonatomic, strong) UIPopoverController *aPopoverVC;
@property (nonatomic, strong) NSMutableArray *arrContacts;
@property (nonatomic, strong) AMCase *aCase;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (nonatomic, assign) BOOL isHiddenMoney;
@property (nonatomic, strong) NSMutableArray *arrCodeItems;
@property (nonatomic, strong) NSMutableArray *arrCodePriceList;
@property (nonatomic, strong) NSMutableArray *arrSections;
@property (nonatomic, strong) NSArray *arrInvoiceInfoGroups;
@property (nonatomic, strong) AMInvoiceCodeTableViewSection *invoiceSectionView;
@property (nonatomic, strong) AMInvoiceCaseTableViewSection *invoiceCaseSectionView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation AMInvoiceViewController
@synthesize invoiceSectionView;
@synthesize workOrder;
@synthesize arrInvoiceInfos;
@synthesize delegate;
@synthesize aPopoverVC;
@synthesize arrContacts;
@synthesize aCase;
@synthesize isHiddenMoney;
@synthesize arrCodeItems;
@synthesize arrCodePriceList;
@synthesize arrSections;
@synthesize arrInvoiceInfoGroups;
@synthesize invoiceCaseSectionView;
@synthesize tempInvoiceList;
@synthesize txtSelectedFilters;
@synthesize activityView;
@synthesize btnSubmit;
@synthesize isMCEmailSelected;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		arrContacts = [NSMutableArray array];
        arrSections = [NSMutableArray array];
        isHiddenMoney = NO;
        isMCEmailSelected = NO;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

    syncAlertview = [[UIAlertView alloc] initWithTitle:MyLocal(@"Syncing")
                                               message:MyLocal(@"Please do not shut down device while syncing")
                                              delegate:nil
                                     cancelButtonTitle:nil
                                     otherButtonTitles:nil, nil];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(syncAlertview.bounds.size.width / 2, syncAlertview.bounds.size.height - 50);
    [indicator startAnimating];
    [syncAlertview setValue:indicator forKey:@"accessoryView"];

    [AMUtilities refreshFontInView:self.viewContact];
    
    [self.btnNext.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceCodeTableViewSection" owner:[AMInvoiceCodeTableViewSection class] options:nil];
    invoiceSectionView = (AMInvoiceCodeTableViewSection *)[nib objectAtIndex:0];
    [invoiceSectionView.btnAdd addTarget:self action:@selector(clickAddInvoiceCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
    invoiceSectionView.labelTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"INVOICE CODE")];
    invoiceSectionView.labelAddTitle.text = MyLocal(@"Invoice Code");
    
    NSArray *nib0 = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceCaseTableViewSection" owner:[AMInvoiceCaseTableViewSection class] options:nil];
    invoiceCaseSectionView = (AMInvoiceCaseTableViewSection *)[nib0 objectAtIndex:0];
    
    self.labelTTotalPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"TOTAL PRICE")];
    self.labelTChooseContact.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Choose Contact")];
    self.labelTOr.text = MyLocal(@"OR");
    self.labelTFirstName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"First Name")];
    self.labelTTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Title")];
    self.labelTLastName.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Last Name")];
    self.labelTContactPhone.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact Phone")];
    self.labelTContactEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Contact Email")];
    self.labelTClientSignature.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Client Signature")];
    self.labelTMCEmail.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Using MC Contact Email")];

    self.imageSelected.hidden = !isMCEmailSelected;
    
    [self.btnNext setTitle:MyLocal(@"SUBMIT") forState:UIControlStateNormal];
    [self.btnNext setTitle:MyLocal(@"SUBMIT") forState:UIControlStateHighlighted];
    
    [AMUtilities refreshFontInView:invoiceSectionView];
    [AMUtilities refreshFontInView:invoiceCaseSectionView];
    self.labelTTotalPrice.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:25.0];
    self.labelPrice.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:32.0];
    
    self.activityView = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityView.center=self.view.center;
    [self.view addSubview:self.activityView];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
//	DLog(@"viewWillLayoutSubviews : AMPointsViewController");
	self.view.frame = self.view.superview.bounds;
}

#pragma mark -

- (void)refreshToInitialization {
	NSString *strFileName = [self.workOrder.caseID length] == 0 ? TEXT_OF_DEFAULT_SIGNIMAGE_NAME : self.workOrder.caseID;
	self.imageViewSignature.image = [UIImage imageWithData:[AMFileManage dataWithName:strFileName]];
}

#pragma mark - Data

- (void)setupDataSourceByInfo:(AMWorkOrder *)aWorkOrder {
    
    if (self.workOrder && ![self.workOrder.woID isEqualToString:aWorkOrder.woID]) {
        self.labelContact.text = TEXT_OF_NULL;
        self.textFieldFirstName.text = TEXT_OF_NULL;
        self.textFieldLastName.text = TEXT_OF_NULL;
        self.textFieldTitle.text = TEXT_OF_NULL;
        self.textFieldContactInfo.text = TEXT_OF_NULL;
        self.textFieldEmail.text = TEXT_OF_NULL;
    }
    
    AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:aWorkOrder.posID];
    isHiddenMoney = [pos.naBillingType isEqualToLocalizedString:@"Central"];
    
    self.mainTableView.contentOffset = CGPointMake(0, 0);
    
    if (self.arrCodeItems && [self.arrCodeItems count] > 0) {
        [self.arrCodeItems removeAllObjects];
    }
    else
    {
        self.arrCodeItems = [NSMutableArray array];
    }
    
    if ([self.arrInvoiceInfos count] > 0) {
        [self.arrInvoiceInfos removeAllObjects];
    }
    
	self.workOrder = aWorkOrder;

     arrCodePriceList = [NSMutableArray arrayWithArray:[[AMLogicCore sharedInstance] getInvoiceCodeListByWOID:self.workOrder.woID]];
	self.arrInvoiceInfos = [NSMutableArray array];
	//*

	NSArray *arrContact = [[AMLogicCore sharedInstance] getContactListByPoSID:self.workOrder.posID];

	[arrContacts removeAllObjects];

	for (AMContact *aContact in arrContact) {
		NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
		[dicInfo setObject:aContact.name forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
		[dicInfo setObject:aContact forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
		[arrContacts addObject:dicInfo];
	}
    //bkk - 4/8/2015 - adding ADD NEW to Contact List
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:@"ADD NEW" forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
    [dicInfo setObject:@"ADD NEW" forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
    [arrContacts addObject:dicInfo];

	aCase = [[AMLogicCore sharedInstance] getCaseInfoByID:self.workOrder.caseID];

	if (!aCase) {
		return;
	}
    
    invoiceCaseSectionView.labelCase.text = aCase.caseNumber;
    
     NSTimeZone *aZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
    
    invoiceCaseSectionView.labelRequestedBy.text = [aCase.contactName length] == 0 ? @"" : aCase.contactName;    //Change Contact Name
    invoiceCaseSectionView.labelCompletedBy.text = aCase.createdDate ? [aCase.createdDate formattedDateWithFormat:@"yyyy.MM.dd" timeZone:aZone] : @"";      //Change Created Date
    invoiceCaseSectionView.labelCaseDate.text = [[NSDate date] formattedDateWithFormat:@"yyyy.MM.dd" timeZone:aZone];       //Change Closed Date

	CGFloat fTotalPrice = 0.0;
    
    NSArray *sortedArray = nil;
    
    NSArray *arrTemp = [[AMLogicCore sharedInstance] getInvoiceListByCaseID:aWorkOrder.caseID];
    
    if ([tempInvoiceList count] > 0) {
        [tempInvoiceList addObjectsFromArray:arrTemp];
        sortedArray = [tempInvoiceList sortedArrayUsingComparator: ^NSComparisonResult (AMInvoice *invoice1, AMInvoice *invoice2) {
            return [invoice1.woID compare:invoice2.woID];
        }];
    }
    else
    {
        sortedArray = [arrTemp sortedArrayUsingComparator: ^NSComparisonResult (AMInvoice *invoice1, AMInvoice *invoice2) {
            return [invoice1.woID compare:invoice2.woID];
        }];
    }

    BOOL hasFitlerInvoice = NO; //If don't have filter invoice, should not auto-populate the SHIP invoice - changed on 11/07/2014
	for (AMInvoice *aInvoice in sortedArray) {
		AMWorkOrder *aWork = [[AMLogicCore sharedInstance] getWorkOrderInfoByID:aInvoice.woID];

		if (!aWork) {
            [AMUtilities showAlertWithInfo:MyLocal(@"Can not get workorder info")];
			break;
		}

		NSMutableDictionary *dic0 = [NSMutableDictionary dictionary];
        
        if ([aInvoice.recordTypeName isEqualToLocalizedString:INVOICE_TYPE_FILTER]) {
            if (aInvoice.price) {
                [dic0 setObject:aInvoice.price forKey:KEY_OF_WORKORDER_TOTAL_PRICE];
            }
			[dic0 setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Invoice_WorkOrder_Filter_Name] forKey:KEY_OF_CELL_TYPE];
            hasFitlerInvoice = YES;
		}
		else if ([aInvoice.recordTypeName isEqualToLocalizedString:INVOICE_TYPE_LABORCHARGE]) {
            if (aInvoice.price) {
                [dic0 setObject:aInvoice.price forKey:KEY_OF_WORKORDER_TOTAL_PRICE];
            }
			[dic0 setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Invoice_WorkOrder_Work_Performed] forKey:KEY_OF_CELL_TYPE];
		}
        else if ([aInvoice.recordTypeName isEqualToLocalizedString:INVOICE_TYPE_INVOICECODE]) {
            //TODO:: Need add Invoice code
            continue;
		}
        else
        {
            continue;
        }

		if (aWork.woNumber) {
			[dic0 setObject:aWork.woNumber forKey:KEY_OF_WORKORDER_TITLE];
		}
        
        if (aWork.woID) {
            [dic0 setObject:aWork.woID forKey:KEY_OF_WORKORDER_ID];
        }
        
        if (aWork.actualTimeEnd) {
             NSTimeZone *aZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
              [dic0 setObject:[aWork.actualTimeEnd formattedDateWithFormat:@"yyyy.MM.dd HH:mm" timeZone:aZone] forKey:KEY_OF_WORKORDER_END_TIME];
        }
        else
        {
            NSTimeZone *aZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
            [dic0 setObject:[[NSDate date] formattedDateWithFormat:@"yyyy.MM.dd HH:mm" timeZone:aZone] forKey:KEY_OF_WORKORDER_END_TIME];
        }

		if (aInvoice.hoursWorked) {
			[dic0 setObject:aInvoice.hoursWorked forKey:KEY_OF_HOURS_WORKED];
		}
		if (aInvoice.hoursRate) {
			[dic0 setObject:aInvoice.hoursRate forKey:KEY_OF_HOURS_RATE];
		}

		[dic0 setObject:@"Preventative Maintenance" forKey:KEY_OF_MAINTENANCE_TYPE];    //TODO::

		if (aInvoice.maintenanceFee) {
			[dic0 setObject:aInvoice.maintenanceFee forKey:KEY_OF_MAINTENANCE_FEE];
		}
        
		if (aInvoice.filterName) {
			[dic0 setObject:aInvoice.filterName forKey:KEY_OF_FILTER_NAME];
		}
        else
        {
            [dic0 setObject:@"" forKey:KEY_OF_FILTER_NAME];
        }
        
		if (aInvoice.unitPrice) {
			[dic0 setObject:aInvoice.unitPrice forKey:KEY_OF_FILTER_PRICE];
		}
        else
        {
            [dic0 setObject:@0 forKey:KEY_OF_FILTER_PRICE];
        }
        
		if (aInvoice.quantity) {
			[dic0 setObject:aInvoice.quantity forKey:KEY_OF_FILTER_QUANTITY];
		}
        else
        {
            [dic0 setObject:@0 forKey:KEY_OF_FILTER_QUANTITY];
        }

		[self.arrInvoiceInfos addObject:dic0];

		fTotalPrice += [aInvoice.price floatValue];
	}
    
    //TODO::Enhancement140929
    if (hasFitlerInvoice && [self.workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_EXCHANGE])
    {
        AMDBCustomerPrice *existCustomerPrice = nil;
        
        for (AMDBCustomerPrice *customerPrice in arrCodePriceList) {
            
            if([[@"SHIP" lowercaseString] isEqualToString:[customerPrice.productName lowercaseString]])
            {
                existCustomerPrice = customerPrice;
                break;
            }
        }
        
        if (existCustomerPrice) {
            NSMutableDictionary *dicParts = [NSMutableDictionary dictionary];
            [dicParts setObject:existCustomerPrice forKey:KEY_OF_CUSTOMER_PRICE];
            [self.arrCodeItems addObject:dicParts];
            [arrCodePriceList removeObject:existCustomerPrice];
        }
    }
    
     self.arrInvoiceInfoGroups = [self groupedbyKey1:KEY_OF_TITLE key2:KEY_OF_DATE forList:self.arrInvoiceInfos];

	self.labelPrice.text = isHiddenMoney ? @"XXX" : [NSString stringWithFormat:@"%.2f", fTotalPrice];
    
	[self.mainTableView reloadData];
    
    [self refreshTotalPrice];//TODO::Enhancement140929
}

- (IBAction)clickContactBtn:(UIButton *)sender {
    
    [self.mainTableView endEditing:YES];
    
    if ([arrContacts count] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Contact List Empty")];
        return;
    }
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
    popView.tag = PopViewType_Select_Contact;
	popView.arrInfos = arrContacts;
    popView.isAddNew = YES;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
    
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (IBAction)clickMCCheckboxBtn:(UIButton *)sender {
    isMCEmailSelected = !isMCEmailSelected;
    self.imageSelected.hidden = !isMCEmailSelected;

    if (isMCEmailSelected) {
        AMUser *user = [[AMLogicCore sharedInstance] getSelfUserInfo];
        NSString *strEmail = user.marketCenterEmail;
        self.textFieldEmail.text = strEmail;
    }
    else
    {
        self.textFieldEmail.text = TEXT_OF_NULL;
    }
}

#pragma mark -

- (IBAction)clickSubmitBtn:(UIButton *)sender {
    
    if ([self.textFieldLastName.text length] == 0 || [self.textFieldLastName.text isEqualToString:TEXT_OF_NULL]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Last Name")];
        return;
    }
    
    if ([self.textFieldEmail.text length] == 0 || [self.textFieldEmail.text isEqualToString:TEXT_OF_NULL]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Email")];
        return;
    }
    
    if(([self.textFieldEmail.text length] != 0 && ![self.textFieldEmail.text isEqualToString:TEXT_OF_NULL]) && ![AMUtilities isValidEmailValueTyped:self.textFieldEmail.text])
    {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please enter a valid email address")];
        return;
    }
    
    NSString *strFileName = [self.workOrder.caseID length] == 0 ? TEXT_OF_DEFAULT_SIGNIMAGE_NAME : self.workOrder.caseID;
    
    if (![AMFileManage dataWithName:strFileName]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Signature")];
        return;
    }
    
	DLog(@"%@ | %@ | %@ | %@ | %@", self.labelContact.text, self.textFieldFirstName.text, self.textFieldLastName.text, self.textFieldTitle.text, self.textFieldContactInfo.text);

    //reset the sync timer to now
    //[AMSyncingManager sharedInstance].timeStamp = [NSDate date];
    //[AMDBManager sharedInstance].timeStamp = [NSDate date];
    

    [self performSelector:@selector(hideAlert) withObject:syncAlertview afterDelay:30];
    
    [syncAlertview show];

    [[AMSyncingManager sharedInstance] startSyncing:^(NSInteger type, NSError *error) {
        [self syncingCompletion:error];
    }];
    
    if (!aCase) {
        aCase = [[AMLogicCore sharedInstance] getCaseInfoByID:self.workOrder.caseID];
    }
    
	aCase.signFirstName = [self.textFieldFirstName.text isEqualToString:TEXT_OF_NULL] ? @"" : self.textFieldFirstName.text;
	aCase.signLastName = [self.textFieldLastName.text isEqualToString:TEXT_OF_NULL] ? @"" : self.textFieldLastName.text;
	aCase.signTitle = [self.textFieldTitle.text isEqualToString:TEXT_OF_NULL] ? @"" : self.textFieldTitle.text;
//	aCase.signContactInfo = [self.textFieldContactInfo.text isEqualToString:TEXT_OF_NULL] ? @"" : self.textFieldContactInfo.text;
    aCase.signContactEmail = [self.textFieldEmail.text isEqualToString:TEXT_OF_NULL] ? @"" : self.textFieldEmail.text;
    aCase.signContactPhone = [self.textFieldContactInfo.text isEqualToString:TEXT_OF_NULL] ? @"" : self.textFieldContactInfo.text;
    
    NSMutableArray *arrInvoiceItems = [NSMutableArray array];
    
    if (arrCodeItems && [arrCodeItems count] > 0) {
		for (NSMutableDictionary *dicCInfo in arrCodeItems) {
            AMDBCustomerPrice *customerPrice = [dicCInfo objectForKey:KEY_OF_CUSTOMER_PRICE];
          
            AMPoS *posInfo = [[AMLogicCore sharedInstance] getPoSInfoByID:self.workOrder.posID];
            
            AMInvoice *invoice = [[AMInvoice alloc] init];
            invoice.woID = self.workOrder.woID;
            invoice.posID = self.workOrder.posID;
            invoice.posName = posInfo.name;
            invoice.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_INVOICECODE forObject:RECORD_TYPE_OF_INVOICE];
            invoice.recordTypeName = INVOICE_TYPE_INVOICECODE;
//            invoice.unitPrice = customerPrice.price;
            invoice.price = customerPrice.price;
            invoice.invoiceCodeId = customerPrice.productID;
            invoice.invoiceCodeName = customerPrice.productName;
            invoice.maintenanceFee = customerPrice.price;
            invoice.quantity = @(1);
            
            if (customerPrice.price && [customerPrice.price intValue] != 0) {
                
                DLog(@"Add : self.workOrder.posID : %@ posInfo.name : %@",self.workOrder.posID,posInfo.name);
                DLog(@"Add : customerPrice.productID : %@ customerPrice.productName : %@",customerPrice.productID,customerPrice.productName);
                
                [arrInvoiceItems addObject:invoice];
            }
        }
	}

    // save case -> save invoice -> update case estimated price

	[[AMLogicCore sharedInstance] updateCase:aCase completionBlock:^(NSInteger type, NSError *error){
        
        [[AMLogicCore sharedInstance] saveInvoiceList:arrInvoiceItems completionBlock:^(NSInteger type, NSError *error){

            MAIN ( ^{
                if (error) {
                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                }
            });
        }];
        
        MAIN ( ^{
            if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
            }
        });
    }];

	[[AMLogicCore sharedInstance] saveSignatureData:[AMFileManage dataWithName:strFileName] byCaseID:self.workOrder.caseID completionBlock: ^(NSInteger type, NSError *error) {
	    MAIN ( ^{
            
            NSString *strFileName = [self.workOrder.caseID length] == 0 ? TEXT_OF_DEFAULT_SIGNIMAGE_NAME : self.workOrder.caseID;
            [AMFileManage removeDataWithName:strFileName];
            self.imageViewSignature.image = nil;
            
	        if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
                return ;
			}
	        else {
	            if (delegate && [delegate respondsToSelector:@selector(didClickInvoiceViewControllerNextBtn)]) {
	                [delegate didClickInvoiceViewControllerNextBtn];
				}
			}
		});
	}];
    
}

- (IBAction)clickSignatureBtn:(id)sender {
	NSString *strFileName = [self.workOrder.caseID length] == 0 ? TEXT_OF_DEFAULT_SIGNIMAGE_NAME : self.workOrder.caseID;

	NSDictionary *dicInfo = @{
		KEY_OF_TYPE:TYPE_OF_SIGNATURE,
		KEY_OF_INFO:strFileName
	};

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_CHECKOUTPANELVIEWCONTROLLER object:dicInfo];
}

- (void)clickInvoiceCodeBtn:(UIButton *)sender
{
     [self.mainTableView endEditing:YES];
    
    if (([arrCodePriceList count] == 0)) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Invoice Code List Empty")];
		return;
	}
    
    NSInteger iRow = sender.tag % 1000;
	NSInteger iSection = (sender.tag - iRow) / 1000;
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
    popView.tag = PopViewType_Select_InvoiceCode;
    
	DLog(@"sender.tag : %d", sender.tag);
    
	popView.aIndexPath = [NSIndexPath indexPathForRow:iRow inSection:iSection];
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
	for (AMDBCustomerPrice *customerPrice in arrCodePriceList) {
		NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
		[dicInfo setObject:customerPrice forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
		[dicInfo setObject:customerPrice.productName forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
		[arrInfos addObject:dicInfo];
	}
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)clickAddInvoiceCodeBtn:(UIButton *)sender
{
    if (([arrCodePriceList count] == 0)) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Invoice Code List Empty")];
		return;
	}
    
    NSMutableDictionary *dicParts = [NSMutableDictionary dictionary];
	[self.arrCodeItems addObject:dicParts];
	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:([self.arrInvoiceInfoGroups count] + 1)] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == [self.arrInvoiceInfoGroups count] + 1) {
        return  TRUE;
    }
    
    return FALSE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数
{
    if (indexPath.section == [self.arrInvoiceInfoGroups count] + 1) {
        return  UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (void) tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if(indexPath.section == [self.arrInvoiceInfoGroups count] + 1)
        {
            AMDBCustomerPrice *customerPrice = [[arrCodeItems objectAtIndex:indexPath.row] objectForKey:KEY_OF_CUSTOMER_PRICE];
            
            if (customerPrice) {
                [arrCodePriceList addObject:customerPrice];
            }
            
            [arrCodeItems removeObjectAtIndex:indexPath.row];
            
            MAIN(^{
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                [self refreshTotalPrice];
            });
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return nil;
    }
    else if (indexPath.section == [self.arrInvoiceInfoGroups count] + 1) {
        AMInvoiceCodeTableViewCell *cell = (AMInvoiceCodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMInvoiceCodeTableViewCell"];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceCodeTableViewCell" owner:[AMInvoiceCodeTableViewCell class] options:nil];
            cell = (AMInvoiceCodeTableViewCell *)[nib objectAtIndex:0];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        AMDBCustomerPrice *customerPrice = [[arrCodeItems objectAtIndex:indexPath.row] objectForKey:KEY_OF_CUSTOMER_PRICE];
        cell.textFieldInvoiceCode.text = [customerPrice.productName length] == 0 ? TEXT_OF_NULL : customerPrice.productName;
        cell.textFieldPrice.text = isHiddenMoney ? @"XXX" : (customerPrice.price ? [NSString stringWithFormat:@"%.2f",[customerPrice.price floatValue]] : TEXT_OF_NULL);
        
        if ([customerPrice.productName length] != 0) {
            cell.btnInvoiceCode.enabled = NO;
        }
        else
        {
            cell.btnInvoiceCode.enabled = YES;
            [cell.btnInvoiceCode addTarget:self action:@selector(clickInvoiceCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnInvoiceCode.tag =  (indexPath.section * 1000 + indexPath.row);
            cell.btnInvoiceCode.tag = indexPath.row;
        }
        
        return cell;
    }
    else
    {
        NSMutableDictionary *dicInfo = [[[self.arrInvoiceInfoGroups objectAtIndex:(indexPath.section - 1)] objectForKey:KEY_OF_DATE] objectAtIndex:indexPath.row];
        switch ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue]) {
            case AMCheckoutCellType_Invoice_Case:
            {
                AMInvoiceTitleTableViewCell *cell = (AMInvoiceTitleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMInvoiceTitleTableViewCell"];
                if (cell == nil) {
                    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceTitleTableViewCell" owner:[AMInvoiceTitleTableViewCell class] options:nil];
                    cell = (AMInvoiceTitleTableViewCell *)[nib objectAtIndex:0];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.labelCase.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_CASE] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_CASE]];
                cell.labelRequestedBy.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_REQUEST_BY] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_REQUEST_BY]];
                cell.labelCompletedBy.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_COMPLETED_BY] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_COMPLETED_BY]];
                cell.labelCaseDate.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_CASE_DATE] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_CASE_DATE]];
                
                return cell;
            }
                break;
                
            case AMCheckoutCellType_Invoice_WorkOrder_Work_Performed :
			{
				AMInvoiceRepairTableViewCell *cell = (AMInvoiceRepairTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMInvoiceRepairTableViewCell"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceRepairTableViewCell" owner:[AMInvoiceRepairTableViewCell class] options:nil];
					cell = (AMInvoiceRepairTableViewCell *)[nib objectAtIndex:0];
				}
                
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
				cell.labelTitle.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_WORKORDER_TITLE] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_WORKORDER_TITLE]];
				cell.labelTitlePrice.text =  isHiddenMoney ? @"XXX" : ([NSString stringWithFormat:@"%.2f", ([dicInfo objectForKey:KEY_OF_WORKORDER_TOTAL_PRICE] ? [[dicInfo objectForKey:KEY_OF_WORKORDER_TOTAL_PRICE] floatValue]:0.00)]);
                //                cell.labelTitlePrice.hidden = isHiddenMoney;
				cell.labelWorkPerformed.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_WORK_PERFORMED] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_WORK_PERFORMED]];
				cell.labelHoursWorked.text = [NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_HOURS_WORKED] ? [dicInfo objectForKey:KEY_OF_HOURS_WORKED]:@""];
				cell.labelHoursRate.text = isHiddenMoney ? @"XXX" :([NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_HOURS_RATE] ? [dicInfo objectForKey:KEY_OF_HOURS_RATE]:@""]);
				cell.labelMaintenanceType.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_MAINTENANCE_TYPE] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_MAINTENANCE_TYPE]];
				cell.labelMaintenanceFee.text = [NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_MAINTENANCE_FEE] ? [dicInfo objectForKey:KEY_OF_MAINTENANCE_FEE]:@""];
                
				return cell;
			}
                break;
                
            case AMCheckoutCellType_Invoice_WorkOrder_Filter_Name :
			{
				AMInvoiceRepairFilterNameCell *cell = (AMInvoiceRepairFilterNameCell *)[tableView dequeueReusableCellWithIdentifier:@"AMInvoiceRepairFilterNameCell"];
				if (cell == nil) {
					NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceRepairFilterNameCell" owner:[AMInvoiceRepairFilterNameCell class] options:nil];
					cell = (AMInvoiceRepairFilterNameCell *)[nib objectAtIndex:0];
				}
                
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
				cell.labelTitle.text = [NSString stringWithFormat:@"%@", [[dicInfo objectForKey:KEY_OF_WORKORDER_TITLE] length] == 0 ? @"":[dicInfo objectForKey:KEY_OF_WORKORDER_TITLE]];
				cell.labelTitlePrice.text =  isHiddenMoney ? @"XXX" : ([NSString stringWithFormat:@"%.2f", ([dicInfo objectForKey:KEY_OF_WORKORDER_TOTAL_PRICE] ? [[dicInfo objectForKey:KEY_OF_WORKORDER_TOTAL_PRICE] floatValue]:0.00)]);
                //                cell.labelTitlePrice.hidden = isHiddenMoney;
                
				cell.labelFilterName.text = [NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_FILTER_NAME]];
				cell.labelFilterPrice.text = isHiddenMoney ? @"XXX" : [NSString stringWithFormat:@"%.2f", [[dicInfo objectForKey:KEY_OF_FILTER_PRICE] floatValue]];
                
				cell.labelFilterQuantity.text = [NSString stringWithFormat:@"%@", [dicInfo objectForKey:KEY_OF_FILTER_QUANTITY] ? [dicInfo objectForKey:KEY_OF_FILTER_QUANTITY]:@""];
                
				return cell;
			}
                break;
                
            case AMCheckoutCellType_Invoice_WorkOrder_MaintenceFee :
            {
            }
                break;
        }

    }

	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 0;
    }
    else if (section == [self.arrInvoiceInfoGroups count] + 1) {
         return [self.arrCodeItems count];
    }
    else
    {
        return [[[self.arrInvoiceInfoGroups objectAtIndex:(section - 1)] objectForKey:KEY_OF_DATE] count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 0;
    }
    else if(indexPath.section == [self.arrInvoiceInfoGroups count] + 1)
    {
        return 48.0;
    }
    else
    {
        NSMutableDictionary *dicInfo = [self.arrInvoiceInfos objectAtIndex:indexPath.row];
        
        switch ([[dicInfo objectForKey:KEY_OF_CELL_TYPE] intValue]) {
            case AMCheckoutCellType_Invoice_Case :
            {
                return 50.0;
            }
                break;
                
            case AMCheckoutCellType_Invoice_WorkOrder_MaintenceFee:
            {
                return 101.0;
            }
                break;
                
            case AMCheckoutCellType_Invoice_WorkOrder_Work_Performed :
            {
                return 48.0;
            }
                break;
                
            case AMCheckoutCellType_Invoice_WorkOrder_Filter_Name :
            {
                return 48.0;
            }
                break;
        }
    }
    
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return CGRectGetHeight(invoiceCaseSectionView.frame);
    }
	else if(section == [self.arrInvoiceInfoGroups count] + 1)
    {
        return CGRectGetHeight(invoiceSectionView.frame);
    }
    else
    {
        return 55.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        
        invoiceCaseSectionView.labelTCase.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Case #")];
        invoiceCaseSectionView.labelTRequestBy.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Requested By")];
        invoiceCaseSectionView.labelTCreatedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Created Date")];
        invoiceCaseSectionView.labelTClosedDate.text = [NSString stringWithFormat:@"%@:",MyLocal(@"Closed Date")];
        
        return invoiceCaseSectionView;
    }
	else if(section == [self.arrInvoiceInfoGroups count] + 1)
    {
        return invoiceSectionView;
    }
    else
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceWorkorderTitleView" owner:[AMInvoiceWorkorderTitleView class] options:nil];
		AMInvoiceWorkorderTitleView *aVerificationTitle = (AMInvoiceWorkorderTitleView *)[nib objectAtIndex:0];
        
         aVerificationTitle.labelTPrice.text = [NSString stringWithFormat:@"%@:",MyLocal(@"PRICE")];
        
        NSArray *arrItems = [[self.arrInvoiceInfoGroups objectAtIndex:(section - 1)] objectForKey:KEY_OF_DATE] ;
        CGFloat fTotalPrice = 0.0;
        for (NSMutableDictionary *dic0 in arrItems) {
            fTotalPrice += ([[dic0 objectForKey:KEY_OF_FILTER_PRICE] floatValue] * [[dic0 objectForKey:KEY_OF_FILTER_QUANTITY] floatValue]);
        }
        
        if ([[[arrItems firstObject] objectForKey:KEY_OF_WORKORDER_END_TIME] length] == 0) {
            aVerificationTitle.labelTitle.text = [[arrItems firstObject] objectForKey:KEY_OF_WORKORDER_TITLE];
        }
        else
        {
            aVerificationTitle.labelTitle.text = [NSString stringWithFormat:@"%@ [ %@: %@ ]",[[arrItems firstObject] objectForKey:KEY_OF_WORKORDER_TITLE],MyLocal(@"Check Out Time"),[[arrItems firstObject] objectForKey:KEY_OF_WORKORDER_END_TIME]];
        }
        aVerificationTitle.labelPrice.text =  isHiddenMoney ? @"XXX" : [NSString stringWithFormat:@"%.2f", fTotalPrice];
        
		if (![self.arrSections containsObject:aVerificationTitle]) {
			[self.arrSections addObject:aVerificationTitle];
		}
        
        aVerificationTitle.labelTPrice.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:20.0];
        aVerificationTitle.labelPrice.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:25.0];
        aVerificationTitle.labelTitle.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:15.0];
        
		return aVerificationTitle;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.arrInvoiceInfoGroups count] + 2;
}

#pragma mark -

#pragma mark -

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([textField.text isEqualToString:TEXT_OF_NULL]) {
		textField.text = @"";
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([AMUtilities isEmpty:textField.text]) {
		textField.text = TEXT_OF_NULL;
	}

	switch (textField.tag) {
		case InvoiceTextInputType_FirstName :
			{
				DLog(@"InvoiceTextInputType_FirstName");
			}
			break;

		case InvoiceTextInputType_LastName :
			{
				DLog(@"InvoiceTextInputType_LastName");
			}
			break;

		case InvoiceTextInputType_Title :
			{
				DLog(@"InvoiceTextInputType_Title");
			}
			break;

		case InvoiceTextInputType_ContactInfo :
			{
				DLog(@"InvoiceTextInputType_ContactInfo");
			}
			break;
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.view endEditing:YES];
	return YES;
}
#pragma mark - Delegate for dismissAMAddNewContactViewController
- (void)dismissAMAddNewContactViewController:(AMAddNewContactViewController *)vc dictContactInfo:(NSMutableDictionary *)dictContactInfo {
    [self.activityView stopAnimating];
    [self.btnSubmit setEnabled:YES];
    
    NSLog(@"dictContactInfo = %@", dictContactInfo);
    self.textFieldFirstName.text = [dictContactInfo objectForKey:@"KEY_OF_CONTACT_FIRST_NAME"] != nil ? [[dictContactInfo objectForKey:@"KEY_OF_CONTACT_FIRST_NAME"] capitalizedString] : @"";
    self.textFieldLastName.text = [dictContactInfo objectForKey:@"KEY_OF_CONTACT_LAST_NAME"] != nil ? [[dictContactInfo objectForKey:@"KEY_OF_CONTACT_LAST_NAME"] capitalizedString] : @"";
    
    NSString *wholeName = [NSString stringWithFormat:@"%@ %@", self.textFieldFirstName.text, self.textFieldLastName.text];
    self.labelContact.text = [wholeName capitalizedString];
    
    self.textFieldEmail.text = [dictContactInfo objectForKey:@"KEY_OF_CONTACT_EMAIL"] != nil ? [dictContactInfo objectForKey:@"KEY_OF_CONTACT_EMAIL"] : @"";
    self.textFieldContactInfo.text = [dictContactInfo objectForKey:@"KEY_OF_CONTACT_PHONE"] != nil ? [dictContactInfo objectForKey:@"KEY_OF_CONTACT_PHONE"] : @"";
    self.textFieldTitle.text = [[dictContactInfo objectForKey:@"KEY_OF_CONTACT_TITLE"] capitalizedString] != nil ? [dictContactInfo objectForKey:@"KEY_OF_CONTACT_TITLE"] : @"";
}

#pragma mark -
- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
    if (aVerificationStatusTableViewController.tag == PopViewType_Select_InvoiceCode) {
        
//        AMDBCustomerPrice *customerPrice0 = [[arrCodeItems objectAtIndex:aVerificationStatusTableViewController.aIndexPath.row] objectForKey:KEY_OF_CUSTOMER_PRICE];
//        
//        if (customerPrice0.price) {
//            [arrCodePriceList addObject:customerPrice0];
//        }
        
        AMDBCustomerPrice *customerPrice = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        [[arrCodeItems objectAtIndex:aVerificationStatusTableViewController.aIndexPath.row] setObject:customerPrice forKey:KEY_OF_CUSTOMER_PRICE];
        
        [arrCodePriceList removeObject:customerPrice];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
		[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:([self.arrInvoiceInfoGroups count] + 1)] withRowAnimation:UITableViewRowAnimationNone];
        
        [self refreshTotalPrice];
    }
    else if(aVerificationStatusTableViewController.tag == PopViewType_Select_Contact){
        DLog(@" didSelected : %@", aInfo);
        
        if ([[aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO] isEqualToString:@"ADD NEW"]) {
            //user is adding new contact.
            [aPopoverVC dismissPopoverAnimated:YES];
            
            AMAddNewContactViewController *ancVC = [[AMAddNewContactViewController alloc] initWithNibName:@"AMAddNewContactViewController" bundle:nil];
            ancVC.isPop = YES;
            ancVC.selectedWorkOrder = self.workOrder;
            ancVC.delegate = self;
            ancVC.modalPresentationStyle = UIModalPresentationPageSheet;

            [self.activityView startAnimating];
            [self.btnSubmit setEnabled:NO];

            [self presentViewController:ancVC animated:YES completion:nil];
            
        } else {
            
            AMContact *aContact = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
            aCase.signContactID = aContact.contactID;
            self.labelContact.text = aContact.name;
            self.textFieldFirstName.text = aContact.firstName;
            self.textFieldLastName.text = aContact.lastName;

    //        if ([aContact.email length] != 0)
    //        {
                self.textFieldEmail.text = aContact.email;
    //        }
    //        else if([aContact.phone length] != 0)
    //        {
                 self.textFieldContactInfo.text = aContact.phone;
    //        }
    //        else
    //        {
    //            self.textFieldContactInfo.text = @"";
    //        }
            
            self.textFieldTitle.text = aContact.title;
            [aPopoverVC dismissPopoverAnimated:YES];
        }
        
    }
}

- (void)refreshTotalPrice {
    
    CGFloat fTotalPrice = 0.0;
    
	for (NSMutableDictionary *dic0 in arrInvoiceInfos) {
            fTotalPrice += ([[dic0 objectForKey:KEY_OF_FILTER_PRICE] floatValue] * [[dic0 objectForKey:KEY_OF_FILTER_QUANTITY] floatValue]);
    }
    
    for (NSMutableDictionary *dicParts in arrCodeItems) {
        AMDBCustomerPrice *customerPrice = [dicParts objectForKey:KEY_OF_CUSTOMER_PRICE];
        fTotalPrice += [customerPrice.price floatValue];
    }
    
	self.labelPrice.text =  isHiddenMoney ? @"XXX" : [NSString stringWithFormat:@"%.2f", fTotalPrice];

}

- (NSArray *)groupedbyKey1:(NSString *)aKey1
                      key2:(NSString *)aKey2
                   forList:(NSMutableArray *)array
{
    NSMutableArray *arrResult = [NSMutableArray array];
    
    for (NSMutableDictionary *aInfo in array) {
        BOOL isExist = NO;
        for (NSMutableDictionary *dicInfo in arrResult) {
            if ([[dicInfo objectForKey:aKey1] isEqualToLocalizedString:[aInfo objectForKey:KEY_OF_WORKORDER_TITLE]]) {
                NSMutableArray *arrItems = [dicInfo objectForKey:aKey2];
                [arrItems addObject:aInfo];
                isExist = YES;
                break;
            }
        }
        
        if (!isExist) {
            NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
            [dicInfo setObject:[aInfo objectForKey:KEY_OF_WORKORDER_TITLE] forKey:aKey1];
            [dicInfo setObject:[aInfo objectForKey:KEY_OF_WORKORDER_END_TIME] forKey:@"KEY_OF_END_TIME"];
            NSMutableArray *arrItems = [NSMutableArray array];
            [arrItems addObject:aInfo];
            [dicInfo setObject:arrItems forKey:aKey2];
            [arrResult addObject:dicInfo];
        }
    }
    
    NSArray *sortedArray = [arrResult sortedArrayUsingComparator: ^NSComparisonResult (NSMutableDictionary *picture1, NSMutableDictionary *picture2) {
        return [[picture1 objectForKey:@"KEY_OF_END_TIME" ] compare:[picture2 objectForKey:@"KEY_OF_END_TIME" ]];
    }];
    
    return sortedArray;
}

#pragma mark -Sync Completion
- (void)syncingCompletion:(NSError *)error
{
    [syncAlertview dismissWithClickedButtonIndex:0 animated:YES];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
            
            [userInfo setObject:TYPE_OF_SHOW_ALERT forKey:KEY_OF_TYPE];
            if (error.localizedDescription) {
                [userInfo setObject:error.localizedDescription forKey:KEY_OF_INFO];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SYNCING_DONE object:nil];
    });
}

- (void)hideAlert {
    if (syncAlertview.visible) {
        [syncAlertview dismissWithClickedButtonIndex:0 animated:YES];
    }
}
@end
