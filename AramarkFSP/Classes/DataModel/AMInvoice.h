//
//  AMInvoice.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/4/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>

#define INVOICE_TYPE_FILTER         @"Filter"   //No asset id
//#define INVOICE_TYPE_WORK           @"Work"
#define INVOICE_TYPE_PART           @"Part" //No asset id
#define INVOICE_TYPE_INVOICECODE    @"Invoice Code"
#define INVOICE_TYPE_LABORCHARGE    @"Labor Charge"


@interface AMInvoice : NSObject

@property (nonatomic, strong) NSString * assetID;
@property (nonatomic, strong) NSString * createdBy;
@property (nonatomic, strong) NSString * invoiceNumber;
@property (nonatomic, strong) NSString * lastModifiedBy;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSString * posID;
@property (nonatomic, strong) NSString * woID;
@property (nonatomic, strong) NSString * invoiceID;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSNumber * price;
@property (nonatomic, strong) NSNumber * hoursRate;
@property (nonatomic, strong) NSNumber * hoursWorked;
@property (nonatomic, strong) NSNumber * maintenanceFee;
@property (nonatomic, strong) NSString * workPerformed;
@property (nonatomic, strong) NSNumber * quantity;
@property (nonatomic, strong) NSString * filterName;
@property (nonatomic, strong) NSString * filterID;
@property (nonatomic, strong) NSString * partsName;
@property (nonatomic, strong) NSString * partsID;
@property (nonatomic, strong) NSArray * filterUsedList;
@property (nonatomic, strong) NSArray * partsUsedList;
@property (nonatomic, retain) NSString * recordTypeName;
@property (nonatomic, retain) NSString * recordTypeID;
@property (nonatomic, retain) NSNumber * unitPrice;
@property (nonatomic, retain) NSString * invoiceCodeId;
@property (nonatomic, retain) NSString * invoiceCodeName;
@property (nonatomic, retain) NSString * posName;
@property (nonatomic, retain) NSString * caseId;

- (BOOL)isEqual:(id)object;
@end
