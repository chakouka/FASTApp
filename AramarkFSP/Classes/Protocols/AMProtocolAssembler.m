//
//  AMProtocolAssembler.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMProtocolAssembler.h"
#import "AMLocation.h"
#import "AMWorkOrder.h"
#import "AMEvent.h"
#import "AMAsset.h"
#import "AMInvoice.h"
#import "AMLocation.h"
#import "AMPoS.h"
#import "AMFilterUsed.h"
#import "AMPartsUsed.h"
#import "AMAssetRequest.h"
#import "NSData+Base64.h"
#import "AMUser.h"
#import "AMProtocolParser.h"

@implementation AMProtocolAssembler

+ (AMProtocolAssembler *)sharedInstance;
{
    static AMProtocolAssembler *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMProtocolAssembler alloc] init];
    });
    
    return sharedInstance;
}

- (NSMutableDictionary *)getLocationDict:(AMLocation *)location
{
    NSMutableDictionary * locationDict = [NSMutableDictionary dictionary];
    
    if (location.addtionalNotes) {
        [locationDict setObject:location.addtionalNotes forKey:@"Additional_Notes__c"];
    }
    if (location.badgeNeeded) {
        if ([location.badgeNeeded intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Badge_Needed_for_Access__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Badge_Needed_for_Access__c"];
        }
        
    }
    if (location.cabinetHeight) {
        [locationDict setObject:location.cabinetHeight forKey:@"Cabinet_Height_inches__c"];
    }
    if (location.dockAvailable) {
        if ([location.dockAvailable intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Dock_Available__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Dock_Available__c"];
        }
    }
    if (location.doorsRemoved) {
        if ([location.doorsRemoved intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Doors_to_be_Removed_for_Vending_Equip__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Doors_to_be_Removed_for_Vending_Equip__c"];
        }
    }
    if (location.doorwayWidth) {
        [locationDict setObject:location.doorwayWidth forKey:@"Doorway_Width_inches__c"];
    }
    if (location.electricOutlet) {
        [locationDict setObject:location.electricOutlet forKey:@"Electric_Outlet_Type__c"];
    }
    if (location.electricity3ft) {
        if ([location.electricity3ft intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Electricity_Within_3ft__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Electricity_Within_3ft__c"];
        }
    }
    if (location.elevatorStairs) {
        [locationDict setObject:location.elevatorStairs forKey:@"Elevator_or_Stairs__c"];
    }
    if (location.elevatorSize) {
        [locationDict setObject:location.elevatorSize forKey:@"Elevator_Size_feet__c"];
    }
    if (location.freightElevator) {
        if ([location.freightElevator intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Freight_Elevator_Available__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Freight_Elevator_Available__c"];
        }
    }
    if (location.personalProtection) {
        if ([location.personalProtection intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Personal_Protection_Equipment_Required__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Personal_Protection_Equipment_Required__c"];
        }
    }
    if (location.electricalInPlace) {
        if ([location.electricalInPlace intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Required_Electrical_in_Place__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Required_Electrical_in_Place__c"];
        }
    }
    if (location.visitByServiceDep) {
        if ([location.visitByServiceDep intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Requires_Visit_by_Service_Department__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Requires_Visit_by_Service_Department__c"];
        }
    }
    if (location.roomMeasurement) {
        [locationDict setObject:location.roomMeasurement forKey:@"Room_Measurement_for_Equipment_sq_ft__c"];
    }
    if (location.siteLevel) {
        if ([location.siteLevel intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Site_Level_and_Lighted__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Site_Level_and_Lighted__c"];
        }
    }
    if (location.siteSurveyDate) {
        NSString *dateString = [[AMProtocolParser sharedInstance] dateStringForSalesforceFromDate:location.siteSurveyDate];
        [locationDict setObject: dateString forKey:@"Site_Survey_Date__c"];
    }
    if (location.specialNotes) {
        [locationDict setObject:location.specialNotes forKey:@"Special_Instructions_Notes__c"];
    }
    if (location.safetyTraining) {
        if ([location.safetyTraining intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Specific_Safety_Training_Required__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Specific_Safety_Training_Required__c"];
        }
    }
    if (location.typeFlooring) {
        [locationDict setObject:location.typeFlooring forKey:@"Type_of_Flooring__c"];
    }
    if (location.waterSource) {
        if ([location.waterSource intValue]) {
            [locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"Water_Source_within_10ft__c"];
        }
        else {
            [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"Water_Source_within_10ft__c"];
        }
    }
    return locationDict;
}

- (NSDictionary *)createObjectWithData:(NSDictionary *)createObj
{
    NSArray * locationArray = [createObj objectForKey:@"AMLocation"];
    NSArray * filterUsedArray = [createObj objectForKey:@"AMFilterUsed"];
    NSArray * partsUsedArray = [createObj objectForKey:@"AMPartsUsed"];
    NSArray * invoiceArray = [createObj objectForKey:@"AMInvoice"];
    NSArray * assetRequestArray = [createObj objectForKey:@"AMAssetRequest"];
//    NSArray * workOrderArray = [createObj objectForKey:@"AMWorkOrder"];
//    NSArray * caseArray = [createObj objectForKey:@"AMCase"];

    
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * objectListDict = [NSMutableDictionary dictionary];
    
    if (locationArray) {
        NSMutableArray * locationDictArray = [NSMutableArray array];
        for (AMLocation * location in locationArray) {
            NSMutableDictionary * locationDict = [self getLocationDict:location];
            
            if (location.fakeID) {
                [locationDict setObject:location.fakeID forKey:@"fakeId"];
            }
//            if (location.locationID) {
//                [locationDict setObject:location.locationID forKey:@"Id"];
//            }
            if (location.location) {
                [locationDict setObject:location.location forKey:@"Name"];
            }
            if (location.accountID) {
                [locationDict setObject:location.accountID forKey:@"Account__c"];
            }
            [locationDictArray addObject:locationDict];
        }
        [objectListDict setObject:locationDictArray forKey:@"Asset_Location__c"];
    }
    if (assetRequestArray) {
        NSMutableArray * assetRequestDictArray = [NSMutableArray array];
        NSDateFormatter * dateFormtter = [[NSDateFormatter alloc] init];
        [dateFormtter setDateFormat:@"yyyy-MM-dd"];
        dateFormtter.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
        
        for (AMAssetRequest * assetReq in assetRequestArray) {
            
            NSMutableDictionary * assetReqDict = [NSMutableDictionary dictionary];
            
            if (assetReq.requestID) {
                [assetReqDict setObject:assetReq.requestID forKey:@"fakeId"];
            }
            if (assetReq.assetID) {
                [assetReqDict setObject:assetReq.assetID forKey:@"Asset__c"];
            }
            if (assetReq.locationID) {
                if ([assetReq.locationID rangeOfString:@"Create"].location != NSNotFound)
                    continue;
                [assetReqDict setObject:assetReq.locationID forKey:@"Asset_Location__c"];
            }
            if (assetReq.posID) {
                [assetReqDict setObject:assetReq.posID forKey:@"Point_of_Service__c"];
            }
            if (assetReq.machineNumber) {
                [assetReqDict setObject:assetReq.machineNumber forKey:@"Machine_Number__c"];
            }
            if (assetReq.serialNumber) {
                [assetReqDict setObject:assetReq.serialNumber forKey:@"Serial_Number__c"];
            }
            if (assetReq.updatedMNumber) {
                [assetReqDict setObject:assetReq.updatedMNumber forKey:@"Updated_Machine_Number__c"];
            }
            if (assetReq.updatedSNumber) {
                [assetReqDict setObject:assetReq.updatedSNumber forKey:@"Updated_Serial_Number__c"];
            }
//            if (assetReq.status) {
//                [assetReqDict setObject:assetReq.status forKey:@"RecordType"];
//            }
            if (assetReq.statusID) {
                [assetReqDict setObject:assetReq.statusID forKey:@"RecordTypeId"];
            }
            if (assetReq.machineType) {
                [assetReqDict setObject:assetReq.machineType forKey:@"Machine_Type__c"];
            }
            if (assetReq.woID) {
                [assetReqDict setObject:assetReq.woID forKey:@"Work_Order__c"];
            }
            if (assetReq.verifiedDate) {
                NSString * verifyDate = [dateFormtter stringFromDate:assetReq.verifiedDate];
                if (verifyDate) {
                    [assetReqDict setObject:verifyDate forKey:@"Verified_Date__c"];
                }
            }
            if (assetReq.verifyNotes) {
                [assetReqDict setObject:assetReq.verifyNotes forKey:@"Verification_Note__c"];
            }

            [assetRequestDictArray addObject:assetReqDict];
        }
        
        [objectListDict setObject:assetRequestDictArray forKey:@"Asset_Verification__c"];
    }
    if (invoiceArray) {
        NSMutableArray * invoiceDictArray = [NSMutableArray array];
        for (AMInvoice * invoice in invoiceArray) {
            NSMutableDictionary * invoiceDict = [NSMutableDictionary dictionary];
            
            if (invoice.invoiceID) {
                [invoiceDict setObject:invoice.invoiceID forKey:@"fakeId"];
            }
//            if (invoice.invoiceNumber) {
//                [invoiceDict setObject:invoice.invoiceNumber forKey:@"Name"];
//            }
            if (invoice.woID) {
                [invoiceDict setObject:invoice.woID forKey:@"Work_Order__c"];
            }
            if (invoice.hoursRate) {
                [invoiceDict setObject:invoice.hoursRate forKey:@"Hours_Rate__c"];
            }
            if (invoice.hoursWorked) {
                [invoiceDict setObject:invoice.hoursWorked forKey:@"Hours_Worked__c"];
            }
            if (invoice.workPerformed) {
                [invoiceDict setObject:invoice.workPerformed forKey:@"Work_Performed__c"];
            }
            if (invoice.maintenanceFee) {
                [invoiceDict setObject:invoice.maintenanceFee forKey:@"Maintenance_Fee__c"];
            }
            if (invoice.quantity) {
                [invoiceDict setObject:invoice.quantity forKey:@"Quantity__c"];
            }
            if (invoice.filterID) {
                [invoiceDict setObject:invoice.filterID forKey:@"Filters__c"];
            }
            if (invoice.partsID) {
                [invoiceDict setObject:invoice.partsID forKey:@"Product_Part__c"];
            }
            if (invoice.price) {
                [invoiceDict setObject:invoice.price forKey:@"Estimated_Price__c"];
            }
            
            if (invoice.unitPrice) {
                [invoiceDict setObject:invoice.unitPrice forKey:@"Filter_Price__c"];
            }
//            if (invoice.recordTypeName) {
//                [invoiceDict setObject:invoice.recordTypeName forKey:@"Record_Type_Name__c"];
//            }

            [invoiceDict setValue:invoice.recordTypeID forKey:@"RecordTypeId"];
            [invoiceDict setValue:invoice.posID forKey:@"Point_of_Service__c"];
            [invoiceDict setValue:invoice.assetID forKey:@"Asset__c"];
            [invoiceDict setValue:invoice.invoiceCodeId forKey:@"Invoice_Code__c"];
            
            [invoiceDictArray addObject:invoiceDict];
        }
        [objectListDict setObject:invoiceDictArray forKey:@"Invoice__c"];
    }
    if (filterUsedArray) {
        NSMutableArray * filterDictArray = [NSMutableArray array];
        for (AMFilterUsed * filter in filterUsedArray) {
            NSMutableDictionary * fuDict = [NSMutableDictionary dictionary];
            
            if (filter.fuID) {
                [fuDict setObject:filter.fuID forKey:@"fakeId"];
            }
            if (filter.filterID) {
                [fuDict setObject:filter.filterID forKey:@"Filter__c"];
            }
            if (filter.fcount) {
                [fuDict setObject:filter.fcount forKey:@"Filter_Quantity__c"];
            }
            if (filter.invoiceID) {
                [fuDict setObject:filter.invoiceID forKey:@"Invoice__c"];
            }
            [filterDictArray addObject:fuDict];
        }
        [objectListDict setObject:filterDictArray forKey:@"Invoice_Filter__c"];
    }
    if (partsUsedArray) {
        NSMutableArray * partsDictArray = [NSMutableArray array];
        for (AMPartsUsed * parts in partsUsedArray) {
            NSMutableDictionary * puDict = [NSMutableDictionary dictionary];
            
            if (parts.puID) {
                [puDict setObject:parts.puID forKey:@"fakeId"];
            }
            if (parts.partID) {
                [puDict setObject:parts.partID forKey:@"Product_Part__c"];
            }
            if (parts.pcount) {
                [puDict setObject:parts.pcount forKey:@"Part_Quantity__c"];
            }
            if (parts.invoiceID) {
                [puDict setObject:parts.invoiceID forKey:@"Invoice__c"];
            }
            [partsDictArray addObject:puDict];
        }
        [objectListDict setObject:partsDictArray forKey:@"Invoice_Part__c"];
    }

    [dataDict setObject:objectListDict forKey:@"objectListMap"];
    
#if DEBUG
    NSError * error = nil;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSString * postStr = [[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding];
    DLog(@"create obj: %@",postStr);
#endif
    
    return dataDict;
}

- (NSDictionary *)updateObjectWithData:(NSDictionary *)updateObj
{
    NSArray * woArray = [updateObj objectForKey:@"AMWorkOrder"];
    NSArray * assetArray = [updateObj objectForKey:@"AMAsset"];
    NSArray * invoiceArray = [updateObj objectForKey:@"AMInvoice"];
    NSArray * locationArray = [updateObj objectForKey:@"AMLocation"];
    NSArray * posArray = [updateObj objectForKey:@"AMPoS"];
    NSArray * caseArray = [updateObj objectForKey:@"AMCase"];
    NSArray * userArray = [updateObj objectForKey:@"AMUser"];
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * objectListDict = [NSMutableDictionary dictionary];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init] ;
    [dateFormat setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    dateFormat.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    if (woArray) {
        NSMutableArray * woDictArray = [NSMutableArray array];
        NSMutableArray * eventDictArray = [NSMutableArray array];
        for (AMWorkOrder * wo in woArray) {
            NSMutableDictionary * woDict = [NSMutableDictionary dictionary];
            NSMutableDictionary * eventDict = [NSMutableDictionary dictionary];
            
            //Assemble wo dict
            [woDict setObject:wo.woID forKey:@"Id"];
            
            if (wo.parkingDetail) {
                //[woDict setObject:wo.parkingDetail forKey:@"Parking_Detail__c"];
            }
            if (wo.status) {
                [woDict setObject:wo.status forKey:@"Status__c"];
            }
            if (wo.notes) {
                [woDict setObject:wo.notes forKey:@"Work_Order_Notes__c"];
            }
            if (wo.ownerID) {
                [woDict setObject:wo.ownerID forKey:@"OwnerId"];
            }
            if (wo.caseDescription) {
                [woDict setObject:wo.caseDescription forKey:@"Description__c"];
            }
            if (wo.subject) {
                [woDict setObject:wo.subject forKey:@"Subject__c"];
            }
            if (wo.inspectedTubing) {
                if ([wo.inspectedTubing intValue]) {
                    [woDict setObject:[NSNumber numberWithBool:YES] forKey:@"Inspected_Tubing_For_Any_Potential_Leaks__c"];
                }
                else {
                    [woDict setObject:[NSNumber numberWithBool:NO] forKey:@"Inspected_Tubing_For_Any_Potential_Leaks__c"];
                }
            }
            if (wo.leftInOrderlyManner) {
                if ([wo.leftInOrderlyManner intValue]) {
                    [woDict setObject:[NSNumber numberWithBool:YES] forKey:@"Break_Room_Left_In_An_Orderly_Manner__c"];
                }
                else {
                    [woDict setObject:[NSNumber numberWithBool:NO] forKey:@"Break_Room_Left_In_An_Orderly_Manner__c"];
                }
            }
            if (wo.testedAll) {
                if ([wo.testedAll intValue]) {
                    [woDict setObject:[NSNumber numberWithBool:YES] forKey:@"Tested_All_Equipment__c"];
                }
                else {
                    [woDict setObject:[NSNumber numberWithBool:NO] forKey:@"Tested_All_Equipment__c"];
                }

            }
            
            if ([wo.woType isEqualToLocalizedString:@"Repair"]) {
//                if (wo.repairCode) {
//                    [woDict setObject:wo.repairCode forKey:@"Repair_Code__c"];
//                }
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }
            }
            else if ([wo.woType isEqualToLocalizedString:@"Move"]) {
//                if (wo.repairCode) {
//                    [woDict setObject:wo.repairCode forKey:@"Repair_Code__c"];
//                }
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }
                if (wo.accessoriesRequired) {
                    [woDict setObject:wo.accessoriesRequired forKey:@"Accessories_Required__c"];
                }
                if (wo.filterCount) {
                    [woDict setObject:wo.filterCount forKey:@"Total_Number_of_Filters__c"];
                }
//                if (wo.filterType) {
//                    [woDict setObject:wo.filterType forKey:@"Filter_Type__c"];
//                }
            }
            else if ([wo.woType isEqualToLocalizedString:@"Removal"]) {
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }
            }
            else if ([wo.woType isEqualToLocalizedString:@"Swap"]) {
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }
                if (wo.accessoriesRequired) {
                    [woDict setObject:wo.accessoriesRequired forKey:@"Accessories_Required__c"];
                }
            }
            else if ([wo.woType isEqualToLocalizedString:@"Install"]) {
                if (wo.accessoriesRequired) {
                    [woDict setObject:wo.accessoriesRequired forKey:@"Accessories_Required__c"];
                }
//                if (wo.filterType) {
//                    [woDict setObject:wo.filterType forKey:@"Filter_Type__c"];
//                }
                if (wo.filterCount) {
                    [woDict setObject:wo.filterCount forKey:@"Total_Number_of_Filters__c"];
                }
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }
            }
            else if ([wo.woType isEqualToLocalizedString:@"Preventative Maintenance"]) {
                if (wo.filterCount) {
                    [woDict setObject:wo.filterCount forKey:@"Total_Number_of_Filters__c"];
                }
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }

            }
            else if ([wo.woType isEqualToLocalizedString:@"Filter Exchange"]) {
                if (wo.filterCount) {
                    [woDict setObject:wo.filterCount forKey:@"Total_Number_of_Filters__c"];
                }
//                if (wo.filterType) {
//                    [woDict setObject:wo.filterType forKey:@"Filter_Type__c"];
//                }
                if (wo.vendKey) {
//                    [woDict setObject:wo.vendKey forKey:@"Vend_Key__c"];
                }
            }
            [woDict setValue:wo.workOrderDescription forKey:@"Work_Order_Description__c"];
            [woDict setValue:wo.toLocationID forKey:@"To_Location__c"];
            [woDict setValue:wo.priority forKey:@"Priority__c"];
            [woDict setValue:wo.repairCode forKey:@"Repair_Code__c"];
            [woDict setValue:wo.machineType forKey:@"Machine_Type__c"];
            [woDict setValue:wo.assetID forKey:@"Asset__c"];
            [woDict setValue:[dateFormat stringFromDate:wo.workOrderCheckinTime]
                      forKey:@"Work_Order_Check_In_Time__c"];
            [woDict setValue:[dateFormat stringFromDate:wo.workOrderCheckoutTime]
                      forKey:@"Work_Order_Check_Out_Time__c"];
            
            //assemble Event
            if (wo.actualTimeStart || wo.actualTimeEnd || wo.estimatedTimeStart || wo.estimatedTimeEnd) {
                for (AMEvent * event in wo.eventList) {
                    if ([event.ownerID isEqualToString:wo.userID]) {
                        [eventDict setObject:event.eventID forKey:@"Id"];
                        break;
                    }
                }
                if (wo.actualTimeStart) {
                    [eventDict setObject:[dateFormat stringFromDate:wo.actualTimeStart] forKey:@"Actual_Start_Time__c"];
                } else {
                    [eventDict setObject:@"" forKey:@"Actual_Start_Time__c"];
                }
                if (wo.actualTimeEnd) {
                    [eventDict setObject:[dateFormat stringFromDate:wo.actualTimeEnd] forKey:@"Actual_End_Time__c"];
                }
                [eventDict setValue:[dateFormat stringFromDate:wo.estimatedTimeStart] forKey:@"StartDateTime"];
                [eventDict setValue:[dateFormat stringFromDate:wo.estimatedTimeEnd] forKey:@"EndDateTime"];

                [eventDictArray addObject:eventDict];
            }
            
            [woDictArray addObject:woDict];
        }
        [objectListDict setObject:eventDictArray forKey:@"Event"];
        [objectListDict setObject:woDictArray forKey:@"Work_Order__c"];
    }
    
    if (assetArray) {
        NSDateFormatter * dateFormtter = [[NSDateFormatter alloc] init];
        NSMutableArray * assetDictArray = [NSMutableArray array];
        [dateFormtter setDateFormat:@"yyyy-MM-dd"];
        dateFormtter.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];

        
        for (AMAsset * asset in assetArray) {
            
            NSMutableDictionary * assetDict = [NSMutableDictionary dictionary];
            
            if (asset.locationID) {
                if ([asset.locationID rangeOfString:@"Create"].location != NSNotFound)
                    continue;
                [assetDict setObject:asset.locationID forKey:@"Asset_Location__c"];
            }
            if (asset.assetID) {
                [assetDict setObject:asset.assetID forKey:@"Id"];
            }
            /*if (asset.mMachineNumber) {
                [assetDict setObject:asset.mMachineNumber forKey:@"Updated_Machine_Number__c"];
            }
            if (asset.mSerialNumber) {
                [assetDict setObject:asset.mSerialNumber forKey:@"Updated_Serial_Number__c"];
            }*/
            if (asset.notes) {
                [assetDict setObject:asset.notes forKey:@"Notes__c"];
            }
            /*if (asset.posID) {
                [assetDict setObject:asset.posID forKey:@"Service_Point__c"];
            }*/
            
            if (asset.verificationStatus) {
                [assetDict setObject:asset.verificationStatus forKey:@"Verification_Status__c"];
            }
            
            if (asset.lastVerifiedDate) {
                NSString * verifyDate = [dateFormtter stringFromDate:asset.lastVerifiedDate];
                if (verifyDate) {
                    [assetDict setObject:verifyDate forKey:@"Verified_Date__c"];
                }
            }
            if (asset.vendKey) {
                [assetDict setObject:asset.vendKey forKey:@"Vend_Key__c"];
            }
            
            [assetDictArray addObject:assetDict];
        }
        [objectListDict setObject:assetDictArray forKey:@"Asset"];
    }
    if (caseArray) {
        NSMutableArray * caseDictArray = [NSMutableArray array];
        for (AMCase * amCase in caseArray) {
            NSMutableDictionary * caseDict = [NSMutableDictionary dictionary];
            if (amCase.caseID) {
                [caseDict setObject:amCase.caseID forKey:@"Id"];
            }
            if (amCase.signContactID) {
                [caseDict setObject:amCase.signContactID forKey:@"FSP_Signature_Contact__c"];
            }
//            if (amCase.signContactInfo) {
//                [caseDict setObject:amCase.signContactInfo forKey:@"FSP_Signature_Contact_Info__c"];
//            }
            if (amCase.signContactPhone) {
                [caseDict setObject:amCase.signContactPhone forKey:@"FSP_Signature_Contact_Phone__c"];
            }
            if (amCase.signContactEmail) {
                [caseDict setObject:amCase.signContactEmail forKey:@"FSP_Signature_Contact_Email__c"];
            }
            if (amCase.signFirstName) {
                [caseDict setObject:amCase.signFirstName forKey:@"FSP_Signature_First_Name__c"];
            }
            if (amCase.signLastName) {
                [caseDict setObject:amCase.signLastName forKey:@"FSP_Signature_Last_Name__c"];
            }
            if (amCase.signTitle) {
                [caseDict setObject:amCase.signTitle forKey:@"FSP_Signature_Title__c"];
            }
            [caseDict setValue:amCase.meiCustomer forKey:@"MEI_Customer__c"];
            [caseDict setValue:amCase.estimatedTotalPrice forKey:@"Estimated_Total_Price__c"];

            [caseDictArray addObject:caseDict];
        }
        [objectListDict setObject:caseDictArray forKey:@"Case"];
    }
    
    if (userArray) {
        NSMutableArray * userDictArray = [NSMutableArray array];
        for (AMUser * theUser in userArray) {
            NSMutableDictionary * userDict = [NSMutableDictionary dictionary];
            
            if (theUser.userID) {
                [userDict setObject:theUser.userID forKey:@"Id"];
            }
            if (theUser.longitude) {
                [userDict setObject:theUser.longitude forKey:@"Current_Position__Longitude__s"];
            }
            if (theUser.latitude) {
                [userDict setObject:theUser.latitude forKey:@"Current_Position__Latitude__s"];
            }
            
            [userDict setValue:theUser.workingHourFrom forKey:@"Working_Hour_From__c"];
            [userDict setValue:theUser.workingHourTo forKey:@"Working_Hour_To__c"];
            [userDict setValue:theUser.lunchBreakFrom forKey:@"Lunch_Break_From__c"];
            [userDict setValue:theUser.lunchBreakTo forKey:@"Lunch_Break_To__c"];
            [userDict setValue:[dateFormat stringFromDate: theUser.positionTimestamp] forKey:@"Position_Sync_Timestamp__c"];
            
            [userDictArray addObject:userDict];
        }
        [objectListDict setObject:userDictArray forKey:@"User"];
    }
    if (invoiceArray) {
        NSMutableArray * invoiceDictArray = [NSMutableArray array];
        for (AMInvoice * invoice in invoiceArray) {
            NSMutableDictionary * invoiceDict = [NSMutableDictionary dictionary];
            
            if (invoice.invoiceID) {
                [invoiceDict setObject:invoice.invoiceID forKey:@"Id"];
            }
            if (invoice.hoursRate) {
                [invoiceDict setObject:invoice.hoursRate forKey:@"Hours_Rate__c"];
            }
            if (invoice.hoursWorked) {
                [invoiceDict setObject:invoice.hoursWorked forKey:@"Hours_Worked__c"];
            }
//            if (invoice.workPerformed) {
//                [invoiceDict setObject:invoice.workPerformed forKey:@"Work_Performed__c"];
//            }
            if (invoice.maintenanceFee) {
                [invoiceDict setObject:invoice.maintenanceFee forKey:@"Maintenance_Fee__c"];
            }
            if (invoice.price == nil) {
                invoice.price = [NSNumber numberWithFloat:0.0];
            }
            [invoiceDict setValue:invoice.price forKey:@"Estimated_Price__c"];
            [invoiceDict setValue:invoice.quantity forKey:@"Quantity__c"];
            [invoiceDict setValue:invoice.recordTypeID forKey:@"RecordTypeId"];
            [invoiceDict setValue:invoice.unitPrice forKey:@"Filter_Price__c"];
            [invoiceDict setValue:invoice.filterID forKey:@"Filters__c"];
            [invoiceDict setValue:invoice.invoiceCodeId forKey:@"Invoice_Code__c"];

            [invoiceDictArray addObject:invoiceDict];
        }
        [objectListDict setObject:invoiceDictArray forKey:@"Invoice__c"];
    }
    
    if (locationArray) {
        NSMutableArray * locationDictArray = [NSMutableArray array];
        for (AMLocation * location in locationArray) {
            NSMutableDictionary * locationDict = [self getLocationDict:location];
            
            if (location.locationID) {
                [locationDict setObject:location.locationID forKey:@"Id"];
            }
            
            [locationDictArray addObject:locationDict];
        }
        [objectListDict setObject:locationDictArray forKey:@"Asset_Location__c"];
    }

    if (posArray) {
        NSMutableArray * posDictArray = [NSMutableArray array];
        for (AMPoS * pos in posArray) {
            NSMutableDictionary * posDict = [NSMutableDictionary dictionary];
            
            if (pos.parkingDetail) {
                [posDict setObject:pos.parkingDetail forKey:@"FSP_Parking_Detail__c"];
            }
            [posDictArray addObject:posDict];
        }
        [objectListDict setObject:posDictArray forKey:@"ServicePoint__c"];
    }

    [dataDict setObject:objectListDict forKey:@"objectListMap"];
#if DEBUG
    NSError * error = nil;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    DLog(@"update obj: %@",[[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding]);
#endif
    
    return dataDict;

}

- (NSDictionary *)uploadSignatureWithData:(NSArray *)signatureObj
{
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    NSMutableArray * dataList = [NSMutableArray array];
    
    for (NSDictionary * signData in signatureObj) {
        NSMutableDictionary * signDict = [NSMutableDictionary dictionary];
        NSData * imageData = [signData objectForKey:@"Data"];
        NSString * woID = [signData objectForKey:@"Name"];
        NSString * base64Str = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        //NSString * base64Str = [imageData base64EncodedStringWithSeparateLines:YES];
        if (woID && base64Str) {
            [signDict setObject:base64Str forKey:@"Body"];
            [signDict setObject:woID forKey:@"ParentId"];
        }
        [dataList addObject:signDict];
    }
    
    [dataDict setObject:dataList forKey:@"objectListMap"];
#if DEBUG
    NSError * error = nil;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    DLog(@"upload signature: %@",[[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding]);
#endif
    return dataDict;
}

- (NSDictionary *)setPoSAsset:(NSArray *)assetList
{
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    NSMutableArray * dataList = [NSMutableArray array];
    
    for (AMAsset * asset in assetList) {
        NSMutableDictionary * assetDict = [NSMutableDictionary dictionary];
        if (asset.posID) {
            [assetDict setObject:asset.posID forKey:@"posID"];
        }
        if (asset.machineNumber) {
            [assetDict setObject:asset.machineNumber forKey:@"Machine_Number__c"];
        }
        if (asset.serialNumber) {
            [assetDict setObject:asset.serialNumber forKey:@"SerialNumber"];
        }
        [dataList addObject:assetDict];
    }
    
    [dataDict setObject:dataList forKey:@"objectListMap"];
#if DEBUG
    NSError * error = nil;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    DLog(@"set asset pos: %@",[[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding]);
#endif
    return dataDict;
}

-(NSDictionary *)parameterDictionaryFromAttachments:(NSArray *)attachments
{
    NSMutableDictionary * dataDict = [NSMutableDictionary dictionary];
    NSMutableArray * dataList = [NSMutableArray array];
    
    for (AMDBAttachment *attachment in attachments) {
        [dataList addObject:[attachment dictionaryToUploadSalesforce]];
    }
    
    [dataDict setObject:dataList forKey:@"lstMapCreateKeyValue"];
#if DEBUG
    NSError * error = nil;
    NSData * postData = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:&error];
    NSString * postStr = [[NSString alloc]initWithData:postData encoding:NSUTF8StringEncoding];
    DLog(@"Upload Attachment: %@",postStr);
#endif
    return dataDict;
}

-(NSDictionary *)dictionaryWithAllEntityIDsForSync
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *idDict = [NSMutableDictionary dictionary];
    NSArray *objectList = [NSArray array];
    NSArray *idList = [NSArray array];
    
    objectList = [[AMDBManager sharedInstance] getEventListAfterTodayBegin];
    idList = [objectList valueForKeyExcludingNull:@"eventID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Event"];

    NSMutableArray *woList = [NSMutableArray array];
    idList = [objectList valueForKeyExcludingNull:@"woID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Work_Order__c"];
    [woList addObjectsFromArray:idList];
    
    objectList = [[AMDBManager sharedInstance] getAllPendingWorkOrderList];
    idList = [objectList valueForKeyExcludingNull:@"woID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Pending_Work_Order__c"];
    [woList addObjectsFromArray:idList];

    objectList = [[AMDBManager sharedInstance] getAllWorkOrderList];
    idList = [objectList valueForKeyExcludingNull:@"woID"];
    NSMutableArray *otherWoList = [NSMutableArray arrayWithArray:idList];
    [otherWoList removeObjectsInArray:woList];
    [idDict setValue:(otherWoList ? otherWoList : @[]) forKey:@"Other_Work_Order__c"];

    objectList = [[AMDBManager sharedInstance] getAllInvoiceList];
    idList = [objectList valueForKeyExcludingNull:@"invoiceID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Invoice__c"];
    
    objectList = [[AMDBManager sharedInstance] getAllAccountList];
    idList = [objectList valueForKeyExcludingNull:@"accountID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Account"];
    
    objectList = [[AMDBManager sharedInstance] getAllAssetList];
    idList = [objectList valueForKeyExcludingNull:@"assetID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Asset"];
    idList = [objectList valueForKeyExcludingNull:@"productID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Product2"];
    
    objectList = [[AMDBManager sharedInstance] getAllAttachmentList];
    idList = [objectList valueForKeyExcludingNull:@"id"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Attachment"];
    
    objectList = [[AMDBManager sharedInstance] getAllCaseList];
    idList = [objectList valueForKeyExcludingNull:@"caseID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Case"];
    
    objectList = [[AMDBManager sharedInstance] getAllContactList];
    idList = [objectList valueForKeyExcludingNull:@"contactID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Service_Point_Contacts__c"];
    
    objectList = [[AMDBManager sharedInstance] getAllCustomerPriceList];
    idList = [objectList valueForKeyExcludingNull:@"customerPriceID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Customer_Price__c"];
    
    objectList = [[AMDBManager sharedInstance] getAllLocationList];
    idList = [objectList valueForKeyExcludingNull:@"locationID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Asset_Location__c"];
    
    objectList = [[AMDBManager sharedInstance] getAllPartsList];
    idList = [objectList valueForKeyExcludingNull:@"partID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"Product_Part__c"];
    
    objectList = [[AMDBManager sharedInstance] getAllPoSList];
    idList = [objectList valueForKeyExcludingNull:@"posID"];
    [idDict setValue:(idList ? idList : @[]) forKey:@"ServicePoint__c"];
    
    // assemble root dictionary
    [dict setValue:idDict forKey:@"mapMobileSobjectName2IDs"];
    
//    objectList = [[AMDBManager sharedInstance] getAllPendingWorkOrderList];
//    idList = [objectList valueForKeyExcludingNull:@"woID"];
//    [dict setValue:(idList ? idList : @[]) forKey:@"lstMobilePendingWorkOrderIDs"];
//    [dict setValue: @[] forKey:@"lstMobilePendingWorkOrderIDs"];
    
    return dict;
}

-(NSDictionary *)dictionaryWithWorkOrderAndEventIDsForSync
{
    NSMutableArray * woIDList = [NSMutableArray array];
    NSArray * eventIDList = [NSArray array];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    
    //    NSArray * todayWOs = [[AMDBManager sharedInstance] getTodayWorkOrderIncludeClosed];
    //    for (AMWorkOrder * wo in todayWOs) {
    //        [idList addObject:wo.woID];
    //    }
    
    //    NSArray *woList = [[AMDBManager sharedInstance] getWorkOrderListAfterTodayBegin];
    //    for (AMWorkOrder * wo in woList) {
    //        [idList addObject:wo.woID];
    //    }
    
    
    NSArray *eventList = [[AMDBManager sharedInstance] getEventListAfterTodayBegin];
    eventIDList = [eventList valueForKeyExcludingNull:@"eventID"];
    if (eventIDList) {
        [bodyDict setObject:eventIDList forKey:@"lstMobileEventIDs"];
    } else {
        [bodyDict setObject:@[] forKey:@"lstMobileEventIDs"];
    }
    
    NSArray * pendingWOs = [[AMDBManager sharedInstance] getAllPendingWorkOrderList];
    
    [woIDList addObjectsFromArray: [pendingWOs valueForKeyExcludingNull:@"woID"]];
    [woIDList addObjectsFromArray: [eventList valueForKeyExcludingNull:@"woID"]];
    
    if (woIDList) {
        //        [bodyDict setObject:woIDList forKey:@"mobileWorkOrderIDList"];
        //        [bodyDict setObject:woIDList forKey:@"lstMobilePendingWorkOrderIDs"];
        [bodyDict setObject:woIDList forKey:@"lstMobileWorkOrderIDs"];
    } else {
        [bodyDict setObject:@[] forKey:@"lstMobileWorkOrderIDs"];
    }
    
    return bodyDict;
}

@end






