//
//  AMWorkOrderViewController.m
//  AramarkFSP
//
//  Created by PwC on 4/28/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMWorkOrderViewController.h"
#import "AMEditTableViewCell.h"
#import "AMTextAreaTableViewCell.h"
#import "AMSectionFooterView.h"
#import "AMLogicCore.h"
#import "AMWorkOrder.h"
#import "AMAsset.h"
#import "AMCase.h"
#import "AMConfiguredCell.h"
#import "AMSectionHeaderAttachmentView.h"
#import "AMAttachmentTableViewCell.h"
#import "AMDBCustomerPrice+AddOn.h"

#define kAMDEFAULT_PREFERRED_TIME_START @"09:00"
#define kAMDEFAULT_PRIORITY MyLocal(@"Medium")
#define kAM_MACHINE_TYPE_CELL_TITLE MyLocal(@"Machine Type")

//#define isDemoVersion 1
static NSString *AttachmentCellIdentifier = @"AttachmentTableViewCell";

@interface AMWorkOrderViewController (){
    AMBaseTableViewCell *selectedCell;
    BOOL showAttachmentSection;
    BOOL isCreatingWOMode;
    NSDateFormatter *df;
    AMWorkOrder *newWO;
    AMEditTableViewCell *machineTypeCell; //will assign cell to this variable, to get changes update this cell display value after asset changed. should be better performance compared with iterating tableview's visibleCells
}

@end

@implementation AMWorkOrderViewController
@synthesize type;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithWorkOrder:(AMWorkOrder *)workOrder;
{
    self = [self initWithNibName:@"AMWorkOrderViewController" bundle:nil];
    if (self) {
        // Custom initialization
        self.assignedWorkOrder = workOrder; //Note: This will access setter for property assignedWorkOrder, please make sure don't call setter repeatedly.
    }
    return self;
}

- (id)initWithNewWorkOrder:(AMWorkOrder *)byWorkOrder
{
    self = [self initWithNibName:@"AMWorkOrderViewController" bundle:nil];
    if (self) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd"];
        isCreatingWOMode = YES;
        //new to set subject
        newWO = [[AMLogicCore sharedInstance] getFullWorkOrderInfoByID:byWorkOrder.woID];
        newWO.woNumber = nil;
        newWO.woID = nil;
        newWO.status = nil;
        newWO.caseDescription = newWO.woCase.caseDescription;
        newWO.createdDate = [NSDate date];
        newWO.createdByName = [USER_DEFAULT objectForKey:kAMLoggedUserNameKey];
        newWO.createdBy = [USER_DEFAULT objectForKey:USRDFTSELFUID];
        newWO.assignToMyself = [NSNumber numberWithBool:YES];

		if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_REPAIR]){
            newWO.woType = kAMWORK_ORDER_TYPE_REPAIR;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_REMOVAL]){
            newWO.woType = kAMWORK_ORDER_TYPE_REMOVAL;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_MOVE]){
            newWO.woType = kAMWORK_ORDER_TYPE_MOVE;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_SWAP]){
            newWO.woType = kAMWORK_ORDER_TYPE_SWAP;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_EXCHANGE]){
            newWO.woType = kAMWORK_ORDER_TYPE_EXCHANGE;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_INSTALL]){
            newWO.woType = kAMWORK_ORDER_TYPE_INSTALL;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_PM]){
            newWO.woType = kAMWORK_ORDER_TYPE_PM;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_ASSETVERIFICATION]){
            newWO.woType = kAMWORK_ORDER_TYPE_ASSETVERIFICATION;
        }
        else if ([newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_SITESURVEY]){
            newWO.woType = kAMWORK_ORDER_TYPE_SITESURVEY;
        }
		
		/*
        if (![newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_REPAIR]
            && ![newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_MOVE]
            && ![newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_REMOVAL]
            && ![newWO.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_SWAP])
        {
            newWO.woType = kAMWORK_ORDER_TYPE_REPAIR;
        }
		*/

        newWO.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:newWO.woType forObject:RECORD_TYPE_OF_WORK_ORDER];
        [self setupWorkOrder:newWO];
    }
    return self;
}

- (void)setupWorkOrder:(AMWorkOrder *)workOrder
{
    if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_REPAIR]) {
        self.type = WORKORDERType_Repair;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_SWAP]) {
        self.type = WORKORDERType_Swap;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_SITESURVEY]) {
        self.type = WORKORDERType_SiteSurvey;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_REMOVAL]) {
        self.type = WORKORDERType_Removal;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_PM]) {
        self.type = WORKORDERType_PM;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_MOVE]) {
        self.type = WORKORDERType_Move;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_INSTALL]) {
        self.type = WORKORDERType_Install;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_EXCHANGE]) {
        self.type = WORKORDERType_Exchange;
    } else if ([workOrder.woType isEqualToLocalizedString:kAMWORK_ORDER_TYPE_ASSETVERIFICATION]) {
        self.type = WORKORDERType_AssetVerification;
    }
    [self setupDataSourceByRecordType:self.type workOrderObj:workOrder];
    machineTypeCell = nil;
}

- (NSDictionary *)assembDictionaryValue1:(NSString *)proName value2:(NSString *)proValue
{
    if (!proName) {
        DLog(@"proName is NOT supposed be nil");
        return nil;
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:proName, kAMPROPERTY_NAME, proValue ? proValue : @"", kAMPROPERTY_VALUE,  nil];
}

- (void)setupDataSourceByRecordType:(WORKORDERType)recordType workOrderObj:(AMWorkOrder *)workOrderObj
{
    switch (recordType) {
        case WORKORDERType_Repair:
        {
            _dataArr = [NSMutableArray array];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Asset" value:workOrderObj.woAsset.assetName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Asset" propertyDic:[self assembDictionaryValue1:@"assetID" value2:[NSString stringWithFormat:@"%@%@%@", workOrderObj.woAsset.machineNumber ? workOrderObj.woAsset.machineNumber : @"", workOrderObj.woAsset.machineNumber && workOrderObj.woAsset.productName ? @"-" : @"", workOrderObj.woAsset.productName ? workOrderObj.woAsset.productName : @""]] isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Under Warranty" value:[workOrderObj.warranty isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
        }
            break;
        case WORKORDERType_Swap:
        {
            _dataArr = [NSMutableArray array];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Asset" value:workOrderObj.woAsset.assetName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Asset" propertyDic:[self assembDictionaryValue1:@"assetID" value2:[NSString stringWithFormat:@"%@%@%@", workOrderObj.woAsset.machineNumber ? workOrderObj.woAsset.machineNumber : @"", workOrderObj.woAsset.machineNumber && workOrderObj.woAsset.productName ? @"-" : @"", workOrderObj.woAsset.productName ? workOrderObj.woAsset.productName : @""]] isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Under Warranty" value:[workOrderObj.warranty isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Accessories Required" propertyDic:[self assembDictionaryValue1:@"accessoriesRequired" value2:workOrderObj.accessoriesRequired] isEditable:YES]];
        }
            break;
        case WORKORDERType_SiteSurvey:
        {
            _dataArr = [NSMutableArray array];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Location" value:workOrderObj.workLocation isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
             [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
        }
            break;
        case WORKORDERType_Removal:
        {
            _dataArr = [NSMutableArray array];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Asset" value:workOrderObj.woAsset.assetName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Asset" propertyDic:[self assembDictionaryValue1:@"assetID" value2:[NSString stringWithFormat:@"%@%@%@", workOrderObj.woAsset.machineNumber ? workOrderObj.woAsset.machineNumber : @"", workOrderObj.woAsset.machineNumber && workOrderObj.woAsset.productName ? @"-" : @"", workOrderObj.woAsset.productName ? workOrderObj.woAsset.productName : @""]] isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Under Warranty" value:[workOrderObj.warranty isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
        }
            break;
        case WORKORDERType_PM:
        {
            _dataArr = [NSMutableArray array];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Asset" value:workOrderObj.woAsset.assetName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Asset" propertyDic:[self assembDictionaryValue1:@"assetID" value2:[NSString stringWithFormat:@"%@%@%@", workOrderObj.woAsset.machineNumber ? workOrderObj.woAsset.machineNumber : @"", workOrderObj.woAsset.machineNumber && workOrderObj.woAsset.productName ? @"-" : @"", workOrderObj.woAsset.productName ? workOrderObj.woAsset.productName : @""]] isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Under Warranty" value:[workOrderObj.warranty isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Last Service Date" value:[df stringFromDate:workOrderObj.lastServiceDate] isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
        }
            break;
        case WORKORDERType_Move:
        {
            _dataArr = [NSMutableArray array];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
//                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"New Location" value:workOrderObj.toWorkLocation isEditable:NO]];

            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"New Location" propertyDic:[self assembDictionaryValue1:@"toLocationID" value2:workOrderObj.toLocationName] isEditable:YES]];
//            [
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Asset" value:workOrderObj.woAsset.assetName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Asset" propertyDic:[self assembDictionaryValue1:@"assetID" value2:[NSString stringWithFormat:@"%@%@%@", workOrderObj.woAsset.machineNumber ? workOrderObj.woAsset.machineNumber : @"", workOrderObj.woAsset.machineNumber && workOrderObj.woAsset.productName ? @"-" : @"", workOrderObj.woAsset.productName ? workOrderObj.woAsset.productName : @""]] isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Under Warranty" value:[workOrderObj.warranty isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
             [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Filter Type" propertyDic:[self assembDictionaryValue1:@"filterType" value2:workOrderObj.filterTypeName]  isEditable:NO]];
             [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Total Number of Filters" propertyDic:[self assembDictionaryValue1:@"filterCount" value2:[workOrderObj.filterCount stringValue]]  isEditable:YES]];
             [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Accessories Required" propertyDic:[self assembDictionaryValue1:@"accessoriesRequired" value2:workOrderObj.accessoriesRequired]  isEditable:YES]];
        }
            break;
        case WORKORDERType_Install:
        {
            _dataArr = [NSMutableArray array];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.productName isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Product Type" value:workOrderObj.productName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Filter Type" propertyDic:[self assembDictionaryValue1:@"filterType" value2:workOrderObj.filterTypeName]  isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Total Number of Filters" propertyDic:[self assembDictionaryValue1:@"filterCount" value2:[workOrderObj.filterCount stringValue]]  isEditable:YES]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Accessories Required" propertyDic:[self assembDictionaryValue1:@"accessoriesRequired" value2:workOrderObj.accessoriesRequired]  isEditable:YES]];
        }
            break;
        case WORKORDERType_Exchange:
        {
            _dataArr = [NSMutableArray array];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Current Location" value:workOrderObj.workLocation isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Last Service Date" value:[df stringFromDate:workOrderObj.lastServiceDate] isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Filter Type" propertyDic:[self assembDictionaryValue1:@"filterType" value2:workOrderObj.filterTypeName]  isEditable:NO]];
//            NSArray *filtersArray = [NSArray arrayWithArray: [[AMDBManager sharedInstance] getFilterListByWOID:workOrderObj.woID]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Filter Type" propertyDic:[self assembDictionaryValue1:@"filterType" value2:workOrderObj.filterTypeName] isEditable:YES]];
 
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Total Number of Filters" propertyDic:[self assembDictionaryValue1:@"filterCount" value2:[workOrderObj.filterCount stringValue]]  isEditable:YES]];
        }
            break;
        case WORKORDERType_AssetVerification:
        {
            _dataArr = [NSMutableArray array];
            
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"WO #" value:workOrderObj.woNumber isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Contact" value:workOrderObj.contact isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Point of Service" value:workOrderObj.woPoS.name isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Location" value:workOrderObj.workLocation isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Asset" value:workOrderObj.woAsset.assetName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Asset" propertyDic:[self assembDictionaryValue1:@"assetID" value2:[NSString stringWithFormat:@"%@%@%@", workOrderObj.woAsset.machineNumber ? workOrderObj.woAsset.machineNumber : @"", workOrderObj.woAsset.machineNumber && workOrderObj.woAsset.productName ? @"-" : @"", workOrderObj.woAsset.productName ? workOrderObj.woAsset.productName : @""]] isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Machine Type" value:workOrderObj.machineTypeName isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Complaint Code" propertyDic:[self assembDictionaryValue1:@"complaintCode" value2:workOrderObj.complaintCode] isEditable:isCreatingWOMode]];
             [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Under Warranty" value:[workOrderObj.warranty isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Call Ahead" propertyDic:[self assembDictionaryValue1:@"callAhead" value2:[workOrderObj.callAhead isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:isCreatingWOMode]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Preferred Scheduled Time" value:[self preferredScheduledTime:workOrderObj.preferrTimeFrom toTime:workOrderObj.preferrTimeTo] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Vend Key" propertyDic:[self assembDictionaryValue1:@"vendKey" value2:workOrderObj.vendKey]  isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Status" value:workOrderObj.status isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Subject" propertyDic:[self assembDictionaryValue1:@"subject" value2:workOrderObj.subject] isEditable:isCreatingWOMode]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeTextArea title:@"Work Order Description" propertyDic:[self assembDictionaryValue1:@"workOrderDescription" value2:workOrderObj.workOrderDescription]  isEditable:YES]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Parking Detail" value:workOrderObj.parkingDetail isEditable:NO]];
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created Date" value:[df stringFromDate:workOrderObj.createdDate] isEditable:NO]];
            if (!isCreatingWOMode) {
                [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Age(hours)" value:[workOrderObj.age stringValue] isEditable:NO]];
            }
            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Created By" value:workOrderObj.createdByName isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Filter Type" propertyDic:[self assembDictionaryValue1:@"filterType" value2:workOrderObj.filterTypeName]  isEditable:NO]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Total Number of Filters" propertyDic:[self assembDictionaryValue1:@"filterCount" value2:[workOrderObj.filterCount stringValue]]  isEditable:YES]];
//            [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeEdit title:@"Accessories Required" propertyDic:[self assembDictionaryValue1:@"accessoriesRequired" value2:workOrderObj.accessoriesRequired]  isEditable:YES]];
        }
            break;
            
        default:
            break;
    }
    if (isCreatingWOMode) { //adding additional fields for editable if create new wo
        [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeCheckBox title:@"Assign To Myself" propertyDic:[self assembDictionaryValue1:@"assignToMyself" value2:[workOrderObj.assignToMyself isEqualToNumber:[NSNumber numberWithInt:1]] ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO] isEditable:YES]];
        [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Priority" propertyDic:[self assembDictionaryValue1:@"priority" value2:workOrderObj.priority ? workOrderObj.priority : kAMDEFAULT_PRIORITY] isEditable:YES]];
        newWO.estimatedDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60];
        NSString *dateStr = [df stringFromDate:newWO.estimatedDate];
        [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Estimated Date" propertyDic:[self assembDictionaryValue1:@"estimatedDate" value2:dateStr] isEditable:YES]];
        [_dataArr addObject:[[AMConfiguredCell alloc] initWithCellType:AMCellTypeDropDown title:@"Preferred Time Start" propertyDic:[self assembDictionaryValue1:@"preferrTimeFrom" value2:workOrderObj.preferrTimeFrom ? workOrderObj.preferrTimeFrom : kAMDEFAULT_PREFERRED_TIME_START] isEditable:YES]];
        newWO.preferrTimeFrom = workOrderObj.preferrTimeFrom ? workOrderObj.preferrTimeFrom : kAMDEFAULT_PREFERRED_TIME_START;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateFormat:AMDATE_FORMATTER_STRING_STANDARD];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter/Getter
- (void)setAssignedWorkOrder:(AMWorkOrder *)assignedWorkOrder
{
    isCreatingWOMode = NO;
    _assignedWorkOrder = assignedWorkOrder;
    [self setupWorkOrder:assignedWorkOrder];
    [self.tableView reloadData];
    //Checking whether account or POS data is in local DB, if not should call service to retrieve WO related data
    if (!self.assignedWorkOrder.woAccount || !self.assignedWorkOrder.woPoS) {
        [UIAlertView showWithTitle:@"" message:MyLocal(@"Would you like to retrieve work order related information from Server?") cancelButtonTitle:MyLocal(@"NO") otherButtonTitles:@[MyLocal(@"YES")] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == [alertView cancelButtonIndex]) {
                return;
            }
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeClear];
            [[AMLogicCore sharedInstance] getWorkOrderRequiredInfo:@[assignedWorkOrder.woID] withCompletionBlock:^(NSInteger type, NSError *error, id userData, id responseData) {
                BOOL isSuccess = ((NSNumber *)[responseData valueForKeyWithNullToNil:@"isSuccess"]).boolValue;
                if (isSuccess) {
                    NSDictionary *dataDic = [[AMProtocolParser sharedInstance] parseWorkOrderRequiredInfo:responseData];
                    [[AMDBManager sharedInstance] saveAsyncInitialSyncLoadList:dataDic checkExist:YES completion:^(NSInteger type, NSError *error) {
                        dispatch_async(dispatch_get_main_queue(), ^{//notify ui to refresh today's wo list
                            NSMutableDictionary * userInfo = [NSMutableDictionary dictionary];
                            
                            [userInfo setObject:TYPE_OF_REFRESH_WORKORDERLIST forKey:KEY_OF_TYPE];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FROM_LOGICCORE object:userInfo];
                        });
                    }];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if (!isSuccess) {
                        [AMUtilities showAlertWithInfo:MyLocal(@"Failed")];
                    }
                });
                
            }];
        }];
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            AMConfiguredCell *configuredCell = [self.dataArr objectAtIndex:indexPath.row];
            switch (configuredCell.cellType) {
                case AMCellTypeEdit:
                {
                    AMEditTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAMCellIdentifierEdit];
                    if (!cell) {
                        cell = (AMEditTableViewCell *)[AMUtilities loadViewByClassName:NSStringFromClass([AMEditTableViewCell class]) fromXib:nil];
                    }
                    cell.delegate = self;
                    cell.configuredCell = configuredCell;
                    if ([configuredCell.cellTitle isEqualToString:kAM_MACHINE_TYPE_CELL_TITLE]) {
                        machineTypeCell = cell;
                    }
                    return cell;
                }
                    break;
                case AMCellTypeCheckBox:
                {
                    AMCheckBoxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAMCellIdentifierCheckBox];
                    if (!cell) {
                        cell = (AMCheckBoxTableViewCell *)[AMUtilities loadViewByClassName:NSStringFromClass([AMCheckBoxTableViewCell class]) fromXib:nil];
                    }
                    cell.delegate = self;
                    cell.configuredCell = configuredCell;
                    return cell;
                }
                    break;
                case AMCellTypeDropDown:
                {
                    AMDropdownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAMCellIdentifierDropdown];
                    if (!cell) {
                        cell = (AMDropdownTableViewCell *)[AMUtilities loadViewByClassName:NSStringFromClass([AMDropdownTableViewCell class]) fromXib:nil];
                    }
                    cell.delegate = self;
                    cell.configuredCell = configuredCell;
                    cell.accountId = isCreatingWOMode ? newWO.accountID : self.assignedWorkOrder.accountID;
                    cell.posId = isCreatingWOMode ? newWO.posID : self.assignedWorkOrder.posID;
                    cell.woID = self.assignedWorkOrder.woID;
                    
                    return cell;
                }
                    break;
                case AMCellTypeTextArea:
                {
                    AMTextAreaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAMCellIdentifierTextArea];
                    if (!cell) {
                        cell = (AMTextAreaTableViewCell *)[AMUtilities loadViewByClassName:NSStringFromClass([AMTextAreaTableViewCell class]) fromXib:nil];
                    }
                    cell.delegate = self;
                    cell.configuredCell = configuredCell;
                    return cell;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 1:
        {
//            AMAttachmentTableViewCell *attachCell = [AMUtilities loadViewByClassName:NSStringFromClass([AMAttachmentTableViewCell class]) fromXib:@"AMAttachmentTableViewCell"];
            AMAttachmentTableViewCell *aCell;
            aCell = [self.tableView dequeueReusableCellWithIdentifier:AttachmentCellIdentifier];
            if (!aCell) {
                aCell = [[AMAttachmentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AttachmentCellIdentifier];
            }
            
            aCell.workOrder = self.assignedWorkOrder;
            return aCell;
        }
            break;
            
        default:
            break;
    }
    
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (isCreatingWOMode) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.dataArr count];
            break;
            
        case 1:
            return showAttachmentSection ? 1 : 0;
            break;
        default:
            break;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
        {
            AMSectionHeaderView *sectionHeaderView = [AMUtilities loadViewByClassName:NSStringFromClass([AMSectionHeaderView class]) fromXib:nil];
            NSString *titleStr;
            if (isCreatingWOMode) {
                titleStr = [NSString stringWithFormat:@"[%@ ⌄]", MyLocal(newWO.woType)];
            } else {
                titleStr = [NSString stringWithFormat:@"[%@]", MyLocal(self.assignedWorkOrder.woType)];
            }
            NSString *sectionTitle = titleStr;
            [sectionHeaderView.recordTypeButton setTitle:sectionTitle forState:UIControlStateNormal];
            [sectionHeaderView.recordTypeButton setEnabled:isCreatingWOMode];
            [sectionHeaderView.buttonDropDown setHidden:!isCreatingWOMode];
            sectionHeaderView.delegate = self;
            return sectionHeaderView;
        }
            break;
        
        case 1:
        {
            AMSectionHeaderAttachmentView *headerView = [AMUtilities loadViewByClassName:NSStringFromClass([AMSectionHeaderAttachmentView class]) fromXib:nil];
            [headerView.attachmentButton setSelected:showAttachmentSection];
            headerView.delegate = self;
            return headerView;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[AMAttachmentTableViewCell class]]) {
        return;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    AMSectionFooterView *footerView;
    switch (section) {
        case 0:
        {
            
        }
            break;
            
        case 1:
        {
            footerView = [AMUtilities loadViewByClassName:NSStringFromClass([AMSectionFooterView class]) fromXib:nil];
            [footerView.createButton setHidden:YES];
            footerView.delegate = self;
            return footerView;
        }
            break;
            
        default:
            break;
    }
    if (isCreatingWOMode) {
        footerView = [AMUtilities loadViewByClassName:NSStringFromClass([AMSectionFooterView class]) fromXib:nil];
        [footerView.createButton setHidden:YES];
        footerView.delegate = self;
    }
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float height = 0.0;
    switch (section) {
        case 0:
        {

        }
            break;
            
        case 1:
//            return 85.0;
            return 50.0;
            break;
            
        default:
            break;
    }
    if (isCreatingWOMode) {
        height = 50.0;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            AMConfiguredCell *cellContentObj = [_dataArr objectAtIndex:indexPath.row];
            if (cellContentObj.cellType == AMCellTypeTextArea) {
                return 120.0;
            }
            return 40.0;
        }
            break;
            
        case 1:
        {
            return 160.0;
        }
            break;
            
        default:
            break;
    }
    return 40.0;
}

#pragma mark - AMSectionFooterViewDelegate
- (void)didTappedOnSaveButton
{
    if (selectedCell) {
        [selectedCell endEditing:YES];
    }
    if (isCreatingWOMode) {//reset for Create New Work Order
        if (!newWO.workOrderDescription || [newWO.workOrderDescription length] == 0) {
//            [SVProgressHUD showErrorWithStatus:MyLocal(@"Work Order Description is required.") duration:2];
            [AMUtilities showAlertWithInfo:MyLocal(@"Work Order Description is required.")];
            return;
        }
        if (!newWO.preferrTimeFrom) {
//            [SVProgressHUD showErrorWithStatus:MyLocal(@"Preferred Time Start is required")];
            [AMUtilities showAlertWithInfo:MyLocal(@"Preferred Time Start is required")];
            return;
        }
        [[AMLogicCore sharedInstance] createNewWorkOrderInDBWithAMWorkOrder:newWO additionalSetupBlock:^(AMDBNewWorkOrder *newWorkOrder) {
            if (!newWorkOrder.machineTypeID) {
                newWorkOrder.machineTypeID = newWO.woAsset.productID;
            }
        } completion:^(NSInteger type, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:MyLocal(@"Save Success")];
                    [self dismissViewControllerAnimated:YES completion:^(void){
                        if (self.delegate && [self.delegate respondsToSelector:@selector(didSaveNewWorkOrder:)]) {
                            [self.delegate didSaveNewWorkOrder:YES];
                        }
                    }];
                });
            }
        }];
        
        return;
    }
    [[AMLogicCore sharedInstance] updateWorkOrder:self.assignedWorkOrder completionBlock:^(NSInteger type, NSError *error) {
        if (error) {
            DLog(@"%@", [error localizedDescription]);
        } else {
            [SVProgressHUD showSuccessWithStatus:MyLocal(@"Save Success")];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_WORK_ORDER_NEED_REFRESH object:self.assignedWorkOrder];
        }
        
    }];
}

- (void)didTappedOnCreateButton
{
    if (!newWO) {
        newWO = [self.assignedWorkOrder mutableCopy]; //Deep Copy to alloc new AMWorkOrder Object, set newWO as nil once create new work order successfully.
    }
    AMWorkOrderViewController *newWOVC = [[AMWorkOrderViewController alloc] initWithNewWorkOrder:newWO];
    newWOVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:newWOVC animated:YES completion:nil];
}

#pragma mark - AMBaseTableViewCellDelegate
- (void)textViewStartEditing:(UITextView *)textView withCellObj:(AMBaseTableViewCell *)cellObj
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTING_EDITING_MODE object:nil];
    [AMUtilities animateScrollView:self.tableView subView:cellObj showKeyboard:YES];
    selectedCell = cellObj;
}

- (void)textViewEndEditing:(UITextView *)textView withCellObj:(AMBaseTableViewCell *)cellObj
{
    AMWorkOrder *wo = self.assignedWorkOrder;
    if (isCreatingWOMode) {
        wo = newWO;
    }
    [AMUtilities animateScrollView:self.tableView subView:cellObj showKeyboard:NO];
    if (cellObj.configuredCell.propertyName) {
        [wo setValue:textView.text forKey:cellObj.configuredCell.propertyName];
        AMConfiguredCell *newCC = cellObj.configuredCell;
        newCC.cellValue = textView.text;
        cellObj.configuredCell = newCC;
    }
    if ([cellObj isKindOfClass:[AMTextAreaTableViewCell class]]) {
        AMTextAreaTableViewCell *cell = (AMTextAreaTableViewCell *)cellObj;
        [cell editButtonTapped:nil];
    }
    selectedCell = nil;
}

- (void)textFieldStartEditing:(UITextField *)textField withCellObj:(AMBaseTableViewCell *)cellObj
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STARTING_EDITING_MODE object:nil];
    [AMUtilities animateScrollView:self.tableView subView:cellObj showKeyboard:YES];
    selectedCell = cellObj;
    if (cellObj.configuredCell.propertyName && [cellObj.configuredCell.propertyName isEqualToString:@"filterCount"]) {
        if ([textField.text isEqualToString:@"0"]) {
            textField.text = @"";
        }
    }
}

- (void)textFieldEndEditing:(UITextField *)textField withCellObj:(AMBaseTableViewCell *)cellObj
{
    AMWorkOrder *wo = self.assignedWorkOrder;
    if (isCreatingWOMode) {
        wo = newWO;
    }
    [AMUtilities animateScrollView:self.tableView subView:cellObj showKeyboard:NO];
    if (cellObj.configuredCell.propertyName) {
        if ([cellObj.configuredCell.propertyName isEqualToString:@"filterCount"]) {
//            if ([textField.text length] > 3 || ![AMUtilities isValidIntegerValueTyped:textField.text]) {
//                [SVProgressHUD showErrorWithStatus:@"The value of Total Number of Filters is invalid." duration:2.0];
//                textField.text = @"0";
////                [textField becomeFirstResponder];
//                return;
//            }
            [wo setValue:@([textField.text intValue]) forKey:cellObj.configuredCell.propertyName];
        } else {
            [wo setValue:textField.text forKey:cellObj.configuredCell.propertyName];
        }
        AMConfiguredCell *newCC = cellObj.configuredCell;
        newCC.cellValue = textField.text;
        cellObj.configuredCell = newCC;
        
    }
    if ([cellObj isKindOfClass:[AMEditTableViewCell class]]) {
        AMEditTableViewCell *cell = (AMEditTableViewCell *)cellObj;
        [cell editButtonTapped:nil];
    }
    selectedCell = nil;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string withCellObj:(AMBaseTableViewCell *)cellObj
{
    BOOL isValid = YES;
    if (cellObj.configuredCell.propertyName)
    {
        if ([cellObj.configuredCell.propertyName isEqualToString:@"filterCount"]) {
            NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
            BOOL isValid;
            if ([newString length] == 0) {
                isValid = YES;
            } else {
                isValid = [AMUtilities isValidIntegerValueTyped:newString];
            }
            return isValid && [newString length] <= 3;
        } else if ([cellObj.configuredCell.propertyName isEqualToString:@"accessoriesRequired"]){
            return [textField.text length] < 255 ? YES : NO;
        }
        
    }
    
    return isValid;
}

#pragma mark - AMDropdownTableViewCellDelegate
- (void)didSelectPopoverDictionary:(NSDictionary *)dicValue cellObj:(AMDropdownTableViewCell *)cellObj
{
    AMWorkOrder *wo = self.assignedWorkOrder;
    if (isCreatingWOMode) {
        wo = newWO;
    }
    if (cellObj.configuredCell.propertyName) {
        if ([cellObj.configuredCell.propertyName isEqualToString:@"toLocationID"]) {
            AMLocation *location = [dicValue objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
            wo.toLocationID = location.locationID;
            wo.toLocationName = location.location;
        } else if ([cellObj.configuredCell.propertyName isEqualToString:@"assetID"]) {
            AMAsset *asset = [dicValue objectForKey:kAMPOPOVER_DICTIONARY_KEY_DATA];
            wo.assetID = asset.assetID;
            wo.machineType = asset.productID;
            wo.machineTypeName = asset.productName;
            //To update Machine Type Cell
            if (machineTypeCell) {
//                machineTypeCell.configuredCell.cellValue = asset.productName;
                AMConfiguredCell *newCC = machineTypeCell.configuredCell;
                newCC.cellValue = asset.productName;
                machineTypeCell.configuredCell = newCC;
            }
        } else {
            if ([dicValue objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE]) {
                [wo setValue:[dicValue objectForKey:kAMPOPOVER_DICTIONARY_KEY_VALUE] forKey:cellObj.configuredCell.propertyName];
            } else {
                [wo setValue:[dicValue objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO] forKey:cellObj.configuredCell.propertyName];
            }
            
        }
    }
    AMConfiguredCell *newCC = cellObj.configuredCell;
    newCC.cellValue = [dicValue objectForKey:kAMPOPOVER_DICTIONARY_KEY_INFO];

    cellObj.configuredCell = newCC;
}

- (void)dateChoosed:(NSDate *)date cellObj:(AMDropdownTableViewCell *)cellObj
{
    if (cellObj.configuredCell.propertyName) {
        [newWO setValue:date forKey:cellObj.configuredCell.propertyName];
        AMConfiguredCell *newCC = cellObj.configuredCell;
        newCC.cellValue = [df stringFromDate:date];
        cellObj.configuredCell = newCC;
    }
}

#pragma mark - Private Methods
- (NSString *)preferredScheduledTime:(NSString *)fromDate toTime:(NSString *)toDate
{
    NSString *timeStr = @"";
    if (!fromDate || !toDate) {
        return timeStr;
    }
    timeStr = [NSString stringWithFormat:@"%@ ~ %@", fromDate, toDate];
    return timeStr;
}

#pragma mark - AMSectionHeaderAttachmentViewDelegate
- (void)didSelectedOnAttachmentButton:(BOOL)isSelected
{
    showAttachmentSection = isSelected;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    if (showAttachmentSection) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark - AMSectionHeaderViewDelegate
- (void)didTappedOnPopoverRecordType:(NSString *)recordType
{
    //For newWO, pre-populate the value of the assignedWorkOrder to newWO, except woNumber, woID, woType, caseDescription
    
    newWO.woType = recordType;
    newWO.recordTypeID = [[AMLogicCore sharedInstance] getRecordTypeIdByName:recordType forObject:RECORD_TYPE_OF_WORK_ORDER];
    [self setupWorkOrder:newWO];
    [self.tableView reloadData];
}

- (void)didCancelCreatingNewWO
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AMCheckBoxTableViewCellDelegate
- (void)checkboxIsChecked:(BOOL)boolValue cellObj:(AMCheckBoxTableViewCell *)cellObj
{
    if (cellObj.configuredCell.propertyName) {
        if (isCreatingWOMode) {
            [newWO setValue:[NSNumber numberWithBool:boolValue] forKey:cellObj.configuredCell.propertyName];
            AMConfiguredCell *newCC = cellObj.configuredCell;
            newCC.cellValue = boolValue ? kAMBOOL_STRING_YES : kAMBOOL_STRING_NO;
            cellObj.configuredCell = newCC;
        }
    }
}

@end
