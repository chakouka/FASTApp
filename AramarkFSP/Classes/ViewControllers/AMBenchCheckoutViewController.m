//
//  AMBenchCheckoutViewController.m
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

#import "AMBenchCheckoutViewController.h"
#import "AMWorkOrder.h"

#import "AMTitleTableViewCell.h"
#import "AMInvoiceCodeTableViewCell.h"
#import "AMWorkPerformedTableViewCell.h"
#import "AMMaintenanceTypeTableViewCell.h"
#import "AMFilterNameTableViewCell.h"
#import "AMAddTableViewCell.h"
#import "AMWorkOrderViewController.h"
#import "AMPartNameTableViewCell.h"

#import "AMWorkOrderNotesTableViewCell.h"
#import "AMRepairTableViewCell.h"
#import "AMTitleWithAddTableViewCell.h"
#import "AMPopoverSelectTableViewController.h"

#import "AMParts.h"

#import "KLCPopup.h"
#import "TBView.h"
#import "AMProtocolManager.h"

#define MAX_FILTER_COUNT    5
#define MAX_PART_COUNT      5

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

@interface AMBenchCheckoutViewController ()
<
UITextViewDelegate,
UITextFieldDelegate,
UIPopoverControllerDelegate,
AMPopoverSelectTableViewControllerDelegate
>
{
	UIPopoverController *aPopoverVC;

    NSMutableArray *arrCodeItems;
    NSMutableArray *arrFilterItems;
    NSMutableArray *arrPartItems;
    NSMutableArray *arrWorkItems;
    
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
@property (nonatomic, strong) NSMutableArray *arrPartItems;
@property (nonatomic, strong) NSMutableArray *arrWorkItems;
@property (nonatomic, strong) NSMutableArray *arrCodePriceList;
@property (nonatomic, strong) UILabel *lblQty;//bkk 2/5/15
@property (nonatomic, strong) NSDictionary *workorderDict;


//bkk 2/5/15
- (NSInteger)valueForRow:(NSInteger)row inFieldWithTag:(NSInteger)tag;
@end

@implementation AMBenchCheckoutViewController
@synthesize aPopoverVC;
@synthesize arrCheckoutInfos;
@synthesize delegate;
@synthesize arrInvoiceItems;
@synthesize arrCodeItems;
@synthesize arrFilterItems;
@synthesize arrPartItems;
@synthesize arrWorkItems;
@synthesize arrCodePriceList;
@synthesize strNotes;
@synthesize strRepairCode;
@synthesize arrResultAssetRequest;
@synthesize lblQty;//bkk 2/5/15
@synthesize workorderDict;

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

	self.mainTableView.sectionIndexBackgroundColor = [UIColor whiteColor];
	self.mainTableView.sectionIndexColor = [UIColor whiteColor];
	[self.mainTableView reloadData];
    
    [self.btnNext.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    
    [self.btnNext setTitle:MyLocal(@"SUBMIT") forState:UIControlStateNormal];
    [self.btnNext setTitle:MyLocal(@"SUBMIT") forState:UIControlStateHighlighted];
    [self.btnCancelScrap setTitle:MyLocal(@"CANCEL AND SCRAP") forState:UIControlStateNormal];
    
}
-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (id)initWithWorkOrder:(NSDictionary *)aWorkOrder {
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
	self.view.frame = self.view.superview.bounds;
}

-(NSMutableArray *)repairCodes
{
    return       [NSMutableArray arrayWithObjects:
      @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Shop Work Completed"),kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Shop Work Completed")},
      @{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Equipment Cleaned"),kAMPOPOVER_DICTIONARY_KEY_VALUE : MyLocal(@"Equipment Cleaned")},
      nil];
}
#pragma mark -

- (void)refreshToInitialization {
}

#pragma mark - Click

- (IBAction)clickScrapCancelBtn:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertView showWithTitle:@"Scrap" message:@"Are you sure you want to scrap?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != 0)
            {
                //OK
                [[AMProtocolManager sharedInstance] scrapBenchAsset: [self.workorderDict valueForKeyWithNullToNil:@"Id"] completion:^(NSInteger type, NSError *error, id userData, id responseData) {
                    
                    if(error)
                    {
                        MAIN ( (^{
                            
                            [UIAlertView showWithTitle:@"Scrap Error"
                                               message: [NSString stringWithFormat: @"Error:%@" ,error] cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil
                                              tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                  
                                              }];
                        }) );
                    } else {
                        //dismiss the screen after successful scrap
                        NSDictionary *dicInfo = @{
                                                  KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                                                  KEY_OF_INFO:[NSNumber numberWithInteger:7],
                                                  };
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
                        });
                    }
                    
                }];
            }
        }];
    });
}

//TODO::Enhancement140929
- (IBAction)clickSubmitBtn:(UIButton *)sender {
    DLog(@"clickSubmitBtn");
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIAlertView showWithTitle:@"Check Out" message:@"Are you sure you want to Check Out?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex != 0)
            {
                NSMutableDictionary *dicRepairCode = [[self dataWithType:AMCheckoutCellType_Checkout_RepairCode] objectForKey:KEY_OF_CELL_DATA];
                
                if ([[dicRepairCode objectForKey:KEY_OF_REPAIR_CODE] length] == 0) {
                    [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Repair Code")];
                    return;
                }
                NSString *WOID = [[self.workorderDict valueForKeyWithNullToNil:@"Item"] valueForKeyWithNullToNil:@"Id"];
                NSString *repairCode = [dicRepairCode valueForKeyWithNullToNil:@"REPAIR_CODE"];



                AMWorkOrderNotesTableViewCell *cell = (AMWorkOrderNotesTableViewCell *)[(UITableView *)self.mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                
                if ((cell.textViewWorkOrderNotes.text.length == 0 || [cell.textViewWorkOrderNotes.text isEqualToString:@"Write note"])) {
                    [AMUtilities showAlertWithInfo:MyLocal(@"Please Input Work Order Notes")];
                    return;
                }
                
                NSDictionary *benchWODict = @{
                                             @"workOrderId" : WOID,
                                             @"repairCode" : repairCode,
                                             @"notes" : cell.textViewWorkOrderNotes.text
                                             };
                
                [[AMProtocolManager sharedInstance] setBenchWOCheckout:benchWODict completion:^(NSInteger type, NSError *error, id userData, id responseData) {
                    //
                    if (!error)
                    {
                        NSDictionary *dicInfo = @{
                                                  KEY_OF_TYPE:TYPE_OF_BTN_ITEM_CLICKED,
                                                  KEY_OF_INFO:[NSNumber numberWithInteger:7],
                                                  };
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_AMLEFTBARVIEWCONTROLLER object:dicInfo];
                        });
                    }
                    
                }];
            }
        }];
    });
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

    invoce.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:INVOICE_TYPE_PART forObject:RECORD_TYPE_OF_INVOICE];
    invoce.recordTypeName = INVOICE_TYPE_PART;

	[arrPartItems addObject:invoce];
    
	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:dicInfo]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickPartNameBtn:(UIButton *)sender {
    
     [self.mainTableView endEditing:YES];
    NSString *productID = [self.workorderDict valueForKeyWithNullToNil:@"Product2Id"];
//    AMAsset *assetInfo = [[AMLogicCore sharedInstance] getAssetInfoByID:assetID];
//    
//	if (!assetInfo) {
//        [AMUtilities showAlertWithInfo:MyLocal(@"Part List Empty")];
//		return;
//	}
    
	NSArray *arrTemp = [[AMLogicCore sharedInstance] getPartsListByProductID: productID];
    
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

#pragma mark -


- (void)setupDataSourceByWorkOrder:(NSDictionary *)aWorkOrder {
    
    self.mainTableView.contentOffset = CGPointMake(0, 0);
    

    
    if (self.arrCheckoutInfos && [self.arrCheckoutInfos count] > 0) {
        [self.arrCheckoutInfos removeAllObjects];
    }
    else
    {
        self.arrCheckoutInfos = [NSMutableArray array];
    }
    
    if (self.arrCodeItems && [self.arrCodeItems count] > 0) {
        [self.arrCodeItems removeAllObjects];
    }
    else
    {
        self.arrCodeItems = [NSMutableArray array];
    }
    
    if (self.arrPartItems && [self.arrPartItems count] > 0) {
        [self.arrPartItems removeAllObjects];
    }
    else
    {
        self.arrPartItems = [NSMutableArray array];
    }
    self.workorderDict = aWorkOrder;
    
    NSMutableDictionary *dicWO = [NSMutableDictionary dictionary];
    [dicWO setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_RepairCode] forKey:KEY_OF_CELL_TYPE];
    [dicWO setObject:[NSString stringWithFormat:@"%@", [@"" length] == 0 ? @"":@""] forKey:KEY_OF_REPAIR_CODE];
    
    NSMutableDictionary *dicWoT = [NSMutableDictionary dictionary];
    [dicWoT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_RepairCode] forKey:KEY_OF_CELL_TYPE];
    [dicWoT setObject:dicWO forKey:KEY_OF_CELL_DATA];
    
    [self.arrCheckoutInfos addObject:dicWoT];
    
	NSMutableDictionary *dicWONotes = [NSMutableDictionary dictionary];
	[dicWONotes setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_WorkOrderNotes] forKey:KEY_OF_CELL_TYPE];
	[dicWONotes setObject:[NSString stringWithFormat:@"%@", [@"" length] == 0 ? @"":@""] forKey:KEY_OF_WORKORDER_NOTES];
    
    NSMutableDictionary *dicWONotesT = [NSMutableDictionary dictionary];
    [dicWONotesT setObject:[NSNumber numberWithInteger:AMCheckoutCellType_Checkout_WorkOrderNotes] forKey:KEY_OF_CELL_TYPE];
    [dicWONotesT setObject:dicWONotes forKey:KEY_OF_CELL_DATA];
    
	[self.arrCheckoutInfos addObject:dicWONotesT];
    
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
    
    [self.mainTableView reloadData];
    
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
	}
    
	return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dicPartItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
    if (indexPath.section == [arrCheckoutInfos indexOfObject:dicPartItemInfo]) {
        return  TRUE;
    }
    
    return FALSE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数
{
    NSMutableDictionary *dicPartItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
    if (indexPath.section == [arrCheckoutInfos indexOfObject:dicPartItemInfo]) {
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
        NSMutableDictionary *dicPartItemInfo = [self dataWithType:AMCheckoutCellType_Checkout_Part_Item];
        
        if(indexPath.section == [arrCheckoutInfos indexOfObject:dicPartItemInfo]){
            
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
                        //[self refreshTotalPrice];
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
                    //[self refreshTotalPrice];
                });
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id checkoutItem = [self.arrCheckoutInfos objectAtIndex:section];
    
	switch ([[checkoutItem objectForKey:KEY_OF_CELL_TYPE] integerValue]) {
		case AMCheckoutCellType_Checkout_RepairCode :
        case AMCheckoutCellType_Checkout_WorkOrderNotes :
        case AMCheckoutCellType_Checkout_Part_Title:
		{
			return 1;
		}
            break;
		case AMCheckoutCellType_Checkout_Part_Item:
		{
			return [arrPartItems count];
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

#pragma mark - UITextfield Delegates

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
    
    if(TextInputType_PartQuantity == iType)
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
    
	//[self refreshTotalPrice];
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

#pragma mark - AMPopover delegate

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
    if (aVerificationStatusTableViewController.tag == PopViewType_Select_RepairCode) {
        
        //TODO::Enhancement140929
        NSString *strRepairCode0 = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
        NSMutableDictionary *dicInfo = [[self dataWithType:AMCheckoutCellType_Checkout_RepairCode] objectForKey:KEY_OF_CELL_DATA];
        [dicInfo setObject:strRepairCode0 forKey:KEY_OF_REPAIR_CODE];
        

        [aPopoverVC dismissPopoverAnimated:YES];
        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[arrCheckoutInfos indexOfObject:[self dataWithType:AMCheckoutCellType_Checkout_RepairCode]]] withRowAnimation:UITableViewRowAnimationNone];
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



- (IBAction)valueChanged:(UIStepper *)sender {
    double value = ((UIStepper *)sender).value;
    
    [lblQty setText:[NSString stringWithFormat:@"%d", (int)value]];
}
@end
