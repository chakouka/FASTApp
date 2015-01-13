//
//  AMDBInvoice.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/1/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBInvoice : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * filterID;
@property (nonatomic, retain) NSString * filterName;
@property (nonatomic, retain) NSNumber * hoursRate;
@property (nonatomic, retain) NSNumber * hoursWorked;
@property (nonatomic, retain) NSString * invoiceCodeId;
@property (nonatomic, retain) NSString * invoiceCodeName;
@property (nonatomic, retain) NSString * invoiceID;
@property (nonatomic, retain) NSString * invoiceNumber;
@property (nonatomic, retain) NSString * lastModifiedBy;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSNumber * maintenanceFee;
@property (nonatomic, retain) NSString * partsID;
@property (nonatomic, retain) NSString * partsName;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * posName;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * recordTypeID;
@property (nonatomic, retain) NSString * recordTypeName;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * woID;
@property (nonatomic, retain) NSString * workPerformed;
@property (nonatomic, retain) NSString * caseId;

@end
