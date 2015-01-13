//
//  AMDBNewWorkOrder.h
//  AramarkFSP
//
//  Created by Aaron Hu on 9/26/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBNewWorkOrder : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSNumber * assignToMyself;
@property (nonatomic, retain) NSNumber * callAhead;
@property (nonatomic, retain) NSString * caseDescription;
@property (nonatomic, retain) NSString * caseID;
@property (nonatomic, retain) NSString * complaintCode;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * currentLocation;
@property (nonatomic, retain) NSNumber * dataStatus;
@property (nonatomic, retain) NSDate * endDateTime;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSDate * estimatedWorkDate;
@property (nonatomic, retain) NSString * fakeID;
@property (nonatomic, retain) NSNumber * filterCount;
@property (nonatomic, retain) NSString * filterType;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * locationNew;
@property (nonatomic, retain) NSString * machineTypeID;
@property (nonatomic, retain) NSString * parkingDetail;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * preferredScheduleTimeFrom;
@property (nonatomic, retain) NSString * preferredScheduleTimeTo;
@property (nonatomic, retain) NSString * recordTypeID;
@property (nonatomic, retain) NSString * recordTypeName;
@property (nonatomic, retain) NSDate * startDateTime;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * underWarranty;
@property (nonatomic, retain) NSString * vendKey;
@property (nonatomic, retain) NSString * workOrderDescription;
@property (nonatomic, retain) NSString * priority;

@end
