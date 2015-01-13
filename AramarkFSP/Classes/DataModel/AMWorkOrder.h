//
//  AMWorkOrder.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/8/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMPoS.h"
#import "AMAccount.h"
#import "AMAsset.h"
#import "AMCase.h"


@interface AMWorkOrder : NSObject<NSMutableCopying>

@property (nonatomic, strong) NSString * accessoriesRequired;
@property (nonatomic, strong) NSString * assetID;
@property (nonatomic, strong) NSNumber * callAhead;
@property (nonatomic, strong) NSString * caseID;
@property (nonatomic, strong) NSString * complaintCode;
@property (nonatomic, strong) NSString * contact;
@property (nonatomic, strong) NSString * createdBy;
@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSDate * estimatedTimeEnd;
@property (nonatomic, strong) NSDate * estimatedTimeStart;
@property (nonatomic, strong) NSNumber * filterCount;
@property (nonatomic, strong) NSString * filterType;
@property (nonatomic, strong) NSString * fromLocation;
@property (nonatomic, strong) NSString * lastModifiedBy;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSNumber * latitude;
@property (nonatomic, strong) NSNumber * longitude;
@property (nonatomic, strong) NSString * machineType;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * ownerID;
@property (nonatomic, strong) NSString * parkingDetail;
@property (nonatomic, strong) NSString * posID;
@property (nonatomic, strong) NSString * preferrTimeFrom;
@property (nonatomic, strong) NSString * preferrTimeTo;
@property (nonatomic, strong) NSString * priority;
@property (nonatomic, strong) NSString * repairCode;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * toLocationID;
@property (nonatomic, strong) NSString * vendKey;
@property (nonatomic, strong) NSNumber * warranty;
@property (nonatomic, strong) NSString * woID;
@property (nonatomic, strong) NSString * woNumber;
@property (nonatomic, strong) NSString * workLocation;
@property (nonatomic, strong) NSString * woType;
@property (nonatomic, strong) NSDate * actualTimeStart;
@property (nonatomic, strong) NSDate * actualTimeEnd;
@property (nonatomic, strong) NSString * accountID;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSString * accountName;
@property (nonatomic, strong) NSNumber * age;
@property (nonatomic, strong) NSNumber * leftInOrderlyManner;
@property (nonatomic, strong) NSNumber * inspectedTubing;
@property (nonatomic, strong) NSNumber * testedAll;
@property (nonatomic, strong) NSString * caseDescription;
@property (nonatomic, strong) NSString * createdByName;
@property (nonatomic, strong) NSString * ownerName;
@property (nonatomic, strong) NSString * toWorkLocation; //New Location
@property (nonatomic, strong) NSArray * eventList;
@property (nonatomic, strong) AMAccount * woAccount;
@property (nonatomic, strong) AMPoS * woPoS;
@property (nonatomic, strong) AMAsset * woAsset;
@property (nonatomic, strong) AMCase * woCase;
@property (nonatomic, strong) NSString * nextDistance;
@property (nonatomic, strong) NSString * nextTime;
@property (nonatomic, retain) NSString * recordTypeID;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, strong) NSNumber * nextDistanceValue;
@property (nonatomic, strong) NSNumber * nextTimeValue;

@property (nonatomic, strong) NSNumber * assignToMyself;
@property (nonatomic, strong) NSDate   * estimatedDate; //Estimated_Work_Date__c
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * recordTypeName;
@property (nonatomic, retain) NSString * workOrderDescription;
@property (nonatomic, retain) NSString * caseNumber;
@property (nonatomic, retain) NSString * machineTypeName;
@property (nonatomic, retain) NSString * filterTypeName;
@property (nonatomic, retain) NSString * toLocationName;
@property (nonatomic, retain) NSDate * workOrderCheckinTime;
@property (nonatomic, retain) NSDate * workOrderCheckoutTime;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSDate* lastServiceDate;

- (BOOL)isEqual:(id)object;

@end







