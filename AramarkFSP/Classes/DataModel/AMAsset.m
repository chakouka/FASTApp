//
//  AMAsset.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/8/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import "AMAsset.h"


@implementation AMAsset

@synthesize assetID;
@synthesize installDate;
@synthesize lastModifiedBy;
@synthesize lastModifiedDate;
@synthesize lastVerifiedDate;
@synthesize locationID;
@synthesize machineNumber;
@synthesize machineType;
@synthesize nextPMDate;
@synthesize posID;
@synthesize serialNumber;
@synthesize vendKey;
@synthesize notes;
@synthesize userID;
@synthesize productID;
@synthesize verificationStatus;
@synthesize assetName;
@synthesize mMachineNumber;
@synthesize mSerialNumber;
@synthesize assetLocation;

@synthesize repairWOHistory;
@synthesize locationName;

- (NSString *)description
{
    return [NSString stringWithFormat:@"assetID : %@ | assetName : %@ | serialNumber : %@ | posID : %@ | verificationStatus : %@",assetID,assetName,serialNumber,posID,verificationStatus];
}

@end
