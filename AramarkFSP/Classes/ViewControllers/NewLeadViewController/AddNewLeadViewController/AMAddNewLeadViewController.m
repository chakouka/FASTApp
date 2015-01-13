//
//  AMAddNewLeadViewController.m
//  AramarkFSP
//
//  Created by PwC on 6/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAddNewLeadViewController.h"
#import "AMNormalTitleSection.h"
#import "AMNewLeadFirtNameCell.h"
#import "AMNewLeadStreetCell.h"
#import "AMNewLeadSelectCell.h"
#import "AMPopoverSelectTableViewController.h"
#import "AMDBNewLead.h"

typedef NS_ENUM(NSInteger, LeadSection) {
    LeadSection_NewLeads = 0,
    LeadSection_AddressInfo,
    LeadSection_CurrentProduct,
    LeadSection_Satisfication,
};

typedef NS_ENUM(NSInteger, AddNewLeadTextInputType) {
    AddNewLeadTextInputType_FirstName_PR = 0,
    AddNewLeadTextInputType_FirstName,
    AddNewLeadTextInputType_LastName,
    AddNewLeadTextInputType_CompanyName,
    AddNewLeadTextInputType_CompanySize,
    AddNewLeadTextInputType_Title,
    AddNewLeadTextInputType_CurrentProvider,
    AddNewLeadTextInputType_EmailAddress,
    AddNewLeadTextInputType_ReferingEmployee,
    AddNewLeadTextInputType_PhoneNumber,
    
    AddNewLeadTextInputType_Street,
    AddNewLeadTextInputType_ZipCode,
    AddNewLeadTextInputType_City,
    AddNewLeadTextInputType_Street2,
    AddNewLeadTextInputType_Country,
    AddNewLeadTextInputType_SateProvince,
    AddNewLeadTextInputType_Comments,
};

typedef NS_ENUM (NSInteger, PopViewType) {
    PopViewType_NewLead_FirstName = 2000,
    PopViewType_NewLead_Country,
    PopViewType_NewLead_State,
    PopViewType_NewLead_CompanySize,
};


@interface AMAddNewLeadViewController ()
<
UITextFieldDelegate,
UITextViewDelegate,
AMPopoverSelectTableViewControllerDelegate,
UIPopoverControllerDelegate
>
{
    NSMutableDictionary *dicLeadInfo;
    NSMutableArray *arrProducts;
    NSMutableArray *arrSatisficationLevels;
    UIPopoverController *aPopoverVC;
}

@property (strong, nonatomic) NSMutableDictionary *dicLeadInfo;
@property (strong, nonatomic) NSMutableArray *arrProducts;
@property (strong, nonatomic) NSMutableArray *arrSatisficationLevels;
@property (nonatomic, strong) UIPopoverController *aPopoverVC;

@end

@implementation AMAddNewLeadViewController
@synthesize dicLeadInfo;
@synthesize arrProducts;
@synthesize aPopoverVC;
@synthesize arrSatisficationLevels;
@synthesize delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dicLeadInfo = [NSMutableDictionary dictionary];
        arrProducts = [NSMutableArray array];
        arrSatisficationLevels = [NSMutableArray array];
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
    
    MyButtonTitle(self.btnSave, MyLocal(@"SAVE"));
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)refreshWithInfo:(NSMutableDictionary *)aInfo
{
    if (arrProducts && [arrProducts count] > 0) {
        [arrProducts removeAllObjects];
    }
    
    if (arrSatisficationLevels && [arrSatisficationLevels count] > 0) {
        [arrSatisficationLevels removeAllObjects];
    }
    
    [self.dicLeadInfo setObject:TEXT_OF_NONE forKey:KEY_OF_LEAD_FIRSTNAME_PR];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_FIRSTNAME];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_LASTNAME];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_COMPANYNAME];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_COMPANYSIZE];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_TITLE];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_CURRENTPROVIDER];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_EMAILADDRESS];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_REFERINGEMPLOYEE];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_PHONENUMBER];
    
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_STREET];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_ZIPCODE];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_CITY];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_STATE];
    [self.dicLeadInfo setObject:@"US" forKey:KEY_OF_LEAD_COUNTRY];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_STATEPROVINCE];
    [self.dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_COMMENTS];
    
    [self.arrProducts addObject:[self dicWithTitle:@"Coffee"]];
    [self.arrProducts addObject:[self dicWithTitle:@"Water"]];
    [self.arrProducts addObject:[self dicWithTitle:@"Ice"]];
    [self.arrProducts addObject:[self dicWithTitle:@"Private Label"]];
    [self.arrProducts addObject:[self dicWithTitle:@"Single Cup"]];
    
    [self.arrSatisficationLevels addObject:[self dicWithTitle:@"Not Satisfied"]];
    [self.arrSatisficationLevels addObject:[self dicWithTitle:@"Somewhat Satisfied"]];
    [self.arrSatisficationLevels addObject:[self dicWithTitle:@"Ok"]];
    [self.arrSatisficationLevels addObject:[self dicWithTitle:@"Satisfied"]];
    [self.arrSatisficationLevels addObject:[self dicWithTitle:@"Very Satisfied"]];
    
    [self.tableViewMain reloadData];
}

- (NSMutableDictionary *)dicWithTitle:(NSString *)aTitle
{
    NSMutableDictionary *dicItem = [NSMutableDictionary dictionary];
    [dicItem setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_LEAD_CHECK_STATUS];
    [dicItem setObject:MyLocal(aTitle) forKey:KEY_OF_LEAD_CHECK_TITLE];
    return dicItem;
}

#pragma mark -

- (IBAction)clickSaveBtn:(id)sender {
    DLog(@"%@",self.dicLeadInfo);
    DLog(@"%@",self.arrProducts);
    DLog(@"%@",self.arrSatisficationLevels);
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_EMAILADDRESS] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Email")];
        return;
    }
    else if(![AMUtilities isValidEmailValueTyped:[self.dicLeadInfo objectForKey:KEY_OF_LEAD_EMAILADDRESS]])
    {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please enter a valid email address")];
        return;
    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input First Name")];
        return;
    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_LASTNAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Last Name")];
        return;
    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYNAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Company Name")];
        return;
    }
    
//    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYSIZE] length] == 0) {
//        [AMUtilities showAlertWithInfo:@"Please Choose Company Size"];
//        return;
//    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_TITLE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Lead Position/ Title")];
        return;
    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_REFERINGEMPLOYEE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Refering Employee")];
        return;
    }
    
    if ([[dicLeadInfo objectForKey:KEY_OF_LEAD_PHONENUMBER] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Phone Number")];
        return ;
    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_STREET] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Address")];
        return;
    }
    
//    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_STATE] length] == 0) {
//        [AMUtilities showAlertWithInfo:@"Please Choose Street2"];
//        return;
//    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_CITY] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input City")];
        return;
    }
    
    if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_STATEPROVINCE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input State")];
        return;
    }
    
    if ([AMUtilities isEmpty:[self.dicLeadInfo objectForKey:KEY_OF_LEAD_ZIPCODE]]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Valid zip code")];
        return;
    }
    
    [[AMLogicCore sharedInstance] createNewLeadInDBWithSetupBlock:^(AMDBNewLead *newLead) {
        newLead.street2 = [dicLeadInfo objectForKey:KEY_OF_LEAD_STATE];
        newLead.zipCode = [dicLeadInfo objectForKey:KEY_OF_LEAD_ZIPCODE];
        newLead.title = [dicLeadInfo objectForKey:KEY_OF_LEAD_TITLE];
        newLead.emailAddress = [dicLeadInfo objectForKey:KEY_OF_LEAD_EMAILADDRESS];
        newLead.phoneNumber = [dicLeadInfo objectForKey:KEY_OF_LEAD_PHONENUMBER];
        newLead.companyName = [dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYNAME];
        newLead.companySize = [dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYSIZE];
        newLead.currentProvider = [dicLeadInfo objectForKey:KEY_OF_LEAD_CURRENTPROVIDER];
        newLead.referingEmployee = [dicLeadInfo objectForKey:KEY_OF_LEAD_REFERINGEMPLOYEE];
        newLead.street = [dicLeadInfo objectForKey:KEY_OF_LEAD_STREET];
        newLead.stateProvince = [dicLeadInfo objectForKey:KEY_OF_LEAD_STATEPROVINCE];
        newLead.firstName = [dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME];
        newLead.lastName = [dicLeadInfo objectForKey:KEY_OF_LEAD_LASTNAME];
        newLead.city = [dicLeadInfo objectForKey:KEY_OF_LEAD_CITY];
        newLead.country = [dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY];
        newLead.comments = [dicLeadInfo objectForKey:KEY_OF_LEAD_COMMENTS];
        newLead.salutation = [dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME_PR];
        
        newLead.hasCoffee = [[arrProducts objectAtIndex:0] objectForKey:KEY_OF_LEAD_CHECK_STATUS];
        newLead.hasWater = [[arrProducts objectAtIndex:1] objectForKey:KEY_OF_LEAD_CHECK_STATUS];
        newLead.hasIce = [[arrProducts objectAtIndex:2] objectForKey:KEY_OF_LEAD_CHECK_STATUS];
        newLead.hasPrivateLabel = [[arrProducts objectAtIndex:3] objectForKey:KEY_OF_LEAD_CHECK_STATUS];
        newLead.hasSingleCup = [[arrProducts objectAtIndex:4] objectForKey:KEY_OF_LEAD_CHECK_STATUS];
        
        NSString *strSatis = nil;
        
        for (NSMutableDictionary *dicInfo in self.arrSatisficationLevels) {
            if ([[dicInfo objectForKey:KEY_OF_LEAD_CHECK_STATUS] boolValue]) {
                strSatis = [dicInfo objectForKey:KEY_OF_LEAD_CHECK_TITLE];
                break;
            }
        }
        
        newLead.satisfactionLevel = strSatis;
        
    } completion:^(NSInteger type, NSError *error) {
        MAIN(^{
            if (error) {
                [AMUtilities showAlertWithInfo:[error localizedDescription]];
                return ;
            }
            else
            {
                [UIAlertView showWithTitle:@""
                                   message:MyLocal(@"New Lead is created successfully but not synced")
                         cancelButtonTitle:MyLocal(@"OK")
                         otherButtonTitles:nil
                                  tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                      if (buttonIndex == [alertView cancelButtonIndex]) {
                                          if (self.delegate && [self.delegate respondsToSelector:@selector(didClickSaveNewLead:)]) {
                                              [self.delegate didClickSaveNewLead:YES];
                                          }
                                      }
                                  }];
            }
        });
    }];
}

- (void)clickProductCheck:(UIButton *)sender {
    NSMutableDictionary *dicInfos = [self.arrProducts objectAtIndex:sender.tag];

    sender.selected = !sender.selected;
    [dicInfos setObject:[NSNumber numberWithBool:sender.selected] forKey:KEY_OF_LEAD_CHECK_STATUS];
    
    [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:LeadSection_CurrentProduct] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickSatisficationCheck:(UIButton *)sender {
    
    for (NSMutableDictionary *dicInfo in self.arrSatisficationLevels) {
         [dicInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_LEAD_CHECK_STATUS];
    }
    
    NSMutableDictionary *dicInfos = [self.arrSatisficationLevels objectAtIndex:sender.tag];
    
    sender.selected = !sender.selected;
    [dicInfos setObject:[NSNumber numberWithBool:sender.selected] forKey:KEY_OF_LEAD_CHECK_STATUS];
    
    [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:LeadSection_Satisfication] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickFirstNamePrefix:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewLead_FirstName;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"None") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"None"}];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Mr.") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Mr."}];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Ms.") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Ms." }];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Mrs.") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Mrs." }];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Dr.") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Dr." }];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Prof.") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Prof." }];

	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)clickCompanySize:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewLead_CompanySize;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Under 30") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Under 30") }];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"30-100") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"30-100") }];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Greater than 100") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Greater than 100") }];
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

-(void)clickContryBtn:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewLead_Country;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"US" }];
    [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Canada" }];
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

-(void)clickStateBtn:(UIButton *)sender
{
    [self.tableViewMain endEditing:YES];
    
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_NewLead_State;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
    if ([[dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY] isEqualToLocalizedString:@"US"]) {
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Alabama" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Alaska" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Arizona" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Arkansas" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"California" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Colorado" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Connecticut" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Delaware" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Florida" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Georgia " }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Hawaii" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Idaho" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Illinois" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Indiana" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Iowa" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Kansas" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Kentucky" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Louisiana" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Maine" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Maryland" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Massachusetts" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Michigan" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Minnesota" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Mississippi" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Missouri" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Montana" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Nebraska" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Nevada" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"New Hampshire" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"New Jersey" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"New Mexico" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"New York" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"North Carolina" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"North Dakota" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Ohio" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Oklahoma" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Oregon" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Pennsylvania" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Rhode Island" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"South Carolina" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"South Dakota" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Tennessee" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Texas" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Utah" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Vermont" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Virginia" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Washington" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"West Virginia" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Wisconsin" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Wyoming" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"American Samoa" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"District of Columbia" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Guam" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Northern Mariana Islands" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Puerto Rico" }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : @"Virgin Islands" }];
    }
    else if([[dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY] isEqualToLocalizedString:@"Canada"])
    {
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Ontario") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Quebec") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"British Columbia") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Alberta") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Manitoba") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Saskatchewan") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Nova Scotia") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"New Brunswick") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Newfoundland and Labrador") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Prince Edward Island") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Northwest Territories") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Yukon") }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Nunavut") }];
    }
    else
    {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Choose Country First")];
        return ;
    }
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    switch (indexPath.section) {
        case LeadSection_NewLeads:
        {
            AMNewLeadFirtNameCell *cell = (AMNewLeadFirtNameCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNewLeadFirtNameCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNewLeadFirtNameCell" owner:[AMNewLeadFirtNameCell class] options:nil];
                cell = (AMNewLeadFirtNameCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
            cell.labelFIrstName.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_FirstName_PR);
            cell.labelFIrstName.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME_PR] length] == 0 ? MyLocal(TEXT_OF_NONE) : MyLocal([self.dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME_PR]);
            
            cell.textFieldFirstName.delegate = self;
            cell.textFieldFirstName.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_FirstName);
            cell.textFieldFirstName.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_FIRSTNAME];
            
            cell.textFieldLastName.delegate = self;
            cell.textFieldLastName.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_LastName);
            cell.textFieldLastName.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_LASTNAME] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_LASTNAME];
            
            cell.textFieldCompanyName.delegate = self;
            cell.textFieldCompanyName.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_CompanyName);
            cell.textFieldCompanyName.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYNAME] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYNAME];
            
            cell.textFieldCompanySize.delegate = self;
            cell.textFieldCompanySize.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_CompanySize);
            cell.textFieldCompanySize.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYSIZE] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMPANYSIZE];
            
            cell.textFieldTitle.delegate = self;
            cell.textFieldTitle.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_Title);
            cell.textFieldTitle.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_TITLE] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_TITLE];
            
            cell.textFieldCurrentProvider.delegate = self;
            cell.textFieldCurrentProvider.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_CurrentProvider);
            cell.textFieldCurrentProvider.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_CURRENTPROVIDER] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_CURRENTPROVIDER];
            
            cell.textFieldEmailAddress.delegate = self;
            cell.textFieldEmailAddress.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_EmailAddress);
            cell.textFieldEmailAddress.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_EMAILADDRESS] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_EMAILADDRESS];
            
            cell.textFieldReferingEmployee.delegate = self;
            cell.textFieldReferingEmployee.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_ReferingEmployee);
            cell.textFieldReferingEmployee.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_REFERINGEMPLOYEE] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_REFERINGEMPLOYEE];
            
            cell.textFieldPhoneNumber.delegate = self;
            cell.textFieldPhoneNumber.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_PhoneNumber);
            cell.textFieldPhoneNumber.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_PHONENUMBER] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_PHONENUMBER];
            
            [cell.btnFirstName addTarget:self action:@selector(clickFirstNamePrefix:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btnCompanySize addTarget:self action:@selector(clickCompanySize:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
            break;
        case LeadSection_AddressInfo:
        {
            AMNewLeadStreetCell *cell = (AMNewLeadStreetCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNewLeadStreetCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNewLeadStreetCell" owner:[AMNewLeadStreetCell class] options:nil];
                cell = (AMNewLeadStreetCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textFieldStreet.delegate = self;
            cell.textFieldStreet.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_Street);
            cell.textFieldStreet.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_STREET] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_STREET];
            
            cell.textFieldZipCode.delegate = self;
            cell.textFieldZipCode.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_ZipCode);
            cell.textFieldZipCode.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_ZIPCODE] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_ZIPCODE];
            
            cell.textFieldCity.delegate = self;
            cell.textFieldCity.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_City);
            cell.textFieldCity.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_CITY] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_CITY];
            
            cell.textFieldState.delegate = self;
            cell.textFieldState.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_Street2);
            cell.textFieldState.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_STATE] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_STATE];
            
            cell.textFieldCountry.delegate = self;
            cell.textFieldCountry.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_Country);
            cell.textFieldCountry.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY];
            
            cell.textFieldStateProvince.delegate = self;
            cell.textFieldStateProvince.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_SateProvince);
            cell.textFieldStateProvince.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_STATEPROVINCE] length] == 0 ? TEXT_OF_NULL : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_STATEPROVINCE];
            
            cell.textViewComments.delegate = self;
            cell.textViewComments.tag = (indexPath.section * 1000 + AddNewLeadTextInputType_Comments);
            cell.textViewComments.text = [[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMMENTS] length] == 0 ? MyLocal(@"Write Comments") : [self.dicLeadInfo objectForKey:KEY_OF_LEAD_COMMENTS];
            
            if ([[self.dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY] isEqualToLocalizedString:@"Canada"]) {
                cell.labelTState.text = MyLocal(@"Province");
            }
            else
            {
                cell.labelTState.text = MyLocal(@"State");
            }
            
            [cell.btnCountry addTarget:self action:@selector(clickContryBtn:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnState addTarget:self action:@selector(clickStateBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
            break;
        case LeadSection_CurrentProduct:
        {
            AMNewLeadSelectCell *cell = (AMNewLeadSelectCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNewLeadSelectCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNewLeadSelectCell" owner:[AMNewLeadSelectCell class] options:nil];
                cell = (AMNewLeadSelectCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSMutableDictionary *dicInfo = [self.arrProducts objectAtIndex:indexPath.row];
            cell.labelTitle.text = [dicInfo objectForKey:KEY_OF_LEAD_CHECK_TITLE];
            cell.btnCheck.tag = indexPath.row;
            [cell.btnCheck addTarget:self action:@selector(clickProductCheck:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnCheck.selected = [[dicInfo objectForKey:KEY_OF_LEAD_CHECK_STATUS] boolValue];
            
            return cell;
        }
            break;
        case LeadSection_Satisfication:
        {
            AMNewLeadSelectCell *cell = (AMNewLeadSelectCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNewLeadSelectCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNewLeadSelectCell" owner:[AMNewLeadSelectCell class] options:nil];
                cell = (AMNewLeadSelectCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSMutableDictionary *dicInfo = [self.arrSatisficationLevels objectAtIndex:indexPath.row];
            cell.labelTitle.text = [dicInfo objectForKey:KEY_OF_LEAD_CHECK_TITLE];
            cell.btnCheck.tag = indexPath.row;
            [cell.btnCheck addTarget:self action:@selector(clickSatisficationCheck:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnCheck.selected = [[dicInfo objectForKey:KEY_OF_LEAD_CHECK_STATUS] boolValue];
            
            return cell;
        }
            break;
        default:
            break;
    }

    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
        case LeadSection_CurrentProduct:
        {
            return [self.arrProducts count];
        }
            break;
        case LeadSection_Satisfication:
        {
            return [self.arrSatisficationLevels count];
        }
            break;
        default:
        {
            return 1;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case LeadSection_NewLeads:
        {
            return 214.0;
        }
            break;
        case LeadSection_AddressInfo:
        {
            return 290.0;
        }
            break;
        default:
        {
            return 44.0;
        }
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *strTitle = @"";
    
    switch (section) {
        case LeadSection_NewLeads:
        {
            strTitle = @"New Leads";
        }
            break;
        case LeadSection_AddressInfo:
        {
            strTitle = @"Address Info";
        }
            break;
        case LeadSection_CurrentProduct:
        {
            strTitle = @"Current Product";
        }
            break;
        case LeadSection_Satisfication:
        {
            strTitle = @"Satisfication Level with Current Provider";
        }
            break;
        default:
            break;
    }
    
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNormalTitleSection" owner:[AMNormalTitleSection class] options:nil];
    AMNormalTitleSection *aView = (AMNormalTitleSection *)[nib objectAtIndex:0];
    aView.labelTitle.text = MyLocal(strTitle);
	return aView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0;
}

#pragma mark -

- (void)textViewDidBeginEditing:(UITextView *)textView {
	if ([textView.text isEqualToString:MyLocal(@"Write Comments")]) {
		textView.text = @"";
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	if ([AMUtilities isEmpty:textView.text] || [textView.text isEqualToString:TEXT_OF_WRITE_NOTE]) {
		textView.text = TEXT_OF_WRITE_NOTE;
		return;
	}
    
    NSInteger iType = textView.tag % 1000;
//	NSInteger iSection = (textView.tag - iType) / 1000;
    
	switch (iType) {
		case AddNewLeadTextInputType_Comments:
		{
			NSString *strInfo = [textView.text isEqualToString:@""] ? @"" : textView.text;
            [self.dicLeadInfo setObject:strInfo forKey:KEY_OF_LEAD_COMMENTS];
//			[self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:iSection] withRowAnimation:UITableViewRowAnimationNone];
		}
            break;
            
		default:
			break;
	}
}

#pragma mark -

- (void)scrollTableViewCell:(UITextField *)textField {
    
    NSInteger iType = textField.tag % 1000;
    NSInteger iSection = (textField.tag - iType) / 1000;
    
	switch (iType) {
            case AddNewLeadTextInputType_FirstName:
            case AddNewLeadTextInputType_LastName:
            case AddNewLeadTextInputType_CompanyName:
            case AddNewLeadTextInputType_CompanySize:
            case AddNewLeadTextInputType_Title:
            case AddNewLeadTextInputType_CurrentProvider:
            case AddNewLeadTextInputType_EmailAddress:
            case AddNewLeadTextInputType_ReferingEmployee:
            case AddNewLeadTextInputType_PhoneNumber:
        {
            if ([[[self.tableViewMain visibleCells] firstObject] isKindOfClass:[AMNewLeadFirtNameCell class]]) {
                return;
            }
            [self.tableViewMain scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:iSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
            break;
            case AddNewLeadTextInputType_Street:
            case AddNewLeadTextInputType_ZipCode:
            case AddNewLeadTextInputType_City:
            case AddNewLeadTextInputType_Street2:
            case AddNewLeadTextInputType_Country:
            case AddNewLeadTextInputType_SateProvince:
            case AddNewLeadTextInputType_Comments:
        {
            if ([[[self.tableViewMain visibleCells] firstObject] isKindOfClass:[AMNewLeadStreetCell class]]) {
                return;
            }
            [self.tableViewMain scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:iSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
            break;
    }
}

#define myDotNumbers        @"0123456789.\n"
#define myNumbers           @"0123456789\n"
#define myNumbers_F           @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ\n"
#define phoneNumbers        @"0123456789-()\n"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSInteger iType = textField.tag % 1000;
    
	switch (iType) {
		case AddNewLeadTextInputType_ZipCode:
		{
            string = [string uppercaseString];
            
            if ([string isEqualToString:@"\n"]||[string isEqualToString:@""]) {//按下return
                return YES;
            }
            
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers_F] invertedSet];
            if ([string isEqualToString:@"."]) {
                return NO;
            }
            if (textField.text.length >= 6) {
                return NO;
            }
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            return [string isEqualToString:filtered];
		}
            break;
        case AddNewLeadTextInputType_PhoneNumber:
		{
            if ([string isEqualToString:@"\n"]||[string isEqualToString:@""]) {//按下return
                return YES;
            }
            
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:phoneNumbers]invertedSet];
            if ([string isEqualToString:@"."]) {
                return NO;
            }
            NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
            return [string isEqualToString:filtered];
		}
            break;
	}
    
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self scrollTableViewCell:textField];
    
	if ([textField.text isEqualToString:TEXT_OF_NULL]) {
		textField.text = @"";
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
	NSInteger iType = textField.tag % 1000;
    
    switch (iType) {
        case AddNewLeadTextInputType_FirstName:
        {
                [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_FIRSTNAME];
        }
            break;
        case AddNewLeadTextInputType_LastName:
        {
             [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_LASTNAME];
        }
            break;
        case AddNewLeadTextInputType_CompanyName:
        {
             [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_COMPANYNAME];
        }
            break;
        case AddNewLeadTextInputType_CompanySize:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_COMPANYSIZE];
        }
            break;
        case AddNewLeadTextInputType_Title:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_TITLE];
        }
            break;
        case AddNewLeadTextInputType_CurrentProvider:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_CURRENTPROVIDER];
        }
            break;
        case AddNewLeadTextInputType_EmailAddress:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_EMAILADDRESS];
        }
            break;
        case AddNewLeadTextInputType_ReferingEmployee:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_REFERINGEMPLOYEE];
        }
            break;
        case AddNewLeadTextInputType_PhoneNumber:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_PHONENUMBER];
        }
            break;
//        case AddNewLeadTextInputType_ReferingEmployee:
//        {
//            [self.dicLeadInfo setObject:textField.text forKey:KEY_OF_LEAD_REFERINGEMPLOYEE];
//        }
//            break;
        case AddNewLeadTextInputType_Street:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_STREET];
        }
            break;
        case AddNewLeadTextInputType_ZipCode:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_ZIPCODE];
        }
            break;
        case AddNewLeadTextInputType_City:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_CITY];
        }
            break;
        case AddNewLeadTextInputType_Street2:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_STATE];
        }
            break;
        case AddNewLeadTextInputType_Country:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_COUNTRY];
        }
            break;
        case AddNewLeadTextInputType_SateProvince:
        {
            [self.dicLeadInfo setObject:[self strChange:textField.text] forKey:KEY_OF_LEAD_STATEPROVINCE];
        }
            break;
    }
    
    if ([textField.text length] == 0) {
		textField.text = TEXT_OF_NULL;
	}
    
//    [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:iSection] withRowAnimation:UITableViewRowAnimationNone];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return YES;
}

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
    CGRect btnFrame = self.tableViewMain.frame;
//    btnFrame.size.height = btnFrame.size.height + keyboardBounds.size.height;
    btnFrame.size.height = self.view.frame.size.height;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.tableViewMain.frame = btnFrame;
    [UIView commitAnimations];
}

#pragma mark -

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
	if (aVerificationStatusTableViewController.tag == PopViewType_NewLead_FirstName) {
		NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
		[self.dicLeadInfo setObject:strInfo forKey:KEY_OF_LEAD_FIRSTNAME_PR];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	}
    else if(aVerificationStatusTableViewController.tag == PopViewType_NewLead_CompanySize)
    {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
		[self.dicLeadInfo setObject:strInfo forKey:KEY_OF_LEAD_COMPANYSIZE];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(aVerificationStatusTableViewController.tag == PopViewType_NewLead_Country)
    {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        
        if ([[dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY] length] != 0 && ![[dicLeadInfo objectForKey:KEY_OF_LEAD_COUNTRY] isEqualToString:strInfo]) {
            [dicLeadInfo setObject:@"" forKey:KEY_OF_LEAD_STATEPROVINCE];
        }
        
		[self.dicLeadInfo setObject:strInfo forKey:KEY_OF_LEAD_COUNTRY];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    else if(aVerificationStatusTableViewController.tag == PopViewType_NewLead_State)
    {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
		[self.dicLeadInfo setObject:strInfo forKey:KEY_OF_LEAD_STATEPROVINCE];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}



@end
