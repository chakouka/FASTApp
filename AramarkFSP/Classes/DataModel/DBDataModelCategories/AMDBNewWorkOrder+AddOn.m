//
//  AMDBNewWorkOrder+Create.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/25/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBNewWorkOrder+AddOn.h"
#import "AMProtocolParser.h"

@implementation AMDBNewWorkOrder (AddOn)

+(AMDBNewWorkOrder *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBNewWorkOrder *entity = nil;
    entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBNewWorkOrder" inManagedObjectContext:context];
    entity.createdDate = [NSDate date];
    entity.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
    entity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];;

    return entity;
}

+(AMDBNewWorkOrder *)newEntityWithAMWorkOrder:(AMWorkOrder *)workOrder InManagedObjectContext:(NSManagedObjectContext *)context;
{
    AMDBNewWorkOrder *entity = [self newEntityInManagedObjectContext:context];
    entity.recordTypeID = workOrder.recordTypeID;
    entity.contactID = workOrder.contactID;
    entity.posID = workOrder.posID;
    entity.currentLocation = workOrder.workLocation;
    entity.assetID = workOrder.assetID;
    entity.machineTypeID = workOrder.machineType;
    entity.callAhead = workOrder.callAhead;
    entity.caseDescription = workOrder.caseDescription;
    entity.caseID = workOrder.caseID;
    entity.complaintCode = workOrder.complaintCode;
//    entity.endDateTime = workOrder.estimatedTimeEnd;
    entity.preferredScheduleTimeFrom = workOrder.preferrTimeFrom;
    entity.preferredScheduleTimeTo = workOrder.preferrTimeTo;
//    entity.startDateTime = workOrder.estimatedTimeStart;
    entity.status = workOrder.status;
    entity.underWarranty = workOrder.warranty;
    entity.vendKey = workOrder.vendKey;
    entity.createdDate = workOrder.createdDate;
    entity.filterType = workOrder.filterType;
    entity.filterCount = workOrder.filterCount;
    entity.locationNew = workOrder.toWorkLocation;
    entity.parkingDetail = workOrder.parkingDetail;
    entity.assignToMyself = workOrder.assignToMyself;
    entity.estimatedWorkDate = workOrder.estimatedDate;
    entity.subject = workOrder.subject;
    entity.recordTypeName = workOrder.woType;
    entity.workOrderDescription = workOrder.workOrderDescription;
    entity.priority = workOrder.priority;
    entity.dataStatus = @(EntityStatusCreated);
    
    return entity;
}

-(NSDictionary *)dictionaryToCreateObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:self.fakeID forKeyPath:@"fakeId"];
    [dict setValue:self.caseID forKeyPath:@"Case__c"];
    [dict setValue:self.recordTypeID forKeyPath:@"RecordTypeId"];
    [dict setValue:self.contactID forKeyPath:@"Contact"];
    [dict setValue:self.posID forKeyPath:@"Point_of_Service__c"];
    [dict setValue:self.currentLocation forKeyPath:@"CurrentLocation"];
    [dict setValue:self.assetID forKeyPath:@"Asset__c"];
    [dict setValue:self.machineTypeID forKeyPath:@"Machine_Type__c"];
    [dict setValue:self.underWarranty forKeyPath:@"Under_Warranty__c"];
   
    [dict setValue:self.preferredScheduleTimeFrom forKeyPath:@"Preferred_Schedule_Time_From__c"];
    [dict setValue:self.preferredScheduleTimeTo forKeyPath:@"Preferred_Schedule_Time_To__c"];
    [dict setValue:self.vendKey forKeyPath:@"Vend_Key__c"];
    [dict setValue:self.status forKeyPath:@"Status__c"];
    [dict setValue:self.caseDescription forKeyPath:@"Description__c"];
    [dict setValue:self.complaintCode forKeyPath:@"Complaint_Code__c"];
    [dict setValue:self.filterType forKeyPath:@"Filter_Type__c"];
    [dict setValue:self.filterCount forKeyPath:@"Total_Number_of_Filters__c"];
    [dict setValue:self.locationNew forKeyPath:@"New_Location__c"];
//    [dict setValue:self.parkingDetail forKeyPath:@"FSP_Parking_Detail__c"];
    [dict setValue:self.recordTypeName forKeyPath:@"RecordTypeName"];
    [dict setValue:self.workOrderDescription forKey:@"Work_Order_Description__c"];
    [dict setValue:self.priority forKey:@"Priority__c"];
    //Aaron - For BOOL value, salesforce will identify the value by string 'true'/'false', not 1/0
    NSString *assignToMySelfString = @"false";
    if (self.assignToMyself.boolValue) {
        assignToMySelfString = @"true";
    }
    
    [dict setValue:assignToMySelfString forKeyPath:@"AssignToMyself"];
    NSString *callAheadStr = @"false";
    if (self.callAhead.boolValue) {
        callAheadStr = @"true";
    }
    [dict setValue:callAheadStr forKeyPath:@"Call_Ahead__c"];
    
    [dict setValue:self.subject forKeyPath:@"Subject__c"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [[AMLogicCore sharedInstance] timeZoneOnSalesforce];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    [dict setValue: [formatter stringFromDate: self.estimatedWorkDate] forKeyPath:@"Estimated_Work_Date__c"];

    
    NSString *startDateString = [[AMProtocolParser sharedInstance] dateStringForSalesforceFromDate:self.startDateTime];
    NSString *endDateString = [[AMProtocolParser sharedInstance] dateStringForSalesforceFromDate:self.endDateTime];

    [dict setValue:startDateString forKeyPath:@"StartDateTime"];
    [dict setValue:endDateString forKeyPath:@"EndDateTime"];
    
    return dict;
}


@end
