//
//  AMCheckoutViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

//TODO :: 当workordertype == preventative maintenance 时，显示 maintenance type cell 否则显示 work performed cell

/***************************************************************************************************************
 Change Log:
 -----------
 December 2014 Relese. ITEM000121: Check Out on Install WO Adding Asset and Warning. By Hari Kolasani. 12/9/2014
 ***************************************************************************************************************/

#import "AMCheckoutViewController.h"
#import "AMWorkOrder.h"

#import "AMTitleTableViewCell.h"
#import "AMInvoiceCodeTableViewCell.h"
#import "AMWorkPerformedTableViewCell.h"
#import "AMMaintenanceTypeTableViewCell.h"
#import "AMFilterNameTableViewCell.h"
#import "AMAddTableViewCell.h"
#import "AMWorkOrderViewController.h"
#import "AMPartNameTableViewCell.h"
#import "AMPMNameTableViewCell.h"

#import "AMWorkOrderNotesTableViewCell.h"
#import "AMRepairTableViewCell.h"
#import "AMTitleWithAddTableViewCell.h"
#import "AMPopoverSelectTableViewController.h"

#import "AMParts.h"

#import "KLCPopup.h"
#import "TBView.h"

#define MAX_FILTER_COUNT    5
#define MAX_PART_COUNT      5
#define MAX_PM_COUNT        1
#define TEXT_OF_CREATE          @"Unresolved"
#define TEXT_OF_NEED_PARTS      @"Needs Part"
//#define TEXT_OF_VENDING_FIX     MyLocal(@"Vending Fix")

#define TEXT_OF_FILTER_EXCHANGE         @"Filter Exchange"  //TODO::Enhancement140929
#define TEXT_OF_REFUSED_FILTER_EXCHANGE @"Refused Filter Change"//TODO::Enhancement140929
#define TEXT_OF_REPLACED_FILTER @"Replaced Filter"//bkk 1/30/2015
#define TEXT_OF_REFUSED_FILTER_REFUSED @"Refused-Customer Refused"
#define TEXT_OF_REFUSED_NO_FILTER @"Refused-No Filter"
#define TEXT_OF_REPAIR @"Repair"
#define TEXT_OF_INSTALL @"Install"
#define TEXT_OF_SWAP @"Swap"

typedef NS_ENUM (NSInteger, TextInputType) {
	TextInputType_WorkOrderNotes = 0,
	TextInputType_FilterName,
	TextInputType_FilterPrice,
	TextInputType_PartsName,
    
	TextInputType_HoursRate,
	TextInputType_MaintenanceFee,
	TextInputType_FilterQuantity,
	TextInputType_PartQuantity,
};

typedef NS_ENUM (NSInteger, PopViewType) {
	PopViewType_Select_RepairCode = 1000,
	PopViewType_Select_HoursWorked,
    PopViewType_Select_InvoiceCode,
	PopViewType_Select_FilterName,
	PopViewType_Select_PartName,
    PopViewType_Select_FilterType,//bkk 2/5/15
    PopViewType_Select_PMName,//bkk 20170203
};

//bkk 2/5/2015
typedef NS_ENUM(NSInteger, FieldTag) {
    FieldTagHorizontalLayout = 1001,
    FieldTagVerticalLayout,
    FieldTagMaskType,
    FieldTagShowType,
    FieldTagDismissType,
    FieldTagBackgroundDismiss,
    FieldTagContentDismiss,
    FieldTagTimedDismiss,
};

@interface AMCheckoutViewController ()
<
UITextViewDelegate,
UITextFieldDelegate,
UIPopoverControllerDelegate,
AMPopoverSelectTableViewControllerDelegate,
AMWorkOrderViewControllerDelegate
>
{
	UIPopoverController *aPopoverVC;

    NSMutableArray *arrCodeItems;
    NSMutableArray *arrFilterItems;
    NSMutableArray *arrPartItems;
    NSMutableArray *arrWorkItems;
    NSMutableArray *arrPMItems;
    
    NSMutableArray *arrCodePriceList;
    
    //bkk - 2/5/2015
    
    NSArray* _fields;
    NSDictionary* _namesForFields;
    
    NSArray* _horizontalLayouts;
    NSArray* _verticalLayouts;
    NSArray* _maskTypes;
    NSArray* _showTypes;
    NSArray* _dismissTypes;
    
    NSDictionary* _namesForHorizontalLayouts;
    NSDictionary* _namesForVerticalLayouts;
    NSDictionary* _namesForMaskTypes;
    NSDictionary* _namesForShowTypes;
    NSDictionary* _namesForDismissTypes;
    
    NSInteger _selectedRowInHorizontalField;
    NSInteger _selectedRowInVerticalField;
    NSInteger _selectedRowInMaskField;
    NSInteger _selectedRowInShowField;
    NSInteger _selectedRowInDismissField;
    
    BOOL _shouldDismissOnBackgroundTouch;
    BOOL _shouldDismissOnContentTouch;
    BOOL _shouldDismissAfterDelay;
}

@property (nonatomic, strong) UIPopoverController *aPopoverVC;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (nonatomic, strong) NSMutableArray *arrCodeItems;
@property (nonatomic, strong) NSMutableArray *arrFilterItems;
@property (nonatomic, strong) NSMutableArray *arrPMItems;
@property (nonatomic, strong) NSMutableArray *arrPartItems;
@property (nonatomic, strong) NSMutableArray *arrWorkItems;
@property (nonatomic, strong) NSMutableArray *arrCodePriceList;
@property (nonatomic, strong) UILabel *lblQty;//bkk 2/5/15
@property (nonatomic, strong) UIButton *selectFilterButton;//bkk 2/5/15



//bkk 2/5/15
- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag;
- (void)saveButtonPressed:(id)sender;
@end

@implementation AMCheckoutViewController
@synthesize aPopoverVC;
@synthesize workOrder;
@synthesize arrCheckoutInfos;
@synthesize delegate;
@synthesize arrInvoiceItems;
@synthesize arrCodeItems;
@synthesize arrFilterItems;
@synthesize arrPartItems;
@synthesize arrPMItems;
@synthesize arrWorkItems;
@synthesize arrCodePriceList;
@synthesize strNotes;
@synthesize strRepairCode;
@synthesize strPMCode;
@synthesize arrResultAssetRequest;
@synthesize lblQty;//bkk 2/5/15
@synthesize selectFilterButton;
@synthesize strSelectedFilters;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
        // MAIN LIST
        _fields = @[@(FieldTagHorizontalLayout),
                    @(FieldTagVerticalLayout),
                    @(FieldTagMaskType),
                    @(FieldTagShowType),
                    @(FieldTagDismissType),
                    @(FieldTagBackgroundDismiss),
                    @(FieldTagContentDismiss),
                    @(FieldTagTimedDismiss)];
        
        _namesForFields = @{@(FieldTagHorizontalLayout) : @"Horizontal layout",
                            @(FieldTagVerticalLayout) : @"Vertical layout",
                            @(FieldTagMaskType) : @"Background mask",
                            @(FieldTagShowType) : @"Show type",
                            @(FieldTagDismissType) : @"Dismiss type",
                            @(FieldTagBackgroundDismiss) : @"Dismiss on background touch",
                            @(FieldTagContentDismiss) : @"Dismiss on content touch",
                            @(FieldTagTimedDismiss) : @"Dismiss after delay"};
        
        // FIELD SUB-LISTS
        _horizontalLayouts = @[@(KLCPopupHorizontalLayoutLeft),
                               @(KLCPopupHorizontalLayoutLeftOfCenter),
                               @(KLCPopupHorizontalLayoutCenter),
                               @(KLCPopupHorizontalLayoutRightOfCenter),
                               @(KLCPopupHorizontalLayoutRight)];
        
        _namesForHorizontalLayouts = @{@(KLCPopupHorizontalLayoutLeft) : @"Left",
                                       @(KLCPopupHorizontalLayoutLeftOfCenter) : @"Left of Center",
                                       @(KLCPopupHorizontalLayoutCenter) : @"Center",
                                       @(KLCPopupHorizontalLayoutRightOfCenter) : @"Right of Center",
                                       @(KLCPopupHorizontalLayoutRight) : @"Right"};
        
        _verticalLayouts = @[@(KLCPopupVerticalLayoutTop),
                             @(KLCPopupVerticalLayoutAboveCenter),
                             @(KLCPopupVerticalLayoutCenter),
                             @(KLCPopupVerticalLayoutBelowCenter),
                             @(KLCPopupVerticalLayoutBottom)];
        
        _namesForVerticalLayouts = @{@(KLCPopupVerticalLayoutTop) : @"Top",
                                     @(KLCPopupVerticalLayoutAboveCenter) : @"Above Center",
                                     @(KLCPopupVerticalLayoutCenter) : @"Center",
                                     @(KLCPopupVerticalLayoutBelowCenter) : @"Below Center",
                                     @(KLCPopupVerticalLayoutBottom) : @"Bottom"};
        
        _maskTypes = @[@(KLCPopupMaskTypeNone),
                       @(KLCPopupMaskTypeClear),
                       @(KLCPopupMaskTypeDimmed)];
        
        _namesForMaskTypes = @{@(KLCPopupMaskTypeNone) : @"None",
                               @(KLCPopupMaskTypeClear) : @"Clear",
                               @(KLCPopupMaskTypeDimmed) : @"Dimmed"};
        
        _showTypes = @[@(KLCPopupShowTypeNone),
                       @(KLCPopupShowTypeFadeIn),
                       @(KLCPopupShowTypeGrowIn),
                       @(KLCPopupShowTypeShrinkIn),
                       @(KLCPopupShowTypeSlideInFromTop),
                       @(KLCPopupShowTypeSlideInFromBottom),
                       @(KLCPopupShowTypeSlideInFromLeft),
                       @(KLCPopupShowTypeSlideInFromRight),
                       @(KLCPopupShowTypeBounceIn),
                       @(KLCPopupShowTypeBounceInFromTop),
                       @(KLCPopupShowTypeBounceInFromBottom),
                       @(KLCPopupShowTypeBounceInFromLeft),
                       @(KLCPopupShowTypeBounceInFromRight)];
        
        _namesForShowTypes = @{@(KLCPopupShowTypeNone) : @"None",
                               @(KLCPopupShowTypeFadeIn) : @"Fade in",
                               @(KLCPopupShowTypeGrowIn) : @"Grow in",
                               @(KLCPopupShowTypeShrinkIn) : @"Shrink in",
                               @(KLCPopupShowTypeSlideInFromTop) : @"Slide from Top",
                               @(KLCPopupShowTypeSlideInFromBottom) : @"Slide from Bottom",
                               @(KLCPopupShowTypeSlideInFromLeft) : @"Slide from Left",
                               @(KLCPopupShowTypeSlideInFromRight) : @"Slide from Right",
                               @(KLCPopupShowTypeBounceIn) : @"Bounce in",
                               @(KLCPopupShowTypeBounceInFromTop) : @"Bounce from Top",
                               @(KLCPopupShowTypeBounceInFromBottom) : @"Bounce from Bottom",
                               @(KLCPopupShowTypeBounceInFromLeft) : @"Bounce from Left",
                               @(KLCPopupShowTypeBounceInFromRight) : @"Bounce from Right"};
        
        _dismissTypes = @[@(KLCPopupDismissTypeNone),
                          @(KLCPopupDismissTypeFadeOut),
                          @(KLCPopupDismissTypeGrowOut),
                          @(KLCPopupDismissTypeShrinkOut),
                          @(KLCPopupDismissTypeSlideOutToTop),
                          @(KLCPopupDismissTypeSlideOutToBottom),
                          @(KLCPopupDismissTypeSlideOutToLeft),
                          @(KLCPopupDismissTypeSlideOutToRight),
                          @(KLCPopupDismissTypeBounceOut),
                          @(KLCPopupDismissTypeBounceOutToTop),
                          @(KLCPopupDismissTypeBounceOutToBottom),
                          @(KLCPopupDismissTypeBounceOutToLeft),
                          @(KLCPopupDismissTypeBounceOutToRight)];
        
        _namesForDismissTypes = @{@(KLCPopupDismissTypeNone) : @"None",
                                  @(KLCPopupDismissTypeFadeOut) : @"Fade out",
                                  @(KLCPopupDismissTypeGrowOut) : @"Grow out",
                                  @(KLCPopupDismissTypeShrinkOut) : @"Shrink out",
                                  @(KLCPopupDismissTypeSlideOutToTop) : @"Slide to Top",
                                  @(KLCPopupDismissTypeSlideOutToBottom) : @"Slide to Bottom",
                                  @(KLCPopupDismissTypeSlideOutToLeft) : @"Slide to Left",
                                  @(KLCPopupDismissTypeSlideOutToRight) : @"Slide to Right",
                                  @(KLCPopupDismissTypeBounceOut) : @"Bounce out",
                                  @(KLCPopupDismissTypeBounceOutToTop) : @"Bounce to Top",
                                  @(KLCPopupDismissTypeBounceOutToBottom) : @"Bounce to Bottom",
                                  @(KLCPopupDismissTypeBounceOutToLeft) : @"Bounce to Left",
                                  @(KLCPopupDismissTypeBounceOutToRight) : @"Bounce to Right"};
        
        // DEFAULTS
        _selectedRowInHorizontalField = [_horizontalLayouts indexOfObject:@(KLCPopupHorizontalLayoutCenter)];
        _selectedRowInVerticalField = [_verticalLayouts indexOfObject:@(KLCPopupVerticalLayoutCenter)];
        _selectedRowInMaskField = [_maskTypes indexOfObject:@(KLCPopupMaskTypeDimmed)];
        _selectedRowInShowField = [_showTypes indexOfObject:@(KLCPopupShowTypeBounceInFromTop)];
        _selectedRowInDismissField = [_dismissTypes indexOfObject:@(KLCPopupDismissTypeBounceOutToBottom)];
        _shouldDismissOnBackgroundTouch = YES;
        _shouldDismissOnContentTouch = NO;
        _shouldDismissAfterDelay = NO;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
    
    [self.btnNext.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    [self.btnCreateNew.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    [self.labelSubTitle setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    
	self.mainTableView.sectionIndexBackgroundColor = [UIColor whiteColor];
	self.mainTableView.sectionIndexColor = [UIColor whiteColor];
	[self.mainTableView reloadData];
    
    [self.btnNext.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    
    [self.btnNext setTitle:MyLocal(@"SUBMIT") forState:UIControlStateNormal];
    [self.btnNext setTitle:MyLocal(@"SUBMIT") forState:UIControlStateHighlighted];
    
    [self.btnCreateNew setTitle:MyLocal(@"CREATE NEW WORK ORDER") forState:UIControlStateNormal];
    [self.btnCreateNew setTitle:MyLocal(@"CREATE NEW WORK ORDER") forState:UIControlStateHighlighted];
    
    self.labelSubTitle.text = [NSString stringWithFormat:@"%@:",MyLocal(@"ESTIMATED PRICE")];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveButtonPressed:)
                                                 name:@"POST_FILTERS_AND_QUANTITIES"
                                               object:nil];
    self.strSelectedFilters = [NSMutableString string];
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithWorkOrder:(AMWorkOrder *)aWorkOrder {
	self = [self initWithNibName:@"AMWorkOrderViewController" bundle:nil];
	if (self) {
		[self setupDataSourceByWorkOrder:aWorkOrder];
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
//	DLog(@"viewWillLayoutSubviews : AMCheckoutViewController");
	self.view.frame = self.view.superview.bounds;
}

//bkk 2/5/15
-(NSMutableArray *)filterNames {
    return       [NSMutableArray arrayWithObjects:
                  @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Filter 1"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Filter 1"},
                  @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Filter 2"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Filter 2"},
                  @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Filter 3"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Filter 3"},
                  @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Filter 4"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Filter 4"},
                  @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Filter 5"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Filter 5"},
                  nil];
}
-(NSMutableArray *)repairCodes
{
    if ([self.workOrder.woType isEqualToString:MyLocal(@"Filter Exchange")]) {
        return       [NSMutableArray arrayWithObjects:
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Replaced Filter"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Replaced Filter"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Refused-Customer Refused"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Refused-Customer Refused"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Refused-No Filter"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Refused-No Filter"},
          nil];
    }else {
        return       [NSMutableArray arrayWithObjects:
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Administrative Work Done"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Administrative Work Done"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Called Machine Manufacturer"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Called Machine Manufacturer"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Delivered Product"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Delivered Product"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Exchanged Equipment"), kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Exchanged Equipment"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_REFUSED_FILTER_EXCHANGE),kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_REFUSED_FILTER_EXCHANGE},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Installed Equipment"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Installed Equipment"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Kiosk On-Line"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Kiosk On-Line"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Moved Equipment"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Moved Equipment"},
          //bkk 1/30/2015 - removed below line per 
          //@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Needs Part"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Needs Part"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"No Problem"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"No Problem"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Preventative Maintenance"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Preventative Maintenance"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Removed Equipment"),kAMPOPOVER_DICTIONARY_KEY_VALUE :@"Removed Equipment"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Repaired Brewer"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Repaired Brewer"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Repaired Leak"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Repaired Leak"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Repaired Money/Product Jam"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Repaired Money/Product Jam"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Replaced Filter"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Replaced Filter"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Shop Work Completed"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Shop Work Completed"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Site Survey Complete"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Site Survey Complete"},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_CREATE),kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_CREATE},
          @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Vending"),kAMPOPOVER_DICTIONARY_KEY_VALUE : @"Vending"},
          nil];
    }
}
-(void)showPopup {
    // Generate content view to present
    TBView *contentView = [[TBView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    contentView.parentVC = self;
    
    // Show in popup
    KLCPopup* popup = [KLCPopup popupWithContentView:contentView
                                            showType:KLCPopupShowTypeSlideInFromTop
                                         dismissType:KLCPopupDismissTypeSlideOutToTop
                                            maskType:(KLCPopupMaskType)[self valueForRow:_selectedRowInMaskField inFieldWithTag:FieldTagMaskType]
                            dismissOnBackgroundTouch:_shouldDismissOnBackgroundTouch
                               dismissOnContentTouch:_shouldDismissOnContentTouch];
    [popup show];
}
#pragma mark -

- (void)refreshToInitialization {
}

#pragma mark - Click

- (IBAction)clickCreatNewBtn:(UIButton *)sender {
    DLog(@"clickCreatNewBtn");

      [self newWorkOrderButtonTapped];
}

//TODO::Enhancement140929
- (IBAction)clickSubmitBtn:(UIButton *)sender {
    DLog(@"clickSubmitBtn");
    
    NSMutableDictionary *dicRepairCode = [[self dataWithType:AMCheckoutCellType_Checkout_RepairCode] objectForKey:KEY_OF_CELL_DATA];
    
    if ([[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Repair Code")];
        return;
    }
    
    
    AMWorkOrderNotesTableViewCell *cell = (AMWorkOrderNotesTableViewCell *)[(UITableView *)self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    
    if ([self.workOrder.woType isEqualToString:TEXT_OF_REPAIR] && (cell.textViewWorkOrderNotes.text.length == 0 || [cell.textViewWorkOrderNotes.text isEqualToString:@"Write note"])) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Work Order Notes")];
        return;
    }
    
    //i&e 604 - 12/8/2015 - repair code update
    if ([self.workOrder.woType isEqualToString:TEXT_OF_FILTER_EXCHANGE] && (cell.textViewWorkOrderNotes.text.length == 0 || [cell.textViewWorkOrderNotes.text isEqualToString:@"Write note"] )) {
        if ([[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:MyLocal(@"Refused-Customer Refused")] || [[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:MyLocal(@"Refused-No Filter")]) {
            [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Work Order Notes")];
            return;
        }
        
    }
    
    //bkk 1/29/2015
    if (![self.workOrder.woType isEqualToString:TEXT_OF_FILTER_EXCHANGE] && [[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:TEXT_OF_REPLACED_FILTER])
    {
        //bkk - popup shows
        [self showPopup];
    } else {
        //Change: ITEM000121
        //Change item-000611 - Swap Validation Rule
        if ([self.workOrder.woType isEqualToString:TEXT_OF_INSTALL] || [self.workOrder.woType isEqualToString:TEXT_OF_SWAP]) {
            if([self.arrResultAssetRequest count] == 0) {
                [AMUtilities showAlertWithInfo:MyLocal(@"Please Add Asset")];
                return;
            }
        }
        
        if ([self.workOrder.woType isEqualToString:TEXT_OF_FILTER_EXCHANGE]) {
            
            if (![[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:@"Refused-Customer Refused"] && ![[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:@"Refused-No Filter"]) {
                if ([arrFilterItems count] == 0) {
                    //[AMUtilities showAlertWithInfo:MyLocal(@"Please update the filter information")];
                    [self showPopup];
                    return;
                }
                else
                {
                    BOOL exist = NO;
                    BOOL existPrice = NO;
                    
                    for (AMInvoice *invoce in arrFilterItems) {
                        if([invoce.quantity intValue] != 0)
                        {
                            exist = YES;
                        }
                        
                        if([invoce.unitPrice intValue] == 0)
                        {
                            existPrice = YES;
                        }
                    }
                    
                    if(!exist)
                    {
                        [AMUtilities showAlertWithInfo:MyLocal(@"Filter quantity cannot be 0")];
                        return;
                    }
                    
                    if (existPrice) {
                        [UIAlertView showWithTitle:@""
                                           message:MyLocal(@"You are trying to submit a work order with “0.00 Invoice” Do you want to proceed?")
                                 cancelButtonTitle:MyLocal(@"No")
                                 otherButtonTitles:@[MyLocal(@"Yes")]
                                          tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                                  return ;
                                              }
                                              else
                                              {
                                                  [self showFilterExchangeSubmit];
                                              }
                                          }];
                    }
                    else
                    {
                        [self showFilterExchangeSubmit];
                    }
                }
            }
            else
            {
                BOOL exist = NO;
                
                for (AMInvoice *invoce in arrFilterItems) {
                    if([invoce.quantity intValue] != 0)
                    {
                        exist = YES;
                        break;
                    }
                }
                
                if(exist)
                {
                    [AMUtilities showAlertWithInfo:MyLocal(@"Filter quantity should be 0")];
                    return;
                }
                
                [self showFilterExchangeSubmit];
                
            }
        }
        else
        {
            [self showSubmit];
        }
    }
}

//TODO::Enhancement140929
- (void)showFilterExchangeSubmit
{
    NSArray *woList = [[AMLogicCore sharedInstance] getOpenFilterExchangeWorkOrdersByCaseId:workOrder.caseID];
    if ([woList count] > 1) {
    [UIAlertView showWithTitle:@""
                           message:MyLocal(@"There is another open Filter Exchange WO associated with this Case. Please review Filter Exchange WO.")
                 cancelButtonTitle:MyLocal(@"Continue")
                 otherButtonTitles:nil
                          tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                              if (buttonIndex == [alertView cancelButtonIndex]) {
                                  [self showSubmit];
                                  return;
                              }
                          }];
    }
    else
    {
        [self showSubmit];
    }
}

//TODO::Enhancement140929
- (void)showSubmit
{
    [UIAlertView showWithTitle:@""
                       message:MyLocal(@"Are you sure you want to submit?")
             cancelButtonTitle:MyLocal(@"Cancel")
             otherButtonTitles:@[MyLocal(@"OK")]
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              return ;
                          }
                          else
                          {
                              NSMutableDictionary *dicRepairCode = [[self dataWithType:AMCheckoutCellType_Checkout_RepairCode] objectForKey:KEY_OF_CELL_DATA];
                              
                              self.strRepairCode = [dicRepairCode objectForKey:KEY_OF_REPAIR_CODE];
                              NSMutableDictionary *dicNots = [[self dataWithType:AMCheckoutCellType_Checkout_WorkOrderNotes] objectForKey:KEY_OF_CELL_DATA];
                              self.strNotes = [dicNots objectForKey:KEY_OF_WORKORDER_NOTES];
                                                
                              [self invoiceListWithCurrentData];
                              
                              if (delegate && [delegate respondsToSelector:@selector(didClickCheckoutViewControllerNextBtn)]) {
                                  [delegate didClickCheckoutViewControllerNextBtn];
                              }
                          }
                      }];
}

- (NSMutableArray *)invoiceListWithCurrentData
{
	NSMutableDictionary *dicWorkPerformed = [[self dataWithType:AMCheckoutCellType_Checkout_WorkPerformed] objectForKey:KEY_OF_CELL_DATA];
	NSMutableDictionary *dicMaintenance = [[self dataWithType:AMCheckoutCellType_Checkout_Maintenance] objectForKey:KEY_OF_CELL_DATA];
    
	if ([[dicWorkPerformed objectForKey:KEY_OF_HOURS_WORKED] length] != 0) {
		NSString *strHours = [dicWorkPerformed objectForKey:KEY_OF_HOURS_WORKED];
		NSString *strRate = [dicWorkPerformed objectForKey:KEY_OF_HOURS_RATE];
		NSString *strMaintenanceFee = [dicMaintenance objectForKey:KEY_OF_MAINTENANCE_FEE];
        
        AMInvoice *invoce = [[AMInvoice alloc] init];
		invoce.assetID = self.workOrder.assetID;
		invoce.posID = self.workOrder.posID;
		invoce.woID = self.workOrder.woID;
        invoce.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_LABORCHARGE forObject:RECORD_TYPE_OF_INVOICE];
        invoce.recordTypeName = INVOICE_TYPE_LABORCHARGE;
		invoce.maintenanceFee = [NSNumber numberWithFloat:[strMaintenanceFee floatValue]];
		invoce.hoursRate = [NSNumber numberWithFloat:[strRate floatValue]];
		invoce.hoursWorked = [NSNumber numberWithFloat:[strHours floatValue]];
        invoce.price = [NSNumber numberWithFloat:([strHours floatValue] * [strRate floatValue])];
        invoce.unitPrice = [NSNumber numberWithFloat:[strRate floatValue]];
        invoce.caseId = self.workOrder.caseID;
        
        if ([arrInvoiceItems count] > 0) {
            AMInvoice *first = [arrInvoiceItems objectAtIndex:0];
            invoce.invoiceID = first.invoiceID;
            [arrInvoiceItems replaceObjectAtIndex:0 withObject:invoce];
        }
        else
        {
            [arrInvoiceItems addObject:invoce];
        }
	}
    
    if (arrCodeItems && [arrCodeItems count] > 0) {
		for (NSMutableDictionary *dicCInfo in arrCodeItems) {
            AMDBCustomerPrice *customerPrice = [dicCInfo objectForKey:KEY_OF_CUSTOMER_PRICE];
			if ([customerPrice.productName length] != 0 && customerPrice.price) {
                AMInvoice *invoice = [[AMInvoice alloc] init];
                invoice.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_INVOICECODE forObject:RECORD_TYPE_OF_INVOICE];
                invoice.recordTypeName = INVOICE_TYPE_INVOICECODE;
                
                BOOL contain = NO;
                
                for (AMInvoice *inInfo in arrInvoiceItems) {
                    if ([inInfo.recordTypeID isEqualToString:invoice.recordTypeID]) {
                        contain = YES;
                        break;
                    }
                }
                
                if (!contain) {
                    invoice.price = customerPrice.price;
                    [arrInvoiceItems addObject:invoice];
                }
			}
		}
	}
    
	if (arrFilterItems && [arrFilterItems count] > 0) {
		for (AMInvoice *invoice in arrFilterItems) {
			if ([invoice.filterName length] != 0 && [invoice.quantity intValue] != 0) {
                if (![arrInvoiceItems containsObject:invoice]) {
                    invoice.price = [NSNumber numberWithFloat:[invoice.unitPrice floatValue] * [invoice.quantity floatValue]];
                    invoice.unitPrice = invoice.unitPrice;
                    if (invoice.quantity && [invoice.quantity intValue] != 0) {
                        [arrInvoiceItems addObject:invoice];
                    }
                } else {
                    int index = [arrInvoiceItems indexOfObject:invoice];
                    NSInteger qtySum = [((AMInvoice *)[arrInvoiceItems objectAtIndex:index]).quantity integerValue] + [invoice.quantity integerValue];
                    [(AMInvoice *)[arrInvoiceItems objectAtIndex:index] setQuantity: [NSNumber numberWithInteger: qtySum]];
                }
			}
		}
	}
    
    if (arrPartItems && [arrPartItems count] > 0) {
		for (AMInvoice *invoice in arrPartItems) {
			if ([invoice.partsName length] != 0  && [invoice.quantity intValue] != 0) {
                if (![arrInvoiceItems containsObject:invoice]) {
                    [arrInvoiceItems addObject:invoice];
                }
			}
		}
	}
    
    if (arrPMItems &&[arrPMItems count] > 0) {
        for (AMInvoice *invoice in arrPMItems) {
            if ([invoice.invoiceCodeName length] != 0 && [invoice.quantity intValue] !=0)
            {
                [arrInvoiceItems addObject:invoice];
            }
        }
    }
    
    return arrInvoiceItems;
}

- (void)clickHoursWorkedBtn:(UIButton *)sender {
    
    [self.mainTableView endEditing:YES];
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_HoursWorked;
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
	for (NSInteger i = 0; i <= 8; i++) {
		[arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : [NSString stringWithFormat:@"%d", i] }];
        [arrInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : [NSString stringWithFormat:@"%.1f", i + 0.5] }];
	}
    
    [arrInfos removeLastObject];
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)clickAddPartBtn:(UIButton *)sender {
    DLog(@"clickAddPartBtn");
    
    NSMutableDictionary *dicInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
    
    if (!dicInfo) {
        return;
    }
    
    if ([arrPartItems count] >= MAX_PART_COUNT) {
        return;
    }
    
    AMInvoice *invoce = [[AMInvoice alloc] init];
    invoce.assetID = nil;
    invoce.posID = self.workOrder.posID;
    invoce.woID = self.workOrder.woID;
    invoce.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_PART forObject:RECORD_TYPE_OF_INVOICE];
    invoce.recordTypeName = INVOICE_TYPE_PART;
    
    [arrPartItems addObject:invoce];
    
    [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:dicInfo]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickAddPMBtn:(UIButton *)sender {
    DLog(@"clickAddPMBtn");
    
    NSMutableDictionary *dicInfo = [self dataWithType:AMCheckoutCellType_Checkout_PM_Item];
    
    if (!dicInfo) {
        return;
    }
    
    if ([arrPMItems count] >= MAX_PM_COUNT) {
        return;
    }
    
    AMInvoice *invoce = [[AMInvoice alloc] init];
    invoce.assetID = nil;
    invoce.posID = self.workOrder.posID;
    invoce.woID = self.workOrder.woID;
    invoce.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_INVOICECODE forObject:RECORD_TYPE_OF_INVOICE];
    invoce.recordTypeName = INVOICE_TYPE_INVOICECODE;
    invoce.invoiceCodeName = @"PM1";
    invoce.invoiceCodeId = @"01ti0000005rQyp";
    invoce.quantity = @1;
    [arrPMItems addObject:invoce];
    
    [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:dicInfo]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickAddFilterBtn:(UIButton *)sender {
	DLog(@"clickAddFilterBtn");
    
    NSMutableDictionary *dicInfo = [self dataWithType:AMCheckoutCellType_Checkout_Filter_Item];
    
    if (!dicInfo) {
        return;
    }
    
    if ([arrFilterItems count] >= MAX_FILTER_COUNT) {
        return;
    }
    
    AMInvoice *invoce = [[AMInvoice alloc] init];
    invoce.assetID = nil;
    invoce.posID = self.workOrder.posID;
    invoce.woID = self.workOrder.woID;
    invoce.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_FILTER forObject:RECORD_TYPE_OF_INVOICE];
    invoce.recordTypeName = INVOICE_TYPE_FILTER;

	[self.arrFilterItems addObject:invoce];
    
	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:dicInfo]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickAddInvoiceCodeBtn:(UIButton *)sender
{
    NSMutableDictionary *dicInfo = [self dataWithType:AMCheckoutCellType_Checkout_InvoiceCode_Item];
    
    if (!dicInfo) {
        return;
    }
    
    NSMutableDictionary *dicParts = [NSMutableDictionary dictionary];
	[self.arrCodeItems addObject:dicParts];
	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:dicInfo]] withRowAnimation:UITableViewRowAnimationNone];
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

- (void)clickFilterNameBtn:(UIButton *)sender {
    
     [self.mainTableView endEditing:YES];
    
	NSArray *arrTemp0 = [[AMLogicCore sharedInstance] getFilterListByWOID:self.workOrder.woID];
    
    if (!arrTemp0 || [arrTemp0 count] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Filter List Empty")];
		return;
	}
    
    NSInteger iRow = sender.tag % 1000;
	NSInteger iSection = (sender.tag - iRow) / 1000;
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_FilterName;
    
	DLog(@"sender.tag : %d", sender.tag);
    
	popView.aIndexPath = [NSIndexPath indexPathForRow:iRow inSection:iSection];
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
	for (AMDBCustomerPrice *customerPrice in arrTemp0) {
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

- (void)clickPartNameBtn:(UIButton *)sender {
    
     [self.mainTableView endEditing:YES];
    
	AMAsset *assetInfo = [[AMLogicCore sharedInstance] getAssetInfoByID:self.workOrder.assetID];
    
	if (!assetInfo) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Part List Empty")];
		return;
	}
    
	NSArray *arrTemp = [[AMLogicCore sharedInstance] getPartsListByProductID:assetInfo.productID];
    
	if (!arrTemp || [arrTemp count] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Part List Empty")];
		return;
	}
    
    NSInteger iRow = sender.tag % 1000;
	NSInteger iSection = (sender.tag - iRow) / 1000;
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_PartName;
    
	DLog(@"sender.tag : %d", sender.tag);
    
	popView.aIndexPath = [NSIndexPath indexPathForRow:iRow inSection:iSection];
    
	NSMutableArray *arrInfos = [NSMutableArray array];
    
	for (AMParts *aPart in arrTemp) {
		NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
		[dicInfo setObject:aPart forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
		[dicInfo setObject:aPart.name forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
		[arrInfos addObject:dicInfo];
	}
    
	popView.arrInfos = arrInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}


- (void)clickRepairCodeBtn:(UIButton *)sender {
    
     [self.mainTableView endEditing:YES];
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_RepairCode;
    
    popView.arrInfos = [self repairCodes];
    
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame) + 100, CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

//bkk 2/15/2015
- (void)showFiltersList: (UIButton *)sender {
    AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
    popView.delegate = self;
    popView.tag = PopViewType_Select_FilterType;
    
    popView.arrInfos = [self filterNames];
    
    aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
    [aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame) + 100, CGRectGetHeight(popView.view.frame))];
    aPopoverVC.delegate = self;
    [aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

#pragma mark -

- (void)setupDataSourceByWorkOrder:(AMWorkOrder *)aWorkOrder {
    
    self.mainTableView.contentOffset = CGPointMake(0, 0);
    
	if ([workOrder.woID isEqualToString:aWorkOrder.woID]) {
		return;
	}
    
    if (self.arrCheckoutInfos && [self.arrCheckoutInfos count] > 0) {
        [self.arrCheckoutInfos removeAllObjects];
    }
    else
    {
        self.arrCheckoutInfos = [NSMutableArray array];
    }
    
    if (self.arrInvoiceItems && [self.arrInvoiceItems count] > 0) {
        [self.arrInvoiceItems removeAllObjects];
    }
    else
    {
        self.arrInvoiceItems = [NSMutableArray array];
    }
    
    if (self.arrWorkItems && [self.arrWorkItems count] > 0) {
        [self.arrWorkItems removeAllObjects];
    }
    else
    {
        self.arrWorkItems = [NSMutableArray array];
    }
    
    if (self.arrCodeItems && [self.arrCodeItems count] > 0) {
        [self.arrCodeItems removeAllObjects];
    }
    else
    {
        self.arrCodeItems = [NSMutableArray array];
    }
    
    if (self.arrFilterItems && [self.arrFilterItems count] > 0) {
        [self.arrFilterItems removeAllObjects];
    }
    else
    {
        self.arrFilterItems = [NSMutableArray array];
    }
    
    if (self.arrPartItems && [self.arrPartItems count] > 0) {
        [self.arrPartItems removeAllObjects];
    }
    else
    {
        self.arrPartItems = [NSMutableArray array];
    }
    
    if (self.arrPMItems && [self.arrPMItems count] > 0) {
        [self.arrPMItems removeAllObjects];
    }
    else
    {
        self.arrPMItems = [NSMutableArray array];
    }
    
	self.workOrder = aWorkOrder;
    
    arrCodePriceList = [NSMutableArray arrayWithArray:[[AMLogicCore sharedInstance] getInvoiceCodeListByWOID:self.workOrder.woID]];
    
    if ([arrFilterItems count] == 0 && [self.workOrder.woType isEqualToString:TEXT_OF_FILTER_EXCHANGE]) {
        
        NSArray *arrTemp0 = [[AMLogicCore sharedInstance] getFilterListByWOID:self.workOrder.woID];
        
        if ([arrTemp0 count] > 0)
        {
            AMInvoice *invoce = [[AMInvoice alloc] init];
            invoce.assetID = nil;
            invoce.posID = self.workOrder.posID;
            invoce.woID = self.workOrder.woID;
            invoce.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_FILTER forObject:RECORD_TYPE_OF_INVOICE];
            invoce.recordTypeName = INVOICE_TYPE_FILTER;
            
            for (AMDBCustomerPrice *customerPrice in arrTemp0) {
                
                if([self.workOrder.filterType isEqualToString:customerPrice.productID])
                {
                    invoce.filterID = customerPrice.productID;
                    invoce.filterName = customerPrice.productName;
                    invoce.unitPrice = customerPrice.price;
                    invoce.quantity = self.workOrder.filterCount;
                    
                    [arrFilterItems addObject:invoce];
                    break;
                }
            }
            
        }
    }

	NSMutableDictionary *dicWO = [NSMutableDictionary dictionary];
	[dicWO setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_RepairCode] forKey:KEY_OF_CELL_TYPE];
	[dicWO setObject:[NSString stringWithFormat:@"%@", [aWorkOrder.repairCode length] == 0 ? @"":aWorkOrder.repairCode] forKey:KEY_OF_REPAIR_CODE];
    
    [self enableCreateNewBtn:[[dicWO objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:TEXT_OF_CREATE] || [[dicWO objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:TEXT_OF_NEED_PARTS]];
    
    NSMutableDictionary *dicWoT = [NSMutableDictionary dictionary];
    [dicWoT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_RepairCode] forKey:KEY_OF_CELL_TYPE];
    [dicWoT setObject:dicWO forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicWoT];
    
    //
	NSMutableDictionary *dicWONotes = [NSMutableDictionary dictionary];
	[dicWONotes setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_WorkOrderNotes] forKey:KEY_OF_CELL_TYPE];
	[dicWONotes setObject:[NSString stringWithFormat:@"%@", [aWorkOrder.notes length] == 0 ? @"":aWorkOrder.notes] forKey:KEY_OF_WORKORDER_NOTES];
    
    NSMutableDictionary *dicWONotesT = [NSMutableDictionary dictionary];
    [dicWONotesT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_WorkOrderNotes] forKey:KEY_OF_CELL_TYPE];
    [dicWONotesT setObject:dicWONotes forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicWONotesT];
    
     NSMutableDictionary *dicWorkPerformed = [NSMutableDictionary dictionary];
    
    [dicWorkPerformed setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_WorkPerformed] forKey:KEY_OF_CELL_TYPE];
    [dicWorkPerformed setObject:[NSString stringWithFormat:@"%@", [aWorkOrder.woType length] == 0 ? @"":aWorkOrder.woType] forKey:KEY_OF_WORK_PERFORMED];
    [dicWorkPerformed setObject:@""  forKey:KEY_OF_HOURS_WORKED];
    [dicWorkPerformed setObject:@"" forKey:KEY_OF_HOURS_RATE];
    
    NSMutableDictionary *dicWorkPerformedT = [NSMutableDictionary dictionary];
    [dicWorkPerformedT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_WorkPerformed] forKey:KEY_OF_CELL_TYPE];
    [dicWorkPerformedT setObject:dicWorkPerformed forKey:KEY_OF_CELL_DATA];
    
    [self.arrCheckoutInfos addObject:dicWorkPerformedT];
    
	//
    NSMutableDictionary *dicInvoiceCodeItemT = [NSMutableDictionary dictionary];
    [dicInvoiceCodeItemT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_InvoiceCode_Item] forKey:KEY_OF_CELL_TYPE];
    [dicInvoiceCodeItemT setObject:arrCodeItems forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicInvoiceCodeItemT];
    
	//
	NSMutableDictionary *dicFilters = [NSMutableDictionary dictionary];
	[dicFilters setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_Filter_Title] forKey:KEY_OF_CELL_TYPE];
	[dicFilters setObject:[NSString stringWithFormat:@"%@:",MyLocal(@"FILTERS")] forKey:KEY_OF_ADD_HEAD_TITLE];
	[dicFilters setObject:MyLocal(@"Filter") forKey:KEY_OF_ADD_HEAD_INFO];
    
    NSMutableDictionary *dicFiltersT = [NSMutableDictionary dictionary];
    [dicFiltersT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_Filter_Title] forKey:KEY_OF_CELL_TYPE];
    [dicFiltersT setObject:dicFilters forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicFiltersT];
    
	//
    NSMutableDictionary *dicFilterItemT = [NSMutableDictionary dictionary];
    [dicFilterItemT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_Filter_Item] forKey:KEY_OF_CELL_TYPE];
    [dicFilterItemT setObject:arrFilterItems forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicFilterItemT];
    
	//
	NSMutableDictionary *dicParts = [NSMutableDictionary dictionary];
	[dicParts setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_Part_Title] forKey:KEY_OF_CELL_TYPE];
	[dicParts setObject:[NSString stringWithFormat:@"%@:",MyLocal(@"PARTS")] forKey:KEY_OF_ADD_HEAD_TITLE];
	[dicParts setObject:MyLocal(@"Parts") forKey:KEY_OF_ADD_HEAD_INFO];
    
    NSMutableDictionary *dicPartsT = [NSMutableDictionary dictionary];
    [dicPartsT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_Part_Title] forKey:KEY_OF_CELL_TYPE];
    [dicPartsT setObject:dicParts forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicPartsT];
    
	//
    NSMutableDictionary *dicPartItemT = [NSMutableDictionary dictionary];
    [dicPartItemT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_Part_Item] forKey:KEY_OF_CELL_TYPE];
    [dicPartItemT setObject:arrPartItems forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicPartItemT];
    
    //BKK 20170203 - added below for I&E for PMs
    //
    NSMutableDictionary *dicPMs = [NSMutableDictionary dictionary];
    [dicPMs setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_PM_Title] forKey:KEY_OF_CELL_TYPE];
    [dicPMs setObject:[NSString stringWithFormat:@"%@:",MyLocal(@"Preventative Maintenance")] forKey:KEY_OF_ADD_HEAD_TITLE];
    [dicPMs setObject:MyLocal(@"PMs") forKey:KEY_OF_ADD_HEAD_INFO];
    
    NSMutableDictionary *dicPMsT = [NSMutableDictionary dictionary];
    [dicPMsT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_PM_Title] forKey:KEY_OF_CELL_TYPE];
    [dicPMsT setObject:dicPMs forKey:KEY_OF_CELL_DATA];
    
    [self.arrCheckoutInfos addObject:dicPMsT];
    
    //
    NSMutableDictionary *dicPMItemT = [NSMutableDictionary dictionary];
    [dicPMItemT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_PM_Item] forKey:KEY_OF_CELL_TYPE];
    [dicPMItemT setObject:arrPMItems forKey:KEY_OF_CELL_DATA];
    
    [self.arrCheckoutInfos addObject:dicPMItemT];
    
    
    
    [self.mainTableView reloadData];
    
	[self refreshTotalPrice];
}

#pragma mark -

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	id checkoutItem = [self.arrCheckoutInfos objectAtIndex:indexPath.section];
    
	switch ([[checkoutItem objectForKey:KEY_OF_CELL_TYPE] integerValue]) {
		case AMCheckoutCellType_Checkout_RepairCode :
        {
            AMRepairTableViewCell *cell = (AMRepairTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMRepairTableViewCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMRepairTableViewCell" owner:[AMRepairTableViewCell class] options:nil];
                cell = (AMRepairTableViewCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
            cell.labelRepairCode.text = [[dicInfo objectForKey:KEY_OF_REPAIR_CODE] length] == 0 ? @"" : MyLocal([dicInfo objectForKey:KEY_OF_REPAIR_CODE]);
            [cell.btnRepairCode addTarget:self action:@selector(clickRepairCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
            
		case AMCheckoutCellType_Checkout_WorkOrderNotes :
        {
            AMWorkOrderNotesTableViewCell *cell = (AMWorkOrderNotesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMWorkOrderNotesTableViewCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMWorkOrderNotesTableViewCell" owner:[AMWorkOrderNotesTableViewCell class] options:nil];
                cell = (AMWorkOrderNotesTableViewCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
            [cell refreshData:dicInfo];
            cell.textViewWorkOrderNotes.tag = TextInputType_WorkOrderNotes;
            cell.textViewWorkOrderNotes.delegate = self;
            
            return cell;
        }
            
		case AMCheckoutCellType_Checkout_WorkPerformed :
        case AMCheckoutCellType_Checkout_Maintenance :
        {
            AMWorkPerformedTableViewCell *cell = (AMWorkPerformedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMWorkPerformedTableViewCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMWorkPerformedTableViewCell" owner:[AMWorkPerformedTableViewCell class] options:nil];
                cell = (AMWorkPerformedTableViewCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
            cell.textFieldHoursRate.delegate = self;
            cell.textFieldHoursRate.tag = (indexPath.section * 1000 + TextInputType_HoursRate);
            [cell refreshData:dicInfo];
            [cell.btnHoursWorked addTarget:self action:@selector(clickHoursWorkedBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
            
        case AMCheckoutCellType_Checkout_InvoiceCode_Title:
		{
			AMTitleWithAddTableViewCell *cell = (AMTitleWithAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMTitleWithAddTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMTitleWithAddTableViewCell" owner:[AMTitleWithAddTableViewCell class] options:nil];
				cell = (AMTitleWithAddTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
			[cell.btnAdd addTarget:self action:@selector(clickAddInvoiceCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
			[cell refreshData:dicInfo];
            
			return cell;
		}
            
		case AMCheckoutCellType_Checkout_InvoiceCode_Item:
		{
			AMInvoiceCodeTableViewCell *cell = (AMInvoiceCodeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMInvoiceCodeTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMInvoiceCodeTableViewCell" owner:[AMInvoiceCodeTableViewCell class] options:nil];
				cell = (AMInvoiceCodeTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			AMDBCustomerPrice *customerPrice = [[arrCodeItems objectAtIndex:indexPath.row] objectForKey:KEY_OF_CUSTOMER_PRICE];
			cell.textFieldInvoiceCode.text = [customerPrice.productName length] == 0 ? TEXT_OF_NULL : customerPrice.productName;
            cell.textFieldPrice.text = customerPrice.price ? [customerPrice.price stringValue] : TEXT_OF_NULL;
            
			[cell.btnInvoiceCode addTarget:self action:@selector(clickInvoiceCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnInvoiceCode.tag =  (indexPath.section * 1000 + indexPath.row);
			cell.btnInvoiceCode.tag = indexPath.row;
            
			return cell;
		}
            
		case AMCheckoutCellType_Checkout_Filter_Title:
		{
			AMTitleWithAddTableViewCell *cell = (AMTitleWithAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMTitleWithAddTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMTitleWithAddTableViewCell" owner:[AMTitleWithAddTableViewCell class] options:nil];
				cell = (AMTitleWithAddTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
            
			[cell.btnAdd addTarget:self action:@selector(clickAddFilterBtn:) forControlEvents:UIControlEventTouchUpInside];
			[cell refreshData:dicInfo];
            
			return cell;
		}
            
		case AMCheckoutCellType_Checkout_Filter_Item:
		{
			AMFilterNameTableViewCell *cell = (AMFilterNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMFilterNameTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMFilterNameTableViewCell" owner:[AMFilterNameTableViewCell class] options:nil];
				cell = (AMFilterNameTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			AMInvoice *invoice = [arrFilterItems objectAtIndex:indexPath.row];
			cell.textFieldFilterName.text = [invoice.filterName length] == 0 ? TEXT_OF_NULL : invoice.filterName;
//            cell.textFieldFilterPrice.text = invoice.unitPrice ? [invoice.unitPrice stringValue] : TEXT_OF_NULL;
            cell.textFieldFilterPrice.text = invoice.unitPrice ? [NSString stringWithFormat:@"%.02f", [invoice.unitPrice floatValue]] : TEXT_OF_NULL;
			cell.textFieldQuantity.text = invoice.quantity ? [invoice.quantity stringValue] : TEXT_OF_NULL;
            
			[cell.btnFilterName addTarget:self action:@selector(clickFilterNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnFilterName.tag =  (indexPath.section * 1000 + indexPath.row);
			cell.btnFilterName.tag = indexPath.row;
            
			cell.textFieldQuantity.delegate = self;
			cell.textFieldQuantity.tag = (indexPath.row * 1000 + TextInputType_FilterQuantity);
            
			return cell;
		}
            
		case AMCheckoutCellType_Checkout_Part_Title:
		{
			AMTitleWithAddTableViewCell *cell = (AMTitleWithAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMTitleWithAddTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMTitleWithAddTableViewCell" owner:[AMTitleWithAddTableViewCell class] options:nil];
				cell = (AMTitleWithAddTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
			[cell.btnAdd addTarget:self action:@selector(clickAddPartBtn:) forControlEvents:UIControlEventTouchUpInside];
			[cell refreshData:dicInfo];
            
			return cell;
		}
            
		case AMCheckoutCellType_Checkout_Part_Item:
		{
			AMPartNameTableViewCell *cell = (AMPartNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMPartNameTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMPartNameTableViewCell" owner:[AMPartNameTableViewCell class] options:nil];
				cell = (AMPartNameTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            AMInvoice *invoice = [arrPartItems objectAtIndex:indexPath.row];
            
			cell.textFieldQuantity.delegate = self;
			cell.textFieldQuantity.tag = (indexPath.row * 1000 + TextInputType_PartQuantity);
            
			cell.textFieldPartsName.text = [invoice.partsName length] == 0 ? TEXT_OF_NULL : invoice.partsName;
			cell.textFieldQuantity.text = invoice.quantity ? [invoice.quantity stringValue] : TEXT_OF_NULL;
            
			[cell.btnPartsName addTarget:self action:@selector(clickPartNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnPartsName.tag =  (indexPath.section * 1000 + indexPath.row);
			cell.btnPartsName.tag = indexPath.row;
            
			return cell;
		}
            

        case AMCheckoutCellType_Checkout_PM_Title:
        {
            AMTitleWithAddTableViewCell *cell = (AMTitleWithAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMTitleWithAddTableViewCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMTitleWithAddTableViewCell" owner:[AMTitleWithAddTableViewCell class] options:nil];
                cell = (AMTitleWithAddTableViewCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
            [cell.btnAdd addTarget:self action:@selector(clickAddPMBtn:) forControlEvents:UIControlEventTouchUpInside];
            [cell refreshData:dicInfo];
            
            return cell;
        }
        
        //BKKITEM-000462 - 20170202 - Add Preventative Mantenance section
        case AMCheckoutCellType_Checkout_PM_Item:
        {
            AMPMNameTableViewCell *cell = (AMPMNameTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMPMNameTableViewCell"];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMPMNameTableViewCell" owner:[AMPMNameTableViewCell class] options:nil];
                cell = (AMPMNameTableViewCell *)[nib objectAtIndex:0];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            AMInvoice *invoice = [arrPMItems objectAtIndex:indexPath.row];
            
            //cell.textFieldQuantity.delegate = self;
            //cell.textFieldQuantity.tag = (indexPath.row * 1000 + TextInputType_PartQuantity);
            
            cell.textFieldPartsName.text = @"PM1";
            cell.textFieldQuantity.text = @"1";
            
            //[cell.btnPMName addTarget:self action:@selector(clickPMNameBtn:) forControlEvents:UIControlEventTouchUpInside];
            //cell.btnPMName.tag =  (indexPath.section * 1000 + indexPath.row);
            //cell.btnPMName.tag = indexPath.row;
            
            return cell;
        }
            
            
            
	}
    
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dicFilterItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Filter_Item];
    NSMutableDictionary *dicPartItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
    NSMutableDictionary *dicCodesItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_InvoiceCode_Item];
    NSMutableDictionary *dicCodesPMInfo = [self dataWithType:AMCheckoutCellType_Checkout_PM_Item];
    
    if (indexPath.section == [arrCheckoutInfos indexOfObject:dicFilterItemInfo]
        || indexPath.section == [arrCheckoutInfos indexOfObject:dicPartItemInfo]
        || indexPath.section == [arrCheckoutInfos indexOfObject:dicCodesItemInfo]
        || indexPath.section == [arrCheckoutInfos indexOfObject:dicCodesPMInfo]) {
        return  TRUE;
    }
    
    return FALSE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数
{
    NSMutableDictionary *dicFilterItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Filter_Item];
    NSMutableDictionary *dicPartItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
    NSMutableDictionary *dicCodesItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_InvoiceCode_Item];
    NSMutableDictionary *dicCodesPMInfo = [self dataWithType:AMCheckoutCellType_Checkout_PM_Item];
    
    if (indexPath.section == [arrCheckoutInfos indexOfObject:dicFilterItemInfo]
        || indexPath.section == [arrCheckoutInfos indexOfObject:dicPartItemInfo]
        || indexPath.section == [arrCheckoutInfos indexOfObject:dicCodesItemInfo]
        || indexPath.section == [arrCheckoutInfos indexOfObject:dicCodesPMInfo]) {
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
        NSMutableDictionary *dicCodeItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_InvoiceCode_Item];
        NSMutableDictionary *dicFilterItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Filter_Item];
        NSMutableDictionary *dicPartItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
        NSMutableDictionary *dicCodesPMInfo = [self dataWithType:AMCheckoutCellType_Checkout_PM_Item];
       
        if (indexPath.section == [arrCheckoutInfos indexOfObject:dicFilterItemInfo]) {
            
            AMInvoice *invoice = [arrFilterItems objectAtIndex:indexPath.row];
            
            if (invoice.invoiceID) {
                [[AMLogicCore sharedInstance] deleteInvoiceById:invoice.invoiceID completion:^(NSInteger type, NSError *error) {
                    if (error) {
                        [AMUtilities showAlertWithInfo:[error localizedDescription]];
                        return ;
                    }
                    else{
                        [arrInvoiceItems removeObject:[arrFilterItems objectAtIndex:indexPath.row]];
                        [arrFilterItems removeObjectAtIndex:indexPath.row];
                        
                        MAIN(^{
                            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                            [self refreshTotalPrice];
                        });
                    }
                }];
            }
            else
            {
                [arrInvoiceItems removeObject:[arrFilterItems objectAtIndex:indexPath.row]];
                [arrFilterItems removeObjectAtIndex:indexPath.row];
                MAIN(^{
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    [self refreshTotalPrice];
                });
            }
        }
        else if(indexPath.section == [arrCheckoutInfos indexOfObject:dicPartItemInfo]){
            
            AMInvoice *invoice = [arrPartItems objectAtIndex:indexPath.row];
            
            if (invoice.invoiceID) {
            [[AMLogicCore sharedInstance] deleteInvoiceById:invoice.invoiceID completion:^(NSInteger type, NSError *error) {
                if (error) {
                    [AMUtilities showAlertWithInfo:[error localizedDescription]];
                    return ;
                }
                else{
                    [arrInvoiceItems removeObject:[arrPartItems objectAtIndex:indexPath.row]];
                    [arrPartItems removeObjectAtIndex:indexPath.row];
                    MAIN(^{
                        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                        [self refreshTotalPrice];
                    });
                }
            }];
            }
            else
            {
                [arrInvoiceItems removeObject:[arrPartItems objectAtIndex:indexPath.row]];
                [arrPartItems removeObjectAtIndex:indexPath.row];
                MAIN(^{
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
                    [self refreshTotalPrice];
                });
            }
        }
        else if(indexPath.section == [arrCheckoutInfos indexOfObject:dicCodeItemInfo])
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
        else if(indexPath.section == [arrCheckoutInfos indexOfObject:dicCodesPMInfo])
        {
            //BKK 20170202- TODO: PM change 000462
            [arrPMItems removeAllObjects];
            MAIN(^{
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            });
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id checkoutItem = [self.arrCheckoutInfos objectAtIndex:section];
    
	switch ([[checkoutItem objectForKey:KEY_OF_CELL_TYPE] integerValue]) {
		case AMCheckoutCellType_Checkout_RepairCode :
        case AMCheckoutCellType_Checkout_WorkOrderNotes :
        case AMCheckoutCellType_Checkout_WorkPerformed :
        case AMCheckoutCellType_Checkout_Maintenance :
        case AMCheckoutCellType_Checkout_Filter_Title:
        case AMCheckoutCellType_Checkout_Part_Title:
        case AMCheckoutCellType_Checkout_InvoiceCode_Title:
        case AMCheckoutCellType_Checkout_PM_Title:
		{
			return 1;
		}
            break;
        case AMCheckoutCellType_Checkout_InvoiceCode_Item:
        {
            return [arrCodeItems count];
        }
            break;
		case AMCheckoutCellType_Checkout_Filter_Item:
        {
            return [arrFilterItems count];
        }
            break;
		case AMCheckoutCellType_Checkout_Part_Item:
		{
			return [arrPartItems count];
		}
            break;
        case AMCheckoutCellType_Checkout_PM_Item:
        {
            return [arrPMItems count];
        }
            break;
	}
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.arrCheckoutInfos count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	switch (indexPath.section) {
		case 1:
		{
			return 178.0;
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
	UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 1.0)];
	return aView;
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
    
	switch (textView.tag) {
		case TextInputType_WorkOrderNotes:
		{
			id checkoutItem = [self dataWithType:AMCheckoutCellType_Checkout_WorkOrderNotes];
			NSMutableDictionary *dicInfo = [checkoutItem objectForKey:KEY_OF_CELL_DATA];
			[dicInfo setObject:textView.text forKey:KEY_OF_WORKORDER_NOTES];
			[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:checkoutItem]] withRowAnimation:UITableViewRowAnimationNone];
		}
            break;
            
		default:
			break;
	}
}

#pragma mark -

#define myDotNumbers        @"0123456789.\n"
#define myNumbers           @"0123456789\n"

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSInteger iType = textField.tag % 1000;
    
	switch (iType) {
		case TextInputType_MaintenanceFee:
		case TextInputType_FilterQuantity:
		case TextInputType_PartQuantity:
		{
            if ([string isEqualToString:@"\n"]||[string isEqualToString:@""]) {//按下return
                return YES;
            }
            
            NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers]invertedSet];
            if ([string isEqualToString:@"."]) {
                return NO;
            }
            if (textField.text.length >= 3) {
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
    
	NSInteger iType = textField.tag % 1000;
    NSInteger iRow = (textField.tag - iType) / 1000;
    
	if (TextInputType_HoursRate == iType) {
        
        NSMutableDictionary *dicInfo = [[self dataWithType:AMCheckoutCellType_Checkout_WorkPerformed] objectForKey:KEY_OF_CELL_DATA];
        
		if ([[dicInfo objectForKey:KEY_OF_HOURS_WORKED] length] == 0) {
			return NO;
		}
		else {
			return YES;
		}
	}
    else if (TextInputType_FilterQuantity == iType)
    {
        AMInvoice *invoice = [arrFilterItems objectAtIndex:iRow];
        
        if ([invoice.filterName length] == 0) {
			return NO;
		}
		else {
			return YES;
		}
    }
    else if(TextInputType_PartQuantity == iType)
    {
        AMInvoice *invoice = [arrPartItems objectAtIndex:iRow];
        
        if ([invoice.partsName length] == 0) {
			return NO;
		}
		else {
			return YES;
		}
    }
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self scrollTableViewCell:textField];
    
	if ([textField.text isEqualToString:TEXT_OF_NULL] || [textField.text intValue] == 0) {
		textField.text = @"";
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
	if ([AMUtilities isEmpty:textField.text]) {
		textField.text = TEXT_OF_NULL;
	}
    
	NSInteger iType = textField.tag % 1000;
	NSInteger iIndex = (textField.tag - iType) / 1000;
    
	switch (iType) {
		case TextInputType_HoursRate:
		{
             NSMutableDictionary *dicInfo = [[self dataWithType:AMCheckoutCellType_Checkout_WorkPerformed] objectForKey:KEY_OF_CELL_DATA];
            [dicInfo setObject:[textField.text isEqualToString:TEXT_OF_NULL] ? @"" : textField.text forKey:KEY_OF_HOURS_RATE];
		}
            break;
            
		case TextInputType_MaintenanceFee:
		{
             NSMutableDictionary *dicInfo = [[self dataWithType:AMCheckoutCellType_Checkout_Maintenance] objectForKey:KEY_OF_CELL_DATA];
            [dicInfo setObject:[textField.text isEqualToString:TEXT_OF_NULL] ? @"" : textField.text forKey:KEY_OF_MAINTENANCE_FEE];
		}
            break;
            
		case TextInputType_FilterQuantity:
		{
            AMInvoice *invoice = [arrFilterItems objectAtIndex:iIndex];
            invoice.quantity = [textField.text isEqualToString:TEXT_OF_NULL] ? @1 : [NSNumber numberWithFloat:[textField.text floatValue]];
		}
            break;
            
		case TextInputType_PartQuantity:
		{
            AMInvoice *invoice = [arrPartItems objectAtIndex:iIndex];
            invoice.quantity = [textField.text isEqualToString:TEXT_OF_NULL] ? @1 : [NSNumber numberWithFloat:[textField.text floatValue]];
		}
            break;
	}
    
	[self refreshTotalPrice];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
	return YES;
}

#pragma mark -

- (void)scrollTableViewCell:(UITextField *)textField {
	NSIndexPath *indexPath = [AMUtilities indexPathForView:textField inTableView:self.mainTableView];
	[self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
    if (aVerificationStatusTableViewController.tag == PopViewType_Select_RepairCode) {
        
        //TODO::Enhancement140929
        NSString *strRepairCode0 = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
        NSMutableDictionary *dicInfo = [[self dataWithType:AMCheckoutCellType_Checkout_RepairCode] objectForKey:KEY_OF_CELL_DATA];
        [dicInfo setObject:strRepairCode0 forKey:KEY_OF_REPAIR_CODE];
        
        [self enableCreateNewBtn:[[dicInfo objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:TEXT_OF_CREATE] || [[dicInfo objectForKey:KEY_OF_REPAIR_CODE] isEqualToString:TEXT_OF_NEED_PARTS]];
        
        [aPopoverVC dismissPopoverAnimated:YES];
        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:[self dataWithType:AMCheckoutCellType_Checkout_RepairCode]]] withRowAnimation:UITableViewRowAnimationNone];
    }
	else if (aVerificationStatusTableViewController.tag == PopViewType_Select_HoursWorked) {
        
        NSMutableDictionary *dicInfo = [[self dataWithType:AMCheckoutCellType_Checkout_WorkPerformed] objectForKey:KEY_OF_CELL_DATA];
        
		NSString *strWorkHours = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
        
		[dicInfo setObject:strWorkHours forKey:KEY_OF_HOURS_WORKED];
		if ([[dicInfo objectForKey:KEY_OF_HOURS_RATE] length] == 0) {
            NSNumber *rate = [[AMLogicCore sharedInstance] getOwnHourRates];
			NSString *strRate = rate ? [rate stringValue] : @"0";
			[dicInfo setObject:strRate forKey:KEY_OF_HOURS_RATE];
		}
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
		[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:[self dataWithType:AMCheckoutCellType_Checkout_WorkPerformed]]] withRowAnimation:UITableViewRowAnimationNone];
        
		[self refreshTotalPrice];
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_Select_FilterName) {
        
        AMDBCustomerPrice *customerPrice = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
		AMInvoice *invoice = [arrFilterItems objectAtIndex:aVerificationStatusTableViewController.aIndexPath.row];
        invoice.filterID = customerPrice.productID;
        invoice.filterName = customerPrice.productName;
        invoice.unitPrice = customerPrice.price;
        invoice.quantity = @1;
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
		[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:[self dataWithType:AMCheckoutCellType_Checkout_Filter_Item]]] withRowAnimation:UITableViewRowAnimationNone];
        [self refreshTotalPrice];//TODO::Enhancement140929
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_Select_PartName) {
        
        AMParts *part = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
		AMInvoice *invoice = [arrPartItems objectAtIndex:aVerificationStatusTableViewController.aIndexPath.row];
        invoice.partsID = part.partID;
        invoice.partsName = part.name;
        invoice.quantity = @1;
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
		[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:[self dataWithType:AMCheckoutCellType_Checkout_Part_Item]]] withRowAnimation:UITableViewRowAnimationNone];
	}
    else if (aVerificationStatusTableViewController.tag == PopViewType_Select_InvoiceCode) {
        AMDBCustomerPrice *customerPrice = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        [[arrCodeItems objectAtIndex:aVerificationStatusTableViewController.aIndexPath.row] setObject:customerPrice forKey:KEY_OF_CUSTOMER_PRICE];
        [arrCodePriceList removeObject:customerPrice];
        
		NSLog(@"didSelected : %@", aInfo);
		[aPopoverVC dismissPopoverAnimated:YES];
		[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:[self dataWithType:AMCheckoutCellType_Checkout_InvoiceCode_Item]]] withRowAnimation:UITableViewRowAnimationNone];
        
        [self refreshTotalPrice];
	}
    else if (aVerificationStatusTableViewController.tag == PopViewType_Select_FilterType) {
        //bkk 2/5/15
        [aPopoverVC dismissPopoverAnimated:YES];
        [self.selectFilterButton setTitle:[aInfo objectForKey:@"VALUE"] forState:UIControlStateNormal];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Filter_Item_Changed" object:self userInfo:aInfo];

        NSLog(@"%@", aInfo);
    }
}

- (void)refreshTotalPrice {
    
	CGFloat fTotalPrice = 0.0;
    
    for (NSMutableDictionary *dicInfo in self.arrCheckoutInfos) {
        
        NSInteger iType = [[dicInfo objectForKey:KEY_OF_CELL_TYPE] integerValue];
        id date = [dicInfo objectForKey:KEY_OF_CELL_DATA];
        
        switch (iType) {
            case AMCheckoutCellType_Checkout_WorkPerformed:
            {
                float fHours = [[date objectForKey:KEY_OF_HOURS_WORKED] floatValue];
                float fRate = [[date objectForKey:KEY_OF_HOURS_RATE] floatValue];
                
                fTotalPrice += fHours * fRate;
            }
                break;
            case AMCheckoutCellType_Checkout_Maintenance:
            {
                float fFee = [[date objectForKey:KEY_OF_MAINTENANCE_FEE] floatValue];
                fTotalPrice += fFee;
            }
                break;
            case AMCheckoutCellType_Checkout_Filter_Item:
            {
                    for (AMInvoice *invoice in arrFilterItems) {
                        if ([invoice.filterName length] != 0) {
                            fTotalPrice += [invoice.unitPrice floatValue] * [invoice.quantity floatValue];
                        }
                    }
            }
                break;
            case AMCheckoutCellType_Checkout_InvoiceCode_Item:
            {
                for (NSMutableDictionary *dicCInfo in arrCodeItems) {
                    AMDBCustomerPrice *customerPrice = [dicCInfo objectForKey:KEY_OF_CUSTOMER_PRICE];
                    if (customerPrice.price) {
                        fTotalPrice += [customerPrice.price floatValue];
                    }
                }
            }
                break;
        }
    }
    
    self.labelPrice.text = [NSString stringWithFormat:@"%.2f", fTotalPrice];
}

- (void)newWorkOrderButtonTapped {
    AMWorkOrderViewController *woVC = [[AMWorkOrderViewController alloc] initWithNewWorkOrder:self.workOrder];
    woVC.delegate = self;
    woVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:woVC animated:YES completion:nil];
}

#pragma mark -

- (id)dataWithType:(AMCheckoutCellType)aType
{
    NSMutableDictionary *dicInfo = nil;
    
	for (NSMutableDictionary *dicinfos in self.arrCheckoutInfos) {
        if ([[dicinfos objectForKey:KEY_OF_CELL_TYPE] intValue] == aType) {
            dicInfo = dicinfos;
            break;
        }
    }
    
    return dicInfo;
}

#pragma mark -

-(void)enableCreateNewBtn:(BOOL)enable
{
    self.btnCreateNew.enabled = enable;
    self.btnNext.enabled = !enable;
    
    if (enable) {
        [self.btnCreateNew setBackgroundColor:COLOR_BLUE];
        [self.btnNext setBackgroundColor:COLOR_GRAY];
    }
    else
    {
        [self.btnCreateNew setBackgroundColor:COLOR_GRAY];
         [self.btnNext setBackgroundColor:COLOR_DEEP_GREEN];
    }
}

#pragma mark -

- (void)didSaveNewWorkOrder:(BOOL)success
{
    NSMutableDictionary *dicRepairCode = [[self dataWithType:AMCheckoutCellType_Checkout_RepairCode] objectForKey:KEY_OF_CELL_DATA];
    self.strRepairCode = [dicRepairCode objectForKey:KEY_OF_REPAIR_CODE];
	NSMutableDictionary *dicNots = [[self dataWithType:AMCheckoutCellType_Checkout_WorkOrderNotes] objectForKey:KEY_OF_CELL_DATA];
	self.strNotes = [dicNots objectForKey:KEY_OF_WORKORDER_NOTES];
    
    [self invoiceListWithCurrentData];
    
    if (delegate && [delegate respondsToSelector:@selector(didClickCheckoutViewControllerNextBtn)]) {
        [delegate didClickCheckoutViewControllerCreatNewBtn];
    }
}

#pragma mark - Private
- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag {
    
    NSArray* listForField = nil;
    if (tag == FieldTagHorizontalLayout) {
        listForField = _horizontalLayouts;
        
    } else if (tag == FieldTagVerticalLayout) {
        listForField = _verticalLayouts;
        
    } else if (tag == FieldTagMaskType) {
        listForField = _maskTypes;
        
    } else if (tag == FieldTagShowType) {
        listForField = _showTypes;
        
    } else if (tag == FieldTagDismissType) {
        listForField = _dismissTypes;
    }
    
    // If row is out of bounds, try using first row.
    if (row >= listForField.count) {
        row = 0;
    }
    
    if (row < listForField.count) {
        id obj = [listForField objectAtIndex:row];
        if ([obj isKindOfClass:[NSNumber class]]) {
            return [(NSNumber*)obj integerValue];
        }
    }
    
    return 0;
}

- (void)saveButtonPressed:(NSNotification *) notification {
    
    
    [KLCPopup dismissAllPopups];
    [[AMLogicCore sharedInstance] createNewCaseInDBWithSetupBlock:^(AMDBNewCase *newCase) {
        
        AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:self.workOrder.posID];
        
        if (self.workOrder.accountID && self.workOrder.posID) {
            NSArray *arrAsset = [[AMLogicCore sharedInstance] getAssetListByPoSID:self.workOrder.posID AccountID:self.workOrder.accountID];
            
            for (AMAsset *aAsset in arrAsset) {
                NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
                [dicInfo setObject:[NSString stringWithFormat:@"%@%@%@", aAsset.machineNumber ? aAsset.machineNumber : @"", aAsset.machineNumber && aAsset.productName ? @"-" : @"", aAsset.productName ? aAsset.productName : @""] forKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
                [dicInfo setObject:aAsset forKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
            }
        }
        
        NSArray *arrContact = [[AMLogicCore sharedInstance] getContactListByPoSID:self.workOrder.posID];
        
        newCase.accountID = self.workOrder.accountID;
        newCase.assetID = self.workOrder.assetID;
        
        //All filters this trip
        NSMutableArray *myArray = [NSMutableArray arrayWithArray:[notification.userInfo objectForKey:@"POST_FILTERS_AND_QUANTITIES"]];
        NSMutableString *tempString = [NSMutableString string];
        for (int i = 0; i < myArray.count; i++) {
            NSString *str = [NSString stringWithFormat:@"Filter: %@ Qty: %@\n", [myArray[i] objectForKey:@"NAME"], [myArray[i] objectForKey:@"QTY"]];
            [tempString appendString: str];
        }
        self.strSelectedFilters = [NSString stringWithString:tempString];
        
        //date time
        NSDate *now = [[NSDate alloc] init];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-YYYY HH:mm:ss"];
        NSString *todaysDate = [dateFormatter stringFromDate:now];
        
        newCase.caseDescription = [NSString stringWithFormat:@"%@\n\n Please perform the following action on the off schedule filter exchange:\n\n1 - Manually bill this customer (look for account X if needed) for:\n%@\n2 - Update the Service Schedule fields:\nPrevious Scheduled Date - <%@>\nNext Scheduled Date - <%@ + Schedule>", self.workOrder.woNumber, tempString, todaysDate, todaysDate];
        newCase.contactEmail = [arrContact count] > 0 ? ((AMContact *)arrContact[0]).email : @"";
        newCase.contactID = @"";
        NSArray *strFirstAndLastNames = [self.workOrder.ownerName componentsSeparatedByString:@" "];
        
        newCase.firstName = [arrContact count] > 0 ? ((AMContact *)arrContact[0]).firstName : strFirstAndLastNames[0] != nil ? strFirstAndLastNames[0] : @"Change";
        newCase.lastName = [arrContact count] > 0 ? ((AMContact *)arrContact[0]).lastName : strFirstAndLastNames[1] != nil ? strFirstAndLastNames[1] : @"Me";
        newCase.mEI_Customer = [pos.meiNumber length] == 0 ? 0 : pos.meiNumber;
        newCase.point_of_Service = self.workOrder.posID;
        newCase.priority = @"Medium";
        newCase.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:@"AR and Invoice" forObject:RECORD_TYPE_OF_CASE];
        newCase.recordTypeName = MyLocal(@"AR and Invoice");
        newCase.serialNumber = @"";
        newCase.subject = @"Need to Invoice and Update Service Schedule";
        newCase.type = MyLocal(@"InvoiceFilter");
        newCase.accountName = self.workOrder.accountName;
        newCase.posID = self.workOrder.posID;
        newCase.posName = [pos.name length] == 0 ? @"" : pos.name;
        newCase.assetNumber = @"";
        newCase.id = @"";
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
                                  [self showSubmit];
                              }
                         }];
            }
            
        });
    }];
}

- (IBAction)valueChanged:(UIStepper *)sender {
    double value = ((UIStepper *)sender).value;
    
    [lblQty setText:[NSString stringWithFormat:@"%d", (int)value]];
}
@end
