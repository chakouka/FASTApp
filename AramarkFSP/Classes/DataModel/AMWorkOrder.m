//
//  AMWorkOrder.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/8/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMWorkOrder.h"


@implementation AMWorkOrder

@synthesize accessoriesRequired;
@synthesize assetID;
@synthesize callAhead;
@synthesize caseID;
@synthesize complaintCode;
@synthesize contact;
@synthesize createdBy;
@synthesize createdDate;
@synthesize estimatedTimeEnd;
@synthesize estimatedTimeStart;
@synthesize filterCount;
@synthesize filterType;
@synthesize fromLocation;
@synthesize lastModifiedBy;
@synthesize lastModifiedDate;
@synthesize latitude;
@synthesize longitude;
@synthesize machineType;
@synthesize notes;
@synthesize ownerID;
@synthesize parkingDetail;
@synthesize posID;
@synthesize preferrTimeFrom;
@synthesize preferrTimeTo;
@synthesize priority;
@synthesize repairCode;
@synthesize status;
@synthesize vendKey;
@synthesize warranty;
@synthesize woID;
@synthesize woNumber;
@synthesize workLocation;
@synthesize woType;
@synthesize actualTimeStart;
@synthesize actualTimeEnd;
@synthesize accountID;
@synthesize userID;
@synthesize accountName;
@synthesize leftInOrderlyManner;
@synthesize inspectedTubing;
@synthesize testedAll;
@synthesize caseDescription;
@synthesize eventList;
@synthesize nextDistance;
@synthesize nextTime;
@synthesize nextDistanceValue;
@synthesize nextTimeValue;
@synthesize age;
@synthesize woAccount;
@synthesize woAsset;
@synthesize woCase;
@synthesize woPoS;
@synthesize createdByName;
@synthesize ownerName;
@synthesize toWorkLocation;
@synthesize lastServiceDate;
@synthesize pmPrice;

- (NSString *)description
{
    return [NSString stringWithFormat:@"woID : %@ ; %@ : %@",woID,latitude,longitude];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    if ([self.woID isEqualToString:((AMWorkOrder *)object).woID]) {
        return YES;
    }
    
    return NO;
}


- (id)mutableCopyWithZone:(NSZone *)zone
{
    AMWorkOrder *newWordOrder = [[AMWorkOrder allocWithZone:zone] init];
    newWordOrder.subject = self.subject;
    newWordOrder.accessoriesRequired = self.accessoriesRequired;
    newWordOrder.actualTimeEnd = self.actualTimeEnd;
    newWordOrder.actualTimeStart = self.actualTimeStart;
    newWordOrder.assetID = self.assetID;
    newWordOrder.callAhead = self.callAhead;
    newWordOrder.caseID = self.caseID;
    newWordOrder.complaintCode = self.complaintCode;
    newWordOrder.contact = self.contact;
    newWordOrder.createdBy = self.createdBy;
    newWordOrder.createdDate = self.createdDate;
    newWordOrder.estimatedTimeEnd = self.estimatedTimeEnd;
    newWordOrder.estimatedTimeStart = self.estimatedTimeStart;
    newWordOrder.filterCount = self.filterCount;
    newWordOrder.filterType = self.filterType;
    newWordOrder.fromLocation = self.fromLocation;
    newWordOrder.lastModifiedBy = self.lastModifiedBy;
    newWordOrder.lastModifiedDate = self.lastModifiedDate;
    newWordOrder.latitude = self.latitude;
    newWordOrder.longitude = self.longitude;
    newWordOrder.machineType = self.machineType;
    newWordOrder.notes = self.notes;
    newWordOrder.ownerID = self.ownerID;
    newWordOrder.parkingDetail = self.parkingDetail;
    newWordOrder.posID = self.posID;
    newWordOrder.preferrTimeFrom = self.preferrTimeFrom;
    newWordOrder.preferrTimeTo = self.preferrTimeTo;
    newWordOrder.priority = self.priority;
    newWordOrder.repairCode = self.repairCode;
    newWordOrder.status = self.status;
    newWordOrder.toLocationID = self.toLocationID;
    newWordOrder.toLocationName = self.toLocationName;
    newWordOrder.vendKey = self.vendKey;
    newWordOrder.warranty = self.warranty;
    newWordOrder.woID = self.woID;
    newWordOrder.woNumber = self.woNumber;
    newWordOrder.workLocation = self.workLocation;
    newWordOrder.woType = self.woType;
    newWordOrder.accountID = self.accountID;
    newWordOrder.accountName = self.accountName;
    newWordOrder.userID = self.userID;
    newWordOrder.age = self.age;
    newWordOrder.inspectedTubing = self.inspectedTubing;
    newWordOrder.leftInOrderlyManner = self.leftInOrderlyManner;
    newWordOrder.testedAll = self.testedAll;
    newWordOrder.createdByName = self.createdByName;
    newWordOrder.ownerName = self.ownerName;
    newWordOrder.lastServiceDate = self.lastServiceDate;
    newWordOrder.pmPrice = self.pmPrice;//bkk added 20180912 PM 000462
    return newWordOrder;
}

@end








