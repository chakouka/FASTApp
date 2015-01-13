//
//  AMInvoice.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/4/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMInvoice.h"


@implementation AMInvoice

@synthesize assetID;
@synthesize createdBy;
@synthesize invoiceNumber;
@synthesize lastModifiedBy;
@synthesize lastModifiedDate;
@synthesize posID;
@synthesize woID;
@synthesize invoiceID;
@synthesize userID;
@synthesize price;
@synthesize hoursRate;
@synthesize hoursWorked;
@synthesize maintenanceFee;
@synthesize workPerformed;
@synthesize quantity;
@synthesize filterName;
@synthesize filterID;
@synthesize partsName;
@synthesize partsID;
@synthesize filterUsedList;
@synthesize partsUsedList;
@synthesize recordTypeName;

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ - %@ - %@ - %@ - %@",invoiceID,recordTypeName,price,quantity,woID];
}

@end
