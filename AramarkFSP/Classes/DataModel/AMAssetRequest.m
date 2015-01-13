//
//  AMAssetRequest.m
//  AramarkFSP
//
//  Created by Appledev010 on 6/11/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAssetRequest.h"

@implementation AMAssetRequest

@synthesize assetID;
@synthesize requestID;
@synthesize locationID;
@synthesize posID;
@synthesize machineNumber;
@synthesize serialNumber;
@synthesize updatedMNumber;
@synthesize updatedSNumber;
@synthesize createdBy;
@synthesize createdDate;
@synthesize status;
@synthesize woID;
@synthesize machineType;
@synthesize verifiedDate;
@synthesize verifyNotes;

- (NSString *)description
{
    return [NSString stringWithFormat:@"\n assetID : %@ \n locationID : %@ \n posID : %@ \n machineNumber : %@ \n serialNumber : %@ \n updatedMNumber : %@ \n updatedSNumber : %@ \n status : %@ \n verifyNotes : %@",assetID,locationID,posID,machineNumber,serialNumber,updatedMNumber,updatedSNumber,status,verifyNotes];
}

@end
