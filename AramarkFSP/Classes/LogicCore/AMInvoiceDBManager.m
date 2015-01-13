//
//  AMInvoiceDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/18/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMInvoiceDBManager.h"
#import "AMDBInvoice.h"

@implementation AMInvoiceDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBInvoice";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMInvoice * invoice = (AMInvoice *)object;
    AMDBInvoice * dbInvoice = (AMDBInvoice *)dbObject;
    
    dbInvoice.assetID = invoice.assetID;
    dbInvoice.createdBy = invoice.createdBy;
    dbInvoice.invoiceNumber = invoice.invoiceNumber;
    dbInvoice.lastModifiedBy = invoice.lastModifiedBy;
    dbInvoice.posID = invoice.posID;
    dbInvoice.woID = invoice.woID;
    dbInvoice.userID = invoice.userID;
    dbInvoice.invoiceID = invoice.invoiceID;
    dbInvoice.price = invoice.price;
    dbInvoice.quantity = invoice.quantity;
    dbInvoice.filterID = invoice.filterID;
    dbInvoice.filterName = invoice.filterName;
    dbInvoice.partsID = invoice.partsID;
    dbInvoice.partsName = invoice.partsName;
    dbInvoice.hoursRate = invoice.hoursRate;
    dbInvoice.hoursWorked = invoice.hoursWorked;
    dbInvoice.lastModifiedDate = invoice.lastModifiedDate;
    dbInvoice.workPerformed = invoice.workPerformed;
    dbInvoice.maintenanceFee = invoice.maintenanceFee;
    dbInvoice.recordTypeName = invoice.recordTypeName;
    dbInvoice.recordTypeID = invoice.recordTypeID;
    dbInvoice.unitPrice = invoice.unitPrice;
    dbInvoice.invoiceCodeId = invoice.invoiceCodeId;
    dbInvoice.invoiceCodeName = invoice.invoiceCodeName;
    dbInvoice.posName = invoice.posName;
    dbInvoice.caseId = invoice.caseId;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMInvoice * invoice = [[AMInvoice alloc] init];
    AMDBInvoice * dbInvoice = (AMDBInvoice *)dbObject;
    
    invoice.assetID = dbInvoice.assetID;
    invoice.createdBy = dbInvoice.createdBy;
    invoice.invoiceNumber = dbInvoice.invoiceNumber;
    invoice.lastModifiedBy = dbInvoice.lastModifiedBy;
    invoice.posID = dbInvoice.posID;
    invoice.woID = dbInvoice.woID;
    invoice.userID = dbInvoice.userID;
    invoice.invoiceID = dbInvoice.invoiceID;
    invoice.price = dbInvoice.price;
    invoice.quantity = dbInvoice.quantity;
    invoice.filterID = dbInvoice.filterID;
    invoice.filterName = dbInvoice.filterName;
    invoice.partsID = dbInvoice.partsID;
    invoice.partsName = dbInvoice.partsName;
    invoice.hoursRate = dbInvoice.hoursRate;
    invoice.hoursWorked = dbInvoice.hoursWorked;
    invoice.lastModifiedDate = dbInvoice.lastModifiedDate;
    invoice.workPerformed = dbInvoice.workPerformed;
    invoice.maintenanceFee = dbInvoice.maintenanceFee;
    invoice.recordTypeName = dbInvoice.recordTypeName;
    invoice.recordTypeID = dbInvoice.recordTypeID;
    invoice.unitPrice = dbInvoice.unitPrice;
    invoice.invoiceCodeId = dbInvoice.invoiceCodeId;
    invoice.invoiceCodeName = dbInvoice.invoiceCodeName;
    invoice.posName = dbInvoice.posName;
    invoice.caseId = dbInvoice.caseId;
    
    return invoice;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMInvoice * invoice = (AMInvoice *)data;
    
    return [NSPredicate predicateWithFormat:@"invoiceID = %@",invoice.invoiceID];
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    AMDBInvoice * dbInvoice = (AMDBInvoice *)dbObject;
    if ([field isEqualToString:@"lastModifiedBy"]) {
        dbInvoice.lastModifiedBy = value;
    }
    
}

- (void)replaceFields:(NSDictionary *)idMaps toDBObject:(id)dbObject
{
    AMDBInvoice * invoice = (AMDBInvoice *)dbObject;
    
    if ([idMaps objectForKey:invoice.invoiceID]) {
        invoice.invoiceID = [idMaps objectForKey:invoice.invoiceID];
        invoice.createdBy = nil;
    }
}

#pragma mark - Methods
+ (AMInvoiceDBManager *)sharedInstance
{
    static AMInvoiceDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMInvoiceDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
