//
//  AMAddNewContactViewController.m
//  AramarkFSP
//
//  Created by bkendall on 3/25/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

#import "AMNewContactCell.h"
#import "AMAddNewContactViewController.h"
#import "AMPopoverSelectTableViewController.h"
#import "AMNormalTitleSection.h"

typedef NS_ENUM (NSInteger, AddNewContactTextInputType) {
    AddNewContactTextInputType_FirstName = 0,
    AddNewContactTextInputType_Email,
    AddNewContactTextInputType_LastName,
    AddNewContactTextInputType_Title,
    AddNewContactTextInputType_Role,
    AddNewContactTextInputType_Phone,
};

typedef NS_ENUM (NSInteger, PopViewType) {
    PopViewType_NewCase_CaseRecordType = 1000,
    PopViewType_NewCase_Type,
    PopViewType_NewCase_Contact,
    PopViewType_NewCase_Asset,
    PopViewType_NewCase_Priority,
};
@interface AMAddNewContactViewController ()<UITextFieldDelegate, UITextViewDelegate,AMPopoverSelectTableViewControllerDelegate,UIPopoverControllerDelegate>
{
    UIPopoverController *aPopoverVC;
    NSMutableArray *arrContacts;
}

@property (nonatomic, strong) UIPopoverController *aPopoverVC;
@property (nonatomic, strong) NSMutableArray *arrContacts;
//@property (nonatomic, strong) AMContact *selectContact;
@end
@implementation AMAddNewContactViewController
@synthesize isPop;
@synthesize arrContacts;
@synthesize aPopoverVC;
@synthesize dicContactInfo;
//@synthesize selectContact;
@synthesize selectedContact;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        dicContactInfo = [NSMutableDictionary dictionary];
        arrContacts = [NSMutableArray array];
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

    if (self.selectedContact == nil) {
        //Clear out the contact stuff
        [self.dicContactInfo setObject:@"" forKey:KEY_OF_CONTACT_EMAIL];
        [self.dicContactInfo setObject:@"" forKey:KEY_OF_CONTACT_FIRST_NAME];
        [self.dicContactInfo setObject:@"" forKey:KEY_OF_CONTACT_LAST_NAME];
        [self.dicContactInfo setObject:@"" forKey:KEY_OF_CONTACT_TITLE];
        [self.dicContactInfo setObject:@"" forKey:KEY_OF_CONTACT_ROLE];
        [self.dicContactInfo setObject:@"" forKey:KEY_OF_CONTACT_PHONE];
    } else {
        [self.dicContactInfo setObject:self.selectedContact.email != nil ? self.selectedContact.email : @"" forKey:KEY_OF_CONTACT_EMAIL];
        [self.dicContactInfo setObject:self.selectedContact.firstName != nil ? self.selectedContact.firstName : @"" forKey:KEY_OF_CONTACT_FIRST_NAME];
        [self.dicContactInfo setObject:self.selectedContact.lastName != nil ? self.selectedContact.lastName : @""  forKey:KEY_OF_CONTACT_LAST_NAME];
        [self.dicContactInfo setObject:self.selectedContact.title != nil ? self.selectedContact.title : @"" forKey:KEY_OF_CONTACT_TITLE];
        [self.dicContactInfo setObject:self.selectedContact.role != nil ? self.selectedContact.role :@"" forKey:KEY_OF_CONTACT_ROLE];
        [self.dicContactInfo setObject:self.selectedContact.phone != nil ? self.selectedContact.phone : @"" forKey:KEY_OF_CONTACT_PHONE];
    }
    
    //TODO bkk 3/25/2015 add all of the other items to be show on the cell.
    [self.tableViewMain reloadData];
}

#pragma mark -
- (IBAction)clickSelectRoles:(UIButton *)sender {
    [self.tableViewMain endEditing:YES];
    
    if (!self.selectedContact) {
        //Role is only selectable for new contacts.
        AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
        popView.delegate = self;
        popView.isMultiselect = YES;
        popView.tag = PopViewType_NewCase_Contact;
        
        NSMutableArray *arrInfos = [NSMutableArray array];
        
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Alternate Contact") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Alternate Contact"}];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Decision Maker") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Decision Maker"}];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"AP Contact") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"AP Contact"}];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Delivery Contact") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Delivery Contact"}];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Order Contact") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Order Contact"}];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Service Contact") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Service Contact"}];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Done") ,kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Done"}];
        popView.arrInfos = arrInfos;
        aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
        [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
        aPopoverVC.delegate = self;
        [aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    }
}

- (IBAction)clickSaveBtn:(id)sender {
    
    DLog(@"%@",dicContactInfo);
    
    if ([[self.dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input First Name")];
        return;
    } else if (![[self.dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME] isEqualToString:[[self.dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME] capitalizedString]]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"First name must be capitalized")];
        return;
    }
    
    if ([[self.dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL] length] != 0 && ![AMUtilities isValidEmailValueTyped:[self.dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL]]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Valid Email Address")];
        return;
    }
    
    if ([[self.dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Last Name")];
        return;
    } else if (![[self.dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME] isEqualToString:[[self.dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME] capitalizedString]]) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Last name must be capitalized")];
        return;
        
    }
    
    if ([[self.dicContactInfo objectForKey:KEY_OF_CONTACT_TITLE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Title")];
        return;
    }
    
    if ([[self.dicContactInfo objectForKey:KEY_OF_CONTACT_ROLE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Select Role")];
        return;
    }
    
    if (self.selectedContact != nil) {
        //edit mode
        self.selectedContact.firstName = [self.dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME];
        self.selectedContact.lastName = [self.dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME];
        self.selectedContact.email = [self.dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL];
        self.selectedContact.role = [self.dicContactInfo objectForKey:KEY_OF_CONTACT_ROLE];
        self.selectedContact.title = [self.dicContactInfo objectForKey:KEY_OF_CONTACT_TITLE];
        self.selectedContact.phone = [self.dicContactInfo objectForKey:KEY_OF_CONTACT_PHONE];
        self.selectedContact.lastModifiedDate = [NSDate date];
        [[AMLogicCore sharedInstance] updateContact:self.selectedContact shouldDelete:NO completionBlock:^(NSInteger type, NSError *error) {
            //todo: SYNC
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
         
    } else {
        //save new mode
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dismissAMAddNewContactViewController:dictContactInfo:)]) {
            [self.delegate dismissAMAddNewContactViewController:self dictContactInfo:dicContactInfo];
        }
        
        [[AMLogicCore sharedInstance] createNewContactInDBWithSetupBlock:^(AMDBNewContact *newContact) {
            newContact.createdDate = [NSDate date];
            newContact.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
            newContact.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];;
            newContact.accountID = self.selectedWorkOrder.accountID;// @"xxxxxx";
            //newContact.contactID = @"xxxx";
            newContact.posID = self.selectedWorkOrder.posID;
            newContact.phone = [dicContactInfo objectForKey:KEY_OF_CONTACT_PHONE] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_PHONE];
            newContact.name = [NSString stringWithFormat:@"%@ %@", [dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME], [dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME]];
            newContact.lastName = [dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME];
            newContact.firstName =[dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME];
            newContact.email = [dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL];
            newContact.role = [dicContactInfo objectForKey:KEY_OF_CONTACT_ROLE] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_ROLE];
            newContact.title = [dicContactInfo objectForKey:KEY_OF_CONTACT_TITLE] == nil ? @"" : [dicContactInfo objectForKey:KEY_OF_CONTACT_TITLE];


        } completion:^(NSInteger type, NSError *error) {
            //todo Error stuff
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AMNewContactCell *cell = (AMNewContactCell *)[tableView dequeueReusableCellWithIdentifier:@"AMNewContactCell"];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNewContactCell" owner:[AMNewContactCell class] options:nil];
        cell = (AMNewContactCell *)[nib objectAtIndex:0];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.btnChooseRoles addTarget:self action:@selector(clickSelectRoles:) forControlEvents:UIControlEventTouchUpInside];
                
    cell.textFieldFirstName.delegate = self;
    cell.textFieldFirstName.tag = (indexPath.section * 1000 + AddNewContactTextInputType_FirstName);
    cell.textFieldFirstName.text = [[self.dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME] length] == 0 ? TEXT_OF_NULL : [self.dicContactInfo objectForKey:KEY_OF_CONTACT_FIRST_NAME];
    
    cell.textFieldEmail.delegate = self;
    cell.textFieldEmail.tag = (indexPath.section * 1000 + AddNewContactTextInputType_Email);
    cell.textFieldEmail.text = [[self.dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL] length] == 0 ? TEXT_OF_NULL : [self.dicContactInfo objectForKey:KEY_OF_CONTACT_EMAIL];
    
    cell.textFieldLastName.delegate = self;
    cell.textFieldLastName.tag = (indexPath.section * 1000 + AddNewContactTextInputType_LastName);
    cell.textFieldLastName.text = [[self.dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME] length] == 0 ? TEXT_OF_NULL : [self.dicContactInfo objectForKey:KEY_OF_CONTACT_LAST_NAME];
    
    cell.textFieldTitle.delegate = self;
    cell.textFieldTitle.tag = (indexPath.section * 1000 + AddNewContactTextInputType_Title);
    cell.textFieldTitle.text = [[self.dicContactInfo objectForKey:KEY_OF_CONTACT_TITLE] length] == 0 ? TEXT_OF_NULL : [self.dicContactInfo objectForKey:KEY_OF_CONTACT_TITLE];
    
    cell.labelTChooseRoles.tag = (indexPath.section * 1000 + AddNewContactTextInputType_Role);
    cell.labelTChooseRoles.text = [[self.dicContactInfo objectForKey:KEY_OF_CONTACT_ROLE] length] == 0 ? TEXT_OF_NULL : [self.dicContactInfo objectForKey:KEY_OF_CONTACT_ROLE];
        
    cell.textFieldPhone.delegate = self;
    cell.textFieldPhone.tag = (indexPath.section * 1000 + AddNewContactTextInputType_Phone);
    cell.textFieldPhone.text = [[self.dicContactInfo objectForKey:KEY_OF_CONTACT_PHONE] length] == 0 ? TEXT_OF_NULL : [self.dicContactInfo objectForKey:KEY_OF_CONTACT_PHONE];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 225.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMNormalTitleSection" owner:[AMNormalTitleSection class] options:nil];
    AMNormalTitleSection *aView = (AMNormalTitleSection *)[nib objectAtIndex:0];
    if (self.selectedContact) {
        aView.labelTitle.text = MyLocal(@"Update Contact");
    } else {
        aView.labelTitle.text = MyLocal(@"New Contact");
    }
    
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
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger iType = textField.tag % 1000;

    //Always upper case the changed string to ensure it passes server side validation
    NSString * proposedNewString = [[[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:TEXT_OF_NULL withString:@""] capitalizedString];
    
    switch (iType) {
        case AddNewContactTextInputType_FirstName:
        {            
            [self.dicContactInfo setObject:[self strChange:[proposedNewString capitalizedString]] forKey:KEY_OF_CONTACT_FIRST_NAME];
        }
            break;
        case AddNewContactTextInputType_Email:
        {
            [self.dicContactInfo setObject:[self strChange:proposedNewString] forKey:KEY_OF_CONTACT_EMAIL];
        }
            break;
        case AddNewContactTextInputType_LastName:
        {
            [self.dicContactInfo setObject:[self strChange:[proposedNewString capitalizedString]] forKey:KEY_OF_CONTACT_LAST_NAME];
        }
            break;
        case AddNewContactTextInputType_Title:
        {
            [self.dicContactInfo setObject:[self strChange:[proposedNewString capitalizedString]] forKey:KEY_OF_CONTACT_TITLE];
        }
            break;
        case AddNewContactTextInputType_Role:
        {
            [self.dicContactInfo setObject:[self strChange:[proposedNewString capitalizedString]] forKey:KEY_OF_CONTACT_ROLE];
        }
            break;
            
        case AddNewContactTextInputType_Phone:
        {
            [self.dicContactInfo setObject:[self strChange: proposedNewString] forKey:KEY_OF_CONTACT_PHONE];
        }
            break;
    }

    return YES;
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
        case AddNewContactTextInputType_FirstName:
        {
            [self.dicContactInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CONTACT_FIRST_NAME];
        }
            break;
        case AddNewContactTextInputType_Email:
        {
            [self.dicContactInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CONTACT_EMAIL];
        }
            break;
        case AddNewContactTextInputType_LastName:
        {
            [self.dicContactInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CONTACT_LAST_NAME];
        }
            break;
        case AddNewContactTextInputType_Title:
        {
            [self.dicContactInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CONTACT_TITLE];
        }
            break;
        case AddNewContactTextInputType_Role:
        {
            [self.dicContactInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CONTACT_ROLE];
        }
            break;
            
        case AddNewContactTextInputType_Phone:
        {
            [self.dicContactInfo setObject:[self strChange:textField.text] forKey:KEY_OF_CONTACT_PHONE];
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

#pragma mark - POPOver Delegate

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelectMulti:(NSString *)selectionString
{
    if (aVerificationStatusTableViewController.tag == PopViewType_NewCase_Contact) {
        NSString *strInfo = selectionString;// [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        //selectContact = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
        [self.dicContactInfo setObject:strInfo forKey:KEY_OF_CONTACT_ROLE];
        
        NSLog(@"didSelected : %@", selectionString);
        [aPopoverVC dismissPopoverAnimated:YES];
        
        [self.tableViewMain reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}
- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
    if (aVerificationStatusTableViewController.tag == PopViewType_NewCase_Contact) {
        NSString *strInfo = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        //selectContact = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
    
        [self.dicContactInfo setObject:strInfo forKey:KEY_OF_CONTACT_ROLE];
    
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
