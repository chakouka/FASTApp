//
//  AMDBWorkOrder.h
//  AramarkFSP
//
//  Created by Aaron Hu on 9/26/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBWorkOrder : NSManagedObject

@property (nonatomic, retain) NSString * accessoriesRequired;
@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) NSDate * actualTimeEnd;
@property (nonatomic, retain) NSDate * actualTimeStart;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSNumber * callAhead;
@property (nonatomic, retain) NSString * caseDescription;
@property (nonatomic, retain) NSString * caseID;
@property (nonatomic, retain) NSString * caseNumber;
@property (nonatomic, retain) NSString * complaintCode;
@property (nonatomic, retain) NSString * contact;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * createdByName;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * estimatedTimeEnd;
@property (nonatomic, retain) NSDate * estimatedTimeStart;
@property (nonatomic, retain) NSDate * estimatedWorkDate;
@property (nonatomic, retain) NSNumber * filterCount;
@property (nonatomic, retain) NSString * filterType;
@property (nonatomic, retain) NSString * filterTypeName;
@property (nonatomic, retain) NSString * fromLocation;
@property (nonatomic, retain) NSNumber * inspectedTubing;
@property (nonatomic, retain) NSString * lastModifiedBy;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * leftInOrderlyManner;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * machineType;
@property (nonatomic, retain) NSString * machineTypeName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * ownerID;
@property (nonatomic, retain) NSString * ownerName;
@property (nonatomic, retain) NSString * parkingDetail;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * preferrTimeFrom;
@property (nonatomic, retain) NSString * preferrTimeTo;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * recordTypeID;
@property (nonatomic, retain) NSString * recordTypeName;
@property (nonatomic, retain) NSString * repairCode;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * testedAll;
@property (nonatomic, retain) NSString * toLocationID;
@property (nonatomic, retain) NSString * toLocationName;
@property (nonatomic, retain) NSString * toWorkLocation;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * vendKey;
@property (nonatomic, retain) NSNumber * warranty;
@property (nonatomic, retain) NSString * woID;
@property (nonatomic, retain) NSString * woNumber;
@property (nonatomic, retain) NSString * workLocation;
@property (nonatomic, retain) NSDate * workOrderCheckinTime;
@property (nonatomic, retain) NSDate * workOrderCheckoutTime;
@property (nonatomic, retain) NSString * workOrderDescription;
@property (nonatomic, retain) NSString * woType;
@property (nonatomic, retain) NSDate * lastServiceDate;
@property (nonatomic, retain) NSNumber *pmPrice;//BKK 20180912 000462
@end
