//
//  AMVerificationViewController.m
//  AramarkFSP
//
//  Created by PwC on 5/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMVerificationViewController.h"

#import "AMVerificationSectionView.h"
#import "AMVerificationTableViewCell.h"
#import "AMAsset.h"
#import "AMAssetRequest.h"
#import "AMPopoverSelectTableViewController.h"
#import "AMVerificationAddSectionView.h"
#import "AMVerificationAddTableViewCell.h"
#import "AMVerificationNewAddAssetTableViewCell.h"

typedef NS_ENUM (NSInteger, VerificationTextInputType) {
	VerificationTextInputType_MachineType = 0,
	VerificationTextInputType_VerifiedDate,
	VerificationTextInputType_Asset,
	VerificationTextInputType_Serial,
	VerificationTextInputType_UpdatedAsset,
	VerificationTextInputType_UpdatedSerial,
	VerificationTextInputType_Notes,
    
	VerificationTextInputType_AddMachineNumber,
	VerificationTextInputType_AddSerialNumber,
	VerificationTextInputType_AddPointOfService,
	VerificationTextInputType_AddLocation,
    VerificationTextInputType_AddNotes,
};

typedef NS_ENUM (NSInteger, PopViewType) {
	PopViewType_Select_VerificationStatus = 1000,
	PopViewType_Select_NormalLocation,
	PopViewType_Select_AddLocation,
	PopViewType_Select_AddStatus,
    PopViewType_Select_MoveToWarehouse
};

typedef NS_ENUM (NSInteger, InfoType) {
	InfoType_NormalAsset = 0,
	InfoType_NewAddAsset,
	InfoType_AddingAsset,
};

#define TEXT_OF_NEW         @"New"
#define TEXT_OF_FOUND       @"Found"
#define TEXT_OF_WORKING         @"Working"
#define TEXT_OF_NOT_WORKING       @"Not Working"

@interface AMVerificationViewController ()
<
AMVerificationSectionViewDelegate,
AMPopoverSelectTableViewControllerDelegate,
UIPopoverControllerDelegate,
UITextFieldDelegate,
UITextViewDelegate,
AMVerificationAddSectionViewDelegate
>
{
	NSMutableArray *arrSections;
	UIPopoverController *aPopoverVC;
	NSMutableArray *arrVerificationStatus;
	NSMutableDictionary *dicAddInfo;
	AMWorkOrder *workOrder;
    AMAsset *woAsset;
}

@property (nonatomic, strong) NSMutableDictionary *dicAddInfo;
@property (nonatomic, strong) NSMutableArray *arrSections;
@property (nonatomic, strong) UIPopoverController *aPopoverVC;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (nonatomic, strong) AMWorkOrder *workOrder;

@end

@implementation AMVerificationViewController
@synthesize dicAddInfo;
@synthesize arrVerificationInfos;
@synthesize arrSections;
@synthesize aPopoverVC;
@synthesize workOrder;
@synthesize delegate;
@synthesize arrResultAsset;
@synthesize arrResultAssetRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        arrVerificationStatus = [NSMutableArray array];
        arrSections = [NSMutableArray array];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	dicAddInfo = [NSMutableDictionary dictionary];
	[dicAddInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_NEEDSHOW];
    [dicAddInfo setObject:@"" forKey:KEY_OF_LOCATION];
    [dicAddInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_SELECT];
    
    [self.btnNext.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeBigger]];
    
    [self.btnNext setTitle:MyLocal(@"NEXT") forState:UIControlStateNormal];
    [self.btnNext setTitle:MyLocal(@"NEXT") forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
	[super viewWillLayoutSubviews];
	self.view.frame = self.view.superview.bounds;
}

#pragma mark - Data

- (void)setupDataSourceByInfo:(AMWorkOrder *)aWorkOrder {
    
    self.mainTableView.contentOffset = CGPointMake(0, 0);
    
    if ([workOrder.woID isEqualToString:aWorkOrder.woID]) {
		return;
	}
    
    self.workOrder = aWorkOrder;
    
    if ([self.arrVerificationInfos count] > 0) {
        [self.arrVerificationInfos removeAllObjects];
    }
    
    if ([arrVerificationStatus count] > 0) {
        [arrVerificationStatus removeAllObjects];
    }
    
    //CHANGE: Fix for Issue: FAST APP: Asset Verification discrepancies . https://aramark.my.salesforce.com/a2Qi0000000MPfx
    dicAddInfo = [NSMutableDictionary dictionary];
    [dicAddInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_NEEDSHOW];
    [dicAddInfo setObject:@"" forKey:KEY_OF_LOCATION];
    [dicAddInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_SELECT];
    
    NSArray *arrList = [[AMLogicCore sharedInstance] getRecordTypeListForObjectType:RECORD_TYPE_OF_ASSET];
    
    if (arrList && [arrList count] > 0) {
        
        [arrVerificationStatus addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_VERIFED) ,kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_VERIFED }];
        
        for (AMDBRecordType *recordType in arrList) {
            if ([recordType.name isEqualToString:MyLocal(TEXT_OF_NEW)]
                || [recordType.name isEqualToString:MyLocal(TEXT_OF_FOUND)]
                || [recordType.name isEqualToString:TEXT_OF_NEW]
                || [recordType.name isEqualToString:TEXT_OF_FOUND]) {
                continue;
            }
            else
            {
                if (![arrVerificationStatus containsObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(recordType.name) ,
                                                              kAMPOPOVER_DICTIONARY_KEY_DATA : recordType ,
                                                              kAMPOPOVER_DICTIONARY_KEY_VALUE : recordType.name}]) {
                    [arrVerificationStatus addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(recordType.name),
                                                        kAMPOPOVER_DICTIONARY_KEY_DATA : recordType ,
                                                        kAMPOPOVER_DICTIONARY_KEY_VALUE : recordType.name}];
                }
            }
        }
        
        [arrVerificationStatus addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_NEED_TO_VERIFY) ,kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_NEED_TO_VERIFY }];
    }
    
	self.arrVerificationInfos = [NSMutableArray array];
    
	NSArray *assetList = [[AMLogicCore sharedInstance] getAssetListByPoSID:aWorkOrder.posID AccountID:aWorkOrder.accountID];
    
    woAsset = [[AMLogicCore sharedInstance] getAssetInfoByID:self.workOrder.assetID];
    
    if (woAsset.locationID && [woAsset.locationID length] != 0) {
        NSMutableArray *arrSame = [NSMutableArray array];
        NSMutableArray *arrNotSame = [NSMutableArray array];
        for (AMAsset *asset in assetList) {
            if ([asset.locationID isEqualToString:woAsset.locationID]) {
                [arrSame addObject:asset];
            }
            else
            {
                [arrNotSame addObject:asset];
            }
        }
        
        NSMutableArray *arrItems = [NSMutableArray array];
        
        for (AMAsset *asset in arrNotSame) {
            
            BOOL contain = NO;
            
            for (NSMutableArray *arrInfos in arrItems) {
                if (arrInfos && [arrInfos count] > 0) {
                    AMAsset *asset0 = [arrInfos firstObject];
                    if ([asset.locationID isEqualToString:asset0.locationID]) {
                        [arrInfos addObject:asset];
                        contain = YES;
                        break;
                    }
                }
            }
            
            if (!contain) {
                NSMutableArray *arrNews = [NSMutableArray array];
                [arrNews addObject:asset];
                [arrItems addObject:arrNews];
            }
        }
        
        NSArray *sortedArray = [arrItems sortedArrayUsingComparator: ^NSComparisonResult (NSMutableArray *arr1, NSMutableArray *arr2) {
            return [arr1 count] >= [arr2 count];
        }];
        
        for (AMAsset *asset in arrSame) {
            [self addDicInfoToLocalList:asset];
        }
        
        for (NSMutableArray *arrInfos in sortedArray) {
            for (AMAsset *asset in arrInfos) {
                [self addDicInfoToLocalList:asset];
            }
        }
    }
    else
    {
        for (AMAsset *asset in assetList) {
            [self addDicInfoToLocalList:asset];
        }
    }
    
	[self.mainTableView reloadData];
}

- (void)addDicInfoToLocalList:(AMAsset *)asset
{
    AMAssetRequest *assetRequest = [[AMAssetRequest alloc] init];
    assetRequest.assetID = asset.assetID;
    assetRequest.machineNumber = asset.machineNumber;
    assetRequest.serialNumber = asset.serialNumber;
    
    BOOL isEditable = NO;
    
    if ([asset.verificationStatus isEqualToString:MyLocal(TEXT_OF_NEED_TO_VERIFY)]
        || [asset.verificationStatus isEqualToString:MyLocal(TEXT_OF_VERIFED)]
        ||[asset.verificationStatus isEqualToString:TEXT_OF_NEED_TO_VERIFY]
        || [asset.verificationStatus isEqualToString:TEXT_OF_VERIFED]
        || [asset.verificationStatus length] == 0) {
        isEditable = YES;
    }
    
    [self.arrVerificationInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          asset,                                                KEY_OF_ASSET_INFO,
                                          assetRequest,                                         KEY_OF_ASSETREQUEST_INFO,
                                          [NSNumber numberWithBool:NO],                         KEY_OF_NEEDSHOW,
                                          [NSNumber numberWithBool:NO],                         KEY_OF_UPDATE,
                                          [NSNumber numberWithBool:isEditable],                 KEY_OF_EDITABLE,
                                          asset.lastVerifiedDate,                               KEY_OF_INITIAL_DATE,
                                          [NSNumber numberWithInteger:InfoType_NormalAsset],    KEY_OF_INFOTYPE,
                                          nil]];
}

#pragma mark - Click

- (IBAction)clickNextBtn:(id)sender {
	DLog(@"clickNextBtn");
    
    if ([arrResultAsset count] > 0) {
        [arrResultAsset removeAllObjects];
    }
    else
    {
        arrResultAsset = [NSMutableArray array];
    }
    
    if ([arrResultAssetRequest count] > 0) {
        [arrResultAssetRequest removeAllObjects];
    }
    else
    {
        arrResultAssetRequest = [NSMutableArray array];
    }
    
	for (NSMutableDictionary *dicInfo in self.arrVerificationInfos) {
		if ([[dicInfo objectForKey:KEY_OF_INFOTYPE] intValue] == InfoType_NewAddAsset) {
            AMAssetRequest *aRequest = [dicInfo objectForKey:KEY_OF_ASSETREQUEST_INFO];
			[arrResultAssetRequest addObject:aRequest];
		}
		else if ([[dicInfo objectForKey:KEY_OF_INFOTYPE] intValue] == InfoType_NormalAsset) {
            
            AMAsset *aAsset = [dicInfo objectForKey:KEY_OF_ASSET_INFO];
            AMAssetRequest *aRequest = [dicInfo objectForKey:KEY_OF_ASSETREQUEST_INFO];
            
            if (([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_WRONG_SERIAL_NUMBER)] || [aAsset.verificationStatus isEqualToString:TEXT_OF_WRONG_SERIAL_NUMBER])
                && [aRequest.updatedSNumber length] == 0
                && [[dicInfo objectForKey:KEY_OF_EDITABLE] boolValue])
            {
                [AMUtilities showAlertWithInfo:MyLocal(@"Selected 'Wrong Serial Number' should input Updated Serial Number")];
                return;
            }
            else if(([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_WRONG_ASSET_NUMBER)] || [aAsset.verificationStatus isEqualToString:TEXT_OF_WRONG_ASSET_NUMBER])
                    && [aRequest.updatedMNumber length] == 0
                    && [[dicInfo objectForKey:KEY_OF_EDITABLE] boolValue])
            {
                [AMUtilities showAlertWithInfo:MyLocal(@"Selected 'Wrong Asset Number' should input Updated Asset Number")];
                return;
            }
            else if(([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_MISSING)] || [aAsset.verificationStatus isEqualToString:TEXT_OF_MISSING])
                    && [aRequest.verifyNotes length] == 0
                    && [[dicInfo objectForKey:KEY_OF_EDITABLE] boolValue])
            {
                [AMUtilities showAlertWithInfo:MyLocal(@"Selected 'Missing' Should input Verification Note")];
                return;
            }
            else if(([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_WRONG_MACHINE_TYPE)] || [aAsset.verificationStatus isEqualToString:TEXT_OF_WRONG_MACHINE_TYPE])
                    && [aRequest.verifyNotes length] == 0
                    && [[dicInfo objectForKey:KEY_OF_EDITABLE] boolValue])
            {
                [AMUtilities showAlertWithInfo:MyLocal(@"Selected 'Wrong Machine Type' Should input Verification Note")];
                return;
            }
            
            if (!([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_MISSING)] || [aAsset.verificationStatus isEqualToString:TEXT_OF_MISSING])) {
                [arrResultAsset addObject:aAsset];
            }
            
            if ([[dicInfo objectForKey:KEY_OF_EDITABLE] boolValue]) {
                if ([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_WRONG_SERIAL_NUMBER)]
                    || [aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_WRONG_ASSET_NUMBER)]
                    || [aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_MOVE_TO_WAREHOUSE)]
                    ||[aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_MISSING)]
                    || [aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_WRONG_MACHINE_TYPE)]
                    ||[aAsset.verificationStatus isEqualToString:TEXT_OF_WRONG_SERIAL_NUMBER]
                    || [aAsset.verificationStatus isEqualToString:TEXT_OF_WRONG_ASSET_NUMBER]
                    || [aAsset.verificationStatus isEqualToString:TEXT_OF_MOVE_TO_WAREHOUSE]
                    ||[aAsset.verificationStatus isEqualToString:TEXT_OF_MISSING]
                    || [aAsset.verificationStatus isEqualToString:TEXT_OF_WRONG_MACHINE_TYPE])
                {
                    aRequest.status = aAsset.verificationStatus;
                    aRequest.statusID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:aAsset.verificationStatus forObject:RECORD_TYPE_OF_ASSET];
                    aRequest.woID = self.workOrder.woID;
                    aRequest.posID = self.workOrder.posID;
                    aRequest.locationID = aAsset.locationID;
                    aRequest.moveToWarehouse = aAsset.moveToWarehouse;
                    
                    [arrResultAssetRequest addObject:aRequest];
                }
            }
        }
	}
    
    if (delegate && [delegate respondsToSelector:@selector(didClickVerificationViewControllerNextBtn)]) {
        [delegate didClickVerificationViewControllerNextBtn];
    }
}

- (void)clickLocationBtn:(UIButton *)sender {
    
    [self.mainTableView endEditing:YES];
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_NormalLocation;
	popView.aIndexPath = [AMUtilities indexPathForView:sender inTableView:self.mainTableView];
    
	NSArray *arrLocations = [[AMLogicCore sharedInstance] getLocationListByAccountID:self.workOrder.accountID];
    
	NSMutableArray *arrLocationInfos = [NSMutableArray array];
    
	for (AMLocation *locationInfo in arrLocations) {
		[arrLocationInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : [NSString stringWithFormat:@"%@", locationInfo.location], kAMPOPOVER_DICTIONARY_KEY_DATA : locationInfo }];
	}
    
    //add add new button
    [arrLocationInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(@"Add New"), kAMPOPOVER_DICTIONARY_KEY_DATA : @"Add New" }];
    
	popView.arrInfos = arrLocationInfos;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
}

- (void)clickVerificationBtn:(UIButton *)sender {
    
    [self.mainTableView endEditing:YES];
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_VerificationStatus;
    popView.aIndexPath = [AMUtilities indexPathForView:sender inTableView:self.mainTableView];
	popView.arrInfos = arrVerificationStatus;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
    if (sender.superview.superview.window) {
        [aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:NO];
    }
}

- (void)btnMoveToWarehouseTapped:(UIButton *)sender {
    UIButton *button = ((UIButton*) sender);
    
    //get the last section on the screen
    AMVerificationAddSectionView *aSection = self.arrSections[self.arrSections.count-1];
    
    //found status.
    if([aSection.labelStatus.text isEqualToString:@"Found"])
    {
        AMVerificationAddTableViewCell *cell = [self.mainTableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:button.tag inSection:[self.mainTableView numberOfSections]-1]];

        cell.imgCheckmark.hidden = !cell.imgCheckmark.isHidden;
        
        NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:sender.tag];
        //AMAsset *aAsset = [dicInfos objectForKey:KEY_OF_ASSET_INFO];
        AMAssetRequest *aAsset = [dicInfos objectForKey:KEY_OF_ASSETREQUEST_INFO];
        
        if(!cell.imgCheckmark.hidden)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIAlertView showWithTitle:@"Working/Not Working" message:MyLocal(@"Is equipment being returned in working condition?") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"NO") otherButtonTitles:@[MyLocal(@"YES")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    
                    if(buttonIndex == 0)
                    {
                        //YES
                        aAsset.moveToWarehouse = MyLocal(@"Not Working");
                        
                    } else if (buttonIndex == 1) {
                        //NO
                        aAsset.moveToWarehouse = MyLocal(@"Working");
                    }
                    [dicAddInfo setObject:aAsset.moveToWarehouse forKey:KEY_OF_MOVE_TO_WAREHOUSE];
                    
                }];
            });
        } else {
            [dicAddInfo setObject:@"" forKey:KEY_OF_MOVE_TO_WAREHOUSE];
        }
    } else {
        //New status so erase this one
        [dicAddInfo setObject:@"" forKey:KEY_OF_MOVE_TO_WAREHOUSE];
    }
}

- (void)clickAddStatusBtn:(UIButton *)sender {
    
    [self.mainTableView endEditing:YES];
    
	AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
	popView.delegate = self;
	popView.tag = PopViewType_Select_AddStatus;
    
	NSMutableArray *arrList = [NSMutableArray array];
	[arrList addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_NEW), kAMPOPOVER_DICTIONARY_KEY_DATA : TEXT_OF_NEW, kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_NEW }];
	[arrList addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : MyLocal(TEXT_OF_FOUND), kAMPOPOVER_DICTIONARY_KEY_DATA : TEXT_OF_FOUND , kAMPOPOVER_DICTIONARY_KEY_VALUE : TEXT_OF_FOUND }];
    
	popView.arrInfos = arrList;
	aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
	[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
	aPopoverVC.delegate = self;
	[aPopoverVC presentPopoverFromRect:sender.frame inView:sender.superview.superview permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)clickUpdateBtn:(UIButton *)sender {
    NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:sender.tag];
    AMAsset *aAsset = [dicInfos objectForKey:KEY_OF_ASSET_INFO];
    sender.selected = !sender.selected;
    [dicInfos setObject:[NSNumber numberWithBool:sender.selected] forKey:KEY_OF_UPDATE];
    if (sender.selected) {
        aAsset.lastVerifiedDate = [NSDate date];
    }
    else
    {
        aAsset.lastVerifiedDate = [dicInfos objectForKey:KEY_OF_INITIAL_DATE];
    }
    
    aAsset.verificationStatus = TEXT_OF_VERIFED;
    
    [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)clickAddBtn:(UIButton *)sender {
	DLog(@"clickAddBtn");
    
    [self.mainTableView endEditing:YES];
    
	AMAssetRequest *aAsset = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
    
	if ([aAsset.machineNumber length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please input Asset Number!")];
		return;
	}
    
	if ([aAsset.serialNumber length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please input Serial Number!")];
		return;
    }
    
    if (([aAsset.status isEqualToString:MyLocal(TEXT_OF_FOUND)] || [aAsset.status isEqualToString:TEXT_OF_FOUND]) && [aAsset.verifyNotes length] == 0) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please input Verification Note!")];
		return;
    }
    
    if ([AMUtilities isEmpty:[dicAddInfo objectForKey:KEY_OF_LOCATION]] && !aAsset.locationID) {
        [AMUtilities showAlertWithInfo:MyLocal(@"Please input Location!")];
		return;
    }
    
	[dicAddInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_SELECT];
    
    AMAssetRequest *aNew = [[AMAssetRequest alloc] init];
    aNew.woID = self.workOrder.woID;
    aNew.posID = self.workOrder.posID;
    aNew.locationID = aAsset.locationID;
    aNew.posID = aAsset.posID;
    aNew.machineNumber = aAsset.machineNumber;
    aNew.serialNumber = aAsset.serialNumber;
    aNew.status = aAsset.status;
    aNew.statusID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:aAsset.status forObject:RECORD_TYPE_OF_ASSET];
    aNew.woID = self.workOrder.woID;
    aNew.verifyNotes = aAsset.verifyNotes;
    aNew.moveToWarehouse = [dicAddInfo objectForKey:KEY_OF_MOVE_TO_WAREHOUSE];//aAsset.moveToWarehouse;
    
    NSString *strLocation = [dicAddInfo objectForKey:KEY_OF_LOCATION];
    
    if (![AMUtilities isEmpty:strLocation]) {
        [self acquireLocationFor:aNew withLocation:strLocation];
    }
    
	[self.arrVerificationInfos addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          aNew, KEY_OF_ASSETREQUEST_INFO,
                                          [NSNumber numberWithBool:YES], KEY_OF_NEEDSHOW,
                                          [NSNumber numberWithInteger:InfoType_NewAddAsset], KEY_OF_INFOTYPE,
                                          nil]];
    
    //    [[AMLogicCore sharedInstance] saveAssetRequestList:[NSMutableArray arrayWithObjects:aNew, nil] completionBlock:nil];
    
    //    AMAssetRequest *aAssetRequest = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
    //    aAssetRequest.woID = self.workOrder.woID;
    //    aAssetRequest.posID = self.workOrder.posID;
    //    aAssetRequest.status = TEXT_OF_NEW;
    //    aAssetRequest.statusID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:aAsset.status forObject:RECORD_TYPE_OF_ASSET];
    //    aAssetRequest.machineNumber = @"";
    //    aAssetRequest.serialNumber = @"";
    //    aAssetRequest.locationID = @"";
    
    [dicAddInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_NEEDSHOW];
    [dicAddInfo removeObjectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
    //	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count]] withRowAnimation:UITableViewRowAnimationNone];
    
	[self.mainTableView reloadData];
}

#pragma mark -
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self.arrVerificationInfos count]) {
        
        //This part is for adding new verification
		AMVerificationAddTableViewCell *cell = (AMVerificationAddTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMVerificationAddTableViewCell"];
		if (cell == nil) {
			NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMVerificationAddTableViewCell" owner:[AMVerificationAddTableViewCell class] options:nil];
			cell = (AMVerificationAddTableViewCell *)[nib objectAtIndex:0];
		}
        
        AMAssetRequest *aAsset = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
        
		cell.textFieldAsset.delegate = self;
		cell.textFieldAsset.tag = (indexPath.section * 1000 + VerificationTextInputType_AddMachineNumber);
        cell.textFieldAsset.text = [aAsset.machineNumber length] == 0 ? TEXT_OF_NULL : aAsset.machineNumber;
        
		cell.textFieldSerial.delegate = self;
		cell.textFieldSerial.tag = (indexPath.section * 1000 + VerificationTextInputType_AddSerialNumber);
        cell.textFieldSerial.text = [aAsset.serialNumber length] == 0 ? TEXT_OF_NULL : aAsset.serialNumber;
        
		cell.textFieldPoint.delegate = self;
        AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:self.workOrder.posID];
		cell.textFieldPoint.text = pos.name;
		cell.textFieldPoint.tag = (indexPath.section * 1000 + VerificationTextInputType_AddPointOfService);
        
		cell.textFieldLocation.delegate = self;
		cell.textFieldLocation.tag = (indexPath.section * 1000 + VerificationTextInputType_AddLocation);
        
        AMLocation *aLocation = [[AMLogicCore sharedInstance] getLocationByID:aAsset.locationID];
        cell.textFieldLocation.text = (aLocation && aAsset.locationID) ? aLocation.location : TEXT_OF_NULL;
        
        cell.textViewNote.delegate = self;
        cell.textViewNote.tag = (indexPath.section * 1000 + VerificationTextInputType_AddNotes);
        cell.textViewNote.text = [aAsset.verifyNotes length] == 0 ? TEXT_OF_WRITE_NOTE : aAsset.verifyNotes;
        
		[cell.btnAdd addTarget:self action:@selector(clickAddBtn:) forControlEvents:UIControlEventTouchUpInside];
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //bkk 9/2/2016 - added Move to WarehouseFunctionality
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        bool isBenchTech = [[prefs valueForKey:@"isBenchTechActive"] boolValue];
        if(isBenchTech)
        {
            cell.btnMoveToWarehouse.tag = indexPath.row;
            
            [cell.btnMoveToWarehouse addTarget:self action:@selector(btnMoveToWarehouseTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnMoveToWarehouse.hidden = NO;
            cell.imgCheckmarkBackground.hidden = NO;
            cell.lblMoveToWarehouse.hidden = NO;
        } else {
            
            [cell.btnMoveToWarehouse addTarget:self action:@selector(btnMoveToWarehouseTapped:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnMoveToWarehouse.hidden = YES;
            cell.imgCheckmark.hidden = YES;
            cell.imgCheckmarkBackground.hidden = YES;
            cell.lblMoveToWarehouse.hidden = YES;
        }
		return cell;
	}
	else {
        
        //This section is for existing verification, ie. NOT NEW
		NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:indexPath.section];
        
		NSInteger iInfoType = [[dicInfos objectForKey:KEY_OF_INFOTYPE] intValue];
        
		if (iInfoType == InfoType_NormalAsset) {
			AMVerificationTableViewCell *cell = (AMVerificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMVerificationTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMVerificationTableViewCell" owner:[AMVerificationTableViewCell class] options:nil];
				cell = (AMVerificationTableViewCell *)[nib objectAtIndex:0];
			}
            
            AMAsset *aAsset = [dicInfos objectForKey:KEY_OF_ASSET_INFO];
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			aAsset.verificationStatus = [aAsset.verificationStatus length] == 0 ? TEXT_OF_NEED_TO_VERIFY : aAsset.verificationStatus;
            
			if ([aAsset.verificationStatus isEqualToString:MyLocal(TEXT_OF_VERIFED)] || [aAsset.verificationStatus isEqualToString:TEXT_OF_VERIFED]) {
				cell.labelVerificationStatus.textColor = COLOR_GREEN;
			}
			else {
				cell.labelVerificationStatus.textColor = COLOR_RED;
			}
            
			cell.labelVerificationStatus.text = MyLocal(aAsset.verificationStatus);
            
			cell.textFieldMachineType.delegate = self;
			cell.textFieldMachineType.tag = (indexPath.section * 1000 + VerificationTextInputType_MachineType);
            
			cell.textFieldVerifiedDate.delegate = self;
			cell.textFieldVerifiedDate.tag = (indexPath.section * 1000 + VerificationTextInputType_VerifiedDate);
            
			cell.textFieldAsset.delegate = self;
			cell.textFieldAsset.tag = (indexPath.section * 1000 + VerificationTextInputType_Asset);
            
			cell.textFieldSerial.delegate = self;
			cell.textFieldSerial.tag = (indexPath.section * 1000 + VerificationTextInputType_Serial);
            
			cell.textFieldUpdatedAsset.delegate = self;
			cell.textFieldUpdatedAsset.tag = (indexPath.section * 1000 + VerificationTextInputType_UpdatedAsset);
            
			cell.textFieldUpdateSerial.delegate = self;
			cell.textFieldUpdateSerial.tag = (indexPath.section * 1000 + VerificationTextInputType_UpdatedSerial);
            
			cell.textViewNote.delegate = self;
			cell.textViewNote.tag = (indexPath.section * 1000 + VerificationTextInputType_Notes);
            
			cell.btnVerification.tag = indexPath.section;
			[cell.btnVerification addTarget:self action:@selector(clickVerificationBtn:) forControlEvents:UIControlEventTouchUpInside];
            
			cell.btnLocation.tag = indexPath.section;
			[cell.btnLocation addTarget:self action:@selector(clickLocationBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnUpdateDate.tag = indexPath.section;
            [cell.btnUpdateDate addTarget:self action:@selector(clickUpdateBtn:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.btnUpdateDate.selected = [[dicInfos objectForKey:KEY_OF_UPDATE] boolValue];
            
            cell.textFieldMachineType.text = aAsset.productName;
            cell.textFieldAsset.text = aAsset.machineNumber;
            NSString *strDate = @"";
            
            if (aAsset.lastVerifiedDate) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                strDate = [dateFormatter stringFromDate:aAsset.lastVerifiedDate];
            }
            
            cell.textFieldVerifiedDate.text = strDate;
            
            cell.textFieldSerial.text = aAsset.serialNumber;
            
            AMAssetRequest *aAssetR = [dicInfos objectForKey:KEY_OF_ASSETREQUEST_INFO];
            
            cell.textViewNote.text = [aAssetR.verifyNotes length] == 0 ? TEXT_OF_WRITE_NOTE : aAssetR.verifyNotes;
            
            cell.labelLocation.text = aAsset.assetLocation.location;
            
            AMAssetRequest *aAssetRequest = [dicInfos objectForKey:KEY_OF_ASSETREQUEST_INFO];
            
            cell.textFieldUpdatedAsset.text = [aAssetRequest.updatedMNumber length] == 0 ? TEXT_OF_NULL : aAssetRequest.updatedMNumber;
            cell.textFieldUpdateSerial.text = [aAssetRequest.updatedSNumber length] == 0 ? TEXT_OF_NULL : aAssetRequest.updatedSNumber;
            
            [cell enableEdit:[[dicInfos objectForKey:KEY_OF_EDITABLE] boolValue]];

         
			return cell;
		}
		else {
			AMVerificationNewAddAssetTableViewCell *cell = (AMVerificationNewAddAssetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"AMVerificationNewAddAssetTableViewCell"];
			if (cell == nil) {
				NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMVerificationNewAddAssetTableViewCell" owner:[AMVerificationNewAddAssetTableViewCell class] options:nil];
				cell = (AMVerificationNewAddAssetTableViewCell *)[nib objectAtIndex:0];
			}
            
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            AMAssetRequest *aAssetRequest = [dicInfos objectForKey:KEY_OF_ASSETREQUEST_INFO];
            
			cell.textFieldAsset.text = aAssetRequest.machineNumber;
			cell.textFieldSerial.text = aAssetRequest.serialNumber;
            AMPoS *pos = [[AMLogicCore sharedInstance] getPoSInfoByID:self.workOrder.posID];
            cell.textFieldPoint.text = pos.name;
            
            AMLocation *aLocation = [[AMLogicCore sharedInstance] getLocationByID:aAssetRequest.locationID];
            cell.textFieldLocation.text = aLocation ? aLocation.location : TEXT_OF_NULL;
            
            cell.textViewNote.delegate = self;
			cell.textViewNote.tag = (indexPath.section * 1000 + VerificationTextInputType_AddNotes);
            cell.textViewNote.text = [aAssetRequest.verifyNotes length] == 0 ? TEXT_OF_WRITE_NOTE : aAssetRequest.verifyNotes;
            cell.textViewNote.editable = NO;
            cell.imgCheckmark.hidden =  (aAssetRequest.moveToWarehouse != nil && ![aAssetRequest.moveToWarehouse isEqualToString: @""]) ? NO : YES;//bkk 9/6/2016
			return cell;
		}
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == [self.arrVerificationInfos count]) {
		NSNumber *needShow = [dicAddInfo objectForKey:KEY_OF_NEEDSHOW];
		if ([needShow boolValue]) {
			return 1;
		}
		else {
			return 0;
		}
	}
	else {
        
		NSMutableDictionary *dicInfo = [self.arrVerificationInfos objectAtIndex:section];
		NSNumber *needShow = [dicInfo objectForKey:KEY_OF_NEEDSHOW];
		if ([needShow boolValue]) {
			return 1;
		}
		else {
			return 0;
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.arrVerificationInfos count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == [self.arrVerificationInfos count]) {
		return 325.0;
	}
	else {
		NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:indexPath.section];
		NSInteger iInfoType = [[dicInfos objectForKey:KEY_OF_INFOTYPE] intValue];
        
		if (iInfoType == InfoType_NormalAsset) {
			return 345.0;
		}
		else {
			return 263.0;
		}
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (section == [self.arrVerificationInfos count]) {
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMVerificationAddSectionView" owner:[AMVerificationAddSectionView class] options:nil];
		AMVerificationAddSectionView *aVerificationTitle = (AMVerificationAddSectionView *)[nib objectAtIndex:0];
		aVerificationTitle.delegate = self;
		[aVerificationTitle setAdd:[[dicAddInfo objectForKey:KEY_OF_NEEDSHOW] boolValue]];
		[aVerificationTitle.btnStatus addTarget:self action:@selector(clickAddStatusBtn:) forControlEvents:UIControlEventTouchUpInside];
        
		aVerificationTitle.labelStatus.textColor = COLOR_BLUE;
        
        AMAssetRequest *Info = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
        
		aVerificationTitle.labelStatus.text = [Info.status length] == 0 ? MyLocal(TEXT_OF_NEED_TO_VERIFY) : MyLocal(Info.status);
        aVerificationTitle.strWOType = self.workOrder.woType;
		if (![self.arrSections containsObject:aVerificationTitle]) {
			[self.arrSections addObject:aVerificationTitle];
		}
        
		return aVerificationTitle;
	}
	else {
		NSMutableDictionary *dicInfo = [self.arrVerificationInfos objectAtIndex:section];
		NSInteger iType = [[dicInfo objectForKey:KEY_OF_INFOTYPE] integerValue];
        
		NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AMVerificationSectionView" owner:[AMVerificationSectionView class] options:nil];
		AMVerificationSectionView *aVerificationTitle = (AMVerificationSectionView *)[nib objectAtIndex:0];
		aVerificationTitle.section = section;
		aVerificationTitle.delegate = self;
		[aVerificationTitle setDrop:[[dicInfo objectForKey:KEY_OF_NEEDSHOW] boolValue]];
        
		if (iType == InfoType_NormalAsset) {
			AMAsset *Info = [dicInfo objectForKey:KEY_OF_ASSET_INFO];
			aVerificationTitle.labelTitle.text = Info.assetName;
			aVerificationTitle.strFlag = [NSString stringWithFormat:@"%d",section];
            [aVerificationTitle setVerified:([Info.verificationStatus isEqualToString:MyLocal(TEXT_OF_VERIFED)] || [Info.verificationStatus isEqualToString:TEXT_OF_VERIFED])];
			aVerificationTitle.labelStatus.text = [Info.verificationStatus length] == 0 ? MyLocal(TEXT_OF_NEED_TO_VERIFY) : MyLocal(Info.verificationStatus);
            
            //TODO::Change Title Font
            if ([Info.locationID isEqualToString:woAsset.locationID]) {
                aVerificationTitle.labelTitle.font = [AMUtilities applicationFontWithOption:kFontOptionItalic andSize:kAMFontSizeCommon];
                aVerificationTitle.labelTitle.textColor = [UIColor blueColor];
            }
            else
            {
                aVerificationTitle.labelTitle.font = [AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon];
                aVerificationTitle.labelTitle.textColor = [UIColor blackColor];
            }
		}
		else {
            
            aVerificationTitle.labelStatus.hidden = NO;
            aVerificationTitle.labelStatusTitle.hidden = NO;
            
			AMAssetRequest *Info = [dicInfo objectForKey:KEY_OF_ASSETREQUEST_INFO];
            aVerificationTitle.strFlag = [NSString stringWithFormat:@"%d",section];
			aVerificationTitle.labelTitle.text = Info.machineNumber;
			aVerificationTitle.labelStatus.textColor = COLOR_BLUE;
			aVerificationTitle.labelStatus.text = [Info.status length] == 0 ? MyLocal(TEXT_OF_NEED_TO_VERIFY) : MyLocal(Info.status);
		}
        
		if (![self.arrSections containsObject:aVerificationTitle]) {
			[self.arrSections addObject:aVerificationTitle];
		}
        
		return aVerificationTitle;
	}
}

#pragma mark -

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    NSIndexPath *indexPath = [AMUtilities indexPathForView:textView inTableView:self.mainTableView];
    [self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
	if ([textView.text isEqualToString:TEXT_OF_WRITE_NOTE]) {
		textView.text = @"";
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
	NSInteger iType = textView.tag % 1000;
	NSInteger iSection = (textView.tag - iType) / 1000;
    
	switch (iType) {
		case VerificationTextInputType_Notes:
		{
            NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:iSection];
            AMAssetRequest *aAsset = [dicInfos objectForKey:KEY_OF_ASSETREQUEST_INFO];
            aAsset.verifyNotes = ([AMUtilities isEmpty:textView.text] || [textView.text isEqualToString:TEXT_OF_WRITE_NOTE]) ? @"" : textView.text;
            [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:iSection] withRowAnimation:UITableViewRowAnimationNone];
		}
            break;
        case VerificationTextInputType_AddNotes:
        {
            AMAssetRequest *aAssetRequest = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
			aAssetRequest.verifyNotes = ([AMUtilities isEmpty:textView.text] || [textView.text isEqualToString:TEXT_OF_WRITE_NOTE]) ? @"" : textView.text;
        }
            break;
		default:
			break;
	}
    
    if ([AMUtilities isEmpty:textView.text]) {
		textView.text = TEXT_OF_WRITE_NOTE;
	}
}

#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	NSInteger iType = textField.tag % 1000;
	NSInteger iSection = (textField.tag - iType) / 1000;
	if (iSection == [self.arrVerificationInfos count]) {
		if (iType == VerificationTextInputType_AddLocation) {
			if ([[dicAddInfo objectForKey:KEY_OF_SELECT] boolValue]) {
				[self.view endEditing:YES];
                
				AMPopoverSelectTableViewController *popView = [[AMPopoverSelectTableViewController alloc] initWithNibName:@"AMPopoverSelectTableViewController" bundle:nil];
				popView.delegate = self;
				popView.tag = PopViewType_Select_AddLocation;
                
                popView.aIndexPath = [AMUtilities indexPathForView:textField inTableView:self.mainTableView];
                
				NSArray *arrLocations = [[AMLogicCore sharedInstance] getLocationListByAccountID:self.workOrder.accountID];
                
				NSMutableArray *arrLocationInfos = [NSMutableArray array];
                
				for (AMLocation *locationInfo in arrLocations) {
					[arrLocationInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO : [NSString stringWithFormat:@"%@", locationInfo.location], kAMPOPOVER_DICTIONARY_KEY_DATA : locationInfo }];
				}
                
				[arrLocationInfos addObject:@{ kAMPOPOVER_DICTIONARY_KEY_INFO: TEXT_OF_ADD_NEW_LOCATION }];
                
				popView.arrInfos = arrLocationInfos;
                popView.isAddNew = YES;
				aPopoverVC = [[UIPopoverController alloc] initWithContentViewController:popView];
				[aPopoverVC setPopoverContentSize:CGSizeMake(CGRectGetWidth(popView.view.frame), CGRectGetHeight(popView.view.frame))];
				aPopoverVC.delegate = self;
				[aPopoverVC presentPopoverFromRect:textField.frame inView:textField.superview.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
                
				return NO;
			}
		}
	}
    
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[self scrollTableViewCell:textField];
    
	if ([textField.text isEqualToString:TEXT_OF_NULL]) {
		textField.text = @"";
	}
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if ([AMUtilities isEmpty:textField.text]) {
		textField.text = TEXT_OF_NULL;
	}
    
	NSInteger iType = textField.tag % 1000;
	NSInteger iSection = (textField.tag - iType) / 1000;
    
	if (iSection == [self.arrVerificationInfos count]) {
		AMAssetRequest *aAssetRequest = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
        
		switch (iType) {
			case VerificationTextInputType_MachineType:
			case VerificationTextInputType_VerifiedDate:
			case VerificationTextInputType_Asset:
			case VerificationTextInputType_Serial:
			case VerificationTextInputType_UpdatedAsset:
			case VerificationTextInputType_UpdatedSerial:
			{
			}
                break;
                
			case VerificationTextInputType_AddMachineNumber:
			{
                aAssetRequest.machineNumber =  [textField.text isEqualToString:TEXT_OF_NULL] ? @"" : textField.text;
			}
                break;
                
			case VerificationTextInputType_AddSerialNumber:
			{
                aAssetRequest.serialNumber = [textField.text isEqualToString:TEXT_OF_NULL] ? @"" : textField.text;
			}
                break;
                
			case VerificationTextInputType_AddPointOfService:
			{
			}
                break;
                
			case VerificationTextInputType_AddLocation:
			{
                if ([textField.text isEqualToString:TEXT_OF_NULL]) {
                    aAssetRequest.locationID = nil;
                    [dicAddInfo setObject:@"" forKey:KEY_OF_LOCATION];
                    return;
                }
                aAssetRequest.locationID = nil;
                [dicAddInfo setObject:textField.text forKey:KEY_OF_LOCATION];
            }
                break;
		}
	}
	else {
		NSIndexPath *indexPath = [AMUtilities indexPathForView:textField inTableView:self.mainTableView];
		NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:indexPath.section];
		AMAssetRequest *aAsset = [dicInfos objectForKey:KEY_OF_ASSETREQUEST_INFO];
        
		switch (iType) {
			case VerificationTextInputType_MachineType:
			case VerificationTextInputType_VerifiedDate:
			case VerificationTextInputType_Asset:
			case VerificationTextInputType_Serial:
			{
			}
                break;
                
			case VerificationTextInputType_UpdatedAsset:
			{
                aAsset.updatedMNumber = [textField.text isEqualToString:TEXT_OF_NULL] ? @"" : textField.text;
			}
                break;
                
			case VerificationTextInputType_UpdatedSerial:
			{
                aAsset.updatedSNumber = [textField.text isEqualToString:TEXT_OF_NULL] ? @"" : textField.text;
			}
                break;
                
			case VerificationTextInputType_AddPointOfService:
			case VerificationTextInputType_AddSerialNumber:
			case VerificationTextInputType_AddLocation:
			case VerificationTextInputType_AddMachineNumber:
			{
			}
                break;
		}
	}
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSInteger iType = textField.tag % 1000;
    NSInteger iSection = (textField.tag - iType) / 1000;
    
    if (iSection < [self.arrVerificationInfos count]) {
        
        switch (iType) {
            case VerificationTextInputType_MachineType:
            case VerificationTextInputType_VerifiedDate:
            case VerificationTextInputType_Asset:
            case VerificationTextInputType_Serial:
            {
            }
                break;
                
            case VerificationTextInputType_UpdatedAsset:
            {
                NSMutableString *text = [textField.text mutableCopy];
                [text replaceCharactersInRange:range withString:string];
                return [text length] <= 30;
            }
                break;
                
            case VerificationTextInputType_UpdatedSerial:
            case VerificationTextInputType_AddPointOfService:
            case VerificationTextInputType_AddSerialNumber:
            case VerificationTextInputType_AddLocation:
            case VerificationTextInputType_AddMachineNumber:
            {
            }
                break;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSInteger iType = textField.tag % 1000;
	NSInteger iSection = (textField.tag - iType) / 1000;
    
	if (iSection == [self.arrVerificationInfos count]) {
		[self.view endEditing:YES];
	}
	else {
		NSIndexPath *indexPath = [AMUtilities indexPathForView:textField inTableView:self.mainTableView];
        
		[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
	}
	return YES;
}

#pragma mark -

- (void)scrollTableViewCell:(UITextField *)textField {
	NSIndexPath *indexPath = [AMUtilities indexPathForView:textField inTableView:self.mainTableView];
	[self.mainTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark -

- (void)verificationSectionViewDidClickAddBtn:(AMVerificationAddSectionView *)aVerificationAddSectionView {
	[dicAddInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_NEEDSHOW];
	AMAssetRequest *asset = [[AMAssetRequest alloc] init];
	asset.posID = self.workOrder.posID;
	asset.status = TEXT_OF_NEW;
	[dicAddInfo setObject:asset forKey:KEY_OF_ADD_ASSETREQUEST_INFO];
	[dicAddInfo setObject:[NSNumber numberWithInteger:InfoType_AddingAsset] forKey:KEY_OF_INFOTYPE];
	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)verificationSectionViewDidClickCancelBtn:(AMVerificationAddSectionView *)aVerificationAddSectionView {
	[dicAddInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_NEEDSHOW];
    [dicAddInfo removeObjectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
    [dicAddInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_SELECT];

	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -

- (void)verificationSectionViewDidClickDropBtn:(AMVerificationSectionView *)aVerificationSectionView {
    [self.mainTableView endEditing:YES];
	for (NSMutableDictionary *dicInfo in self.arrVerificationInfos) {
		NSNumber *needShow = [dicInfo objectForKey:KEY_OF_NEEDSHOW];
        if ([self.arrVerificationInfos indexOfObject:dicInfo] == [aVerificationSectionView.strFlag intValue]) {
            if ([needShow boolValue]) {
                [dicInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_NEEDSHOW];
            }
            else {
                [dicInfo setObject:[NSNumber numberWithBool:YES] forKey:KEY_OF_NEEDSHOW];
            }
        }
	}
    
	[self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:aVerificationSectionView.section] withRowAnimation:UITableViewRowAnimationNone];
    
	DLog(@"dicInfo : %@", arrVerificationInfos);
}

#pragma mark -

- (void)verificationStatusTableViewController:(AMPopoverSelectTableViewController *)aVerificationStatusTableViewController didSelected:(NSMutableDictionary *)aInfo {
	if (aVerificationStatusTableViewController.tag == PopViewType_Select_VerificationStatus) {
		NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:aVerificationStatusTableViewController.aIndexPath.section];
		AMAsset *aAsset = [dicInfos objectForKey:KEY_OF_ASSET_INFO];
        
		NSString *strNewStatus = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE];
        
		if (![aAsset.verificationStatus isEqualToString:strNewStatus] && ([strNewStatus isEqualToString:MyLocal(TEXT_OF_VERIFED)] || [strNewStatus isEqualToString:TEXT_OF_VERIFED])) {
			aAsset.lastVerifiedDate = [NSDate date];
            if (![dicInfos objectForKey:KEY_OF_INITIAL_DATE]) {
                [dicInfos setObject:aAsset.lastVerifiedDate forKey:KEY_OF_INITIAL_DATE];
            }
		}
        
		aAsset.verificationStatus = strNewStatus;
        
		[aPopoverVC dismissPopoverAnimated:YES];
        if([[aInfo valueForKeyWithNullToNil:@"INFO"] isEqualToString:@"Move to Warehouse"])
        {
            [UIAlertView showWithTitle:@"Asset Condition" message:MyLocal(@"What is the asset's condition?") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"Working") otherButtonTitles:@[MyLocal(@"Not Working"), MyLocal(@"Missing")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if(buttonIndex == 1)
                {
                    //YES
                    aAsset.moveToWarehouse = @"Not Working";
                } else if (buttonIndex == 2) {
                    //NO
                    aAsset.moveToWarehouse = @"Missing";
                } else {
                    aAsset.moveToWarehouse = @"Working";
                }
            }];
        }
        
        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:aVerificationStatusTableViewController.aIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_Select_NormalLocation) {
        
        if ([[aInfo objectForKey:@"DATA"] isKindOfClass:[AMLocation class]])
        {
            //Existing location
            NSMutableDictionary *dicInfos = [self.arrVerificationInfos objectAtIndex:aVerificationStatusTableViewController.aIndexPath.section];
            AMAsset *aAsset = [dicInfos objectForKey:KEY_OF_ASSET_INFO];
            AMLocation *aLocation = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
            aAsset.locationID = aLocation.locationID;
            aAsset.assetLocation = aLocation;
            [aPopoverVC dismissPopoverAnimated:YES];
            [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:aVerificationStatusTableViewController.aIndexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        } else {
            
            //New User entered location
            [aPopoverVC dismissPopoverAnimated:YES];
            
           // UIAlertView *alertViewChangeName=[[UIAlertView alloc] sh
            [UIAlertView showWithTitle:@"Add Location" message:@"Add Location" style:UIAlertViewStylePlainTextInput cancelButtonTitle:MyLocal(@"Cancel") otherButtonTitles:@[MyLocal(@"OK")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
                if (buttonIndex > 0) {
                    NSString *textVal = [[NSString alloc] initWithString: [alertView textFieldAtIndex:0].text];
                    AMLocation *newLocation = [AMLocation new];
                    [newLocation setLocation:textVal];
                    
                    newLocation.accountID = self.workOrder.accountID;
                    
                    [[AMLogicCore sharedInstance] addLocation:newLocation completionBlock:^(NSInteger type, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (error) {
                                [SVProgressHUD showErrorWithStatus:MyLocal(@"Save Fail")];
                            } else {
                                [SVProgressHUD showSuccessWithStatus:MyLocal(@"Save Success")];
                            }
                        });
                    }];


                }
            }];
        }
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_Select_AddLocation) {
		AMVerificationAddTableViewCell *cell = (AMVerificationAddTableViewCell *)[self.mainTableView cellForRowAtIndexPath:aVerificationStatusTableViewController.aIndexPath];
        
		if ([[aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO] isEqualToString:TEXT_OF_ADD_NEW_LOCATION]) {
			[dicAddInfo setObject:[NSNumber numberWithBool:NO] forKey:KEY_OF_SELECT];
            [dicAddInfo setObject:@"" forKey:KEY_OF_LOCATION];
			cell.textFieldLocation.text = @"";
			[cell.textFieldLocation becomeFirstResponder];
		}
		else {
			AMAssetRequest *aAsset = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
			AMLocation *aLocation = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
			aAsset.locationID = aLocation.locationID;
			cell.textFieldLocation.text = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];
		}
        
		[aPopoverVC dismissPopoverAnimated:YES];
	}
	else if (aVerificationStatusTableViewController.tag == PopViewType_Select_AddStatus) {
        //Any time the status changes ie. New or Found is tapped, we need to update.
        [dicAddInfo setObject:@"" forKey:KEY_OF_MOVE_TO_WAREHOUSE];
        
		AMAssetRequest *aAsset = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
		aAsset.status = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count]] withRowAnimation:UITableViewRowAnimationNone];
        
		[aPopoverVC dismissPopoverAnimated:YES];
	}
    else if (aVerificationStatusTableViewController.tag == PopViewType_Select_MoveToWarehouse) {
//        AMAssetRequest *aAsset = [dicAddInfo objectForKey:KEY_OF_MOVE_TO_WAREHOUSE];
//        aAsset.status = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
//        aAsset.moveToWarehouse = @"Working";
//        
//        [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count]] withRowAnimation:UITableViewRowAnimationNone];
//        
//        [aPopoverVC dismissPopoverAnimated:YES];
        AMAssetRequest *aAsset = [dicAddInfo objectForKey:KEY_OF_ADD_ASSETREQUEST_INFO];
        aAsset.status = [aInfo objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
        
        [UIAlertView showWithTitle:@"Working/Not Working" message:MyLocal(@"Is equipment being returned in working condition?") style:UIAlertViewStyleDefault cancelButtonTitle:MyLocal(@"NO") otherButtonTitles:@[MyLocal(@"YES")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if(buttonIndex > 0)
            {
                //YES
                aAsset.moveToWarehouse = @"Working";
            } else {
                //NO
                aAsset.moveToWarehouse = @"Not Working";
            }
        }];
    }
}

- (void)acquireLocationFor:(AMAssetRequest *)aAssetRequest withLocation:(NSString *)strLocation
{
    if (![AMUtilities isEmpty:aAssetRequest.locationID]) {
        return;
    }
    
    __block NSString *aLocationId = @"";
    
    AMLocation *aLocation = [[AMLocation alloc] init];
    aLocation.accountID = self.workOrder.accountID;
    aLocation.location = strLocation;
    [[AMLogicCore sharedInstance] addLocation:aLocation completionBlock: ^(NSInteger type, NSError *error) {
        MAIN ( ^{
            if (error) {
                //
            }
            else {
                aLocationId = aLocation.locationID;
                aAssetRequest.locationID = aLocationId;
                [dicAddInfo setObject:@"" forKey:KEY_OF_LOCATION];
                [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count]] withRowAnimation:UITableViewRowAnimationNone];
                [self.mainTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.arrVerificationInfos count] -1] withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }];
}

@end
