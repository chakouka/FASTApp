//
//  AMAsset.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/8/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMLocation.h"

@interface AMAsset : NSObject

@property (nonatomic, strong) NSString * assetID;
@property (nonatomic, strong) NSString * accountID;
@property (nonatomic, strong) NSDate * installDate;
@property (nonatomic, strong) NSString * lastModifiedBy;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSDate * lastVerifiedDate;
@property (nonatomic, strong) NSString * locationID;
@property (nonatomic, strong) NSString * machineNumber;
@property (nonatomic, strong) NSString * machineType;
@property (nonatomic, strong) NSDate * nextPMDate;
@property (nonatomic, strong) NSString * posID;
@property (nonatomic, strong) NSString * serialNumber;
@property (nonatomic, strong) NSString * vendKey;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSString * productID;
@property (nonatomic, strong) NSString * verificationStatus;
@property (nonatomic, strong) NSString * assetName;
@property (nonatomic, strong) NSString * mMachineNumber;
@property (nonatomic, strong) NSString * mSerialNumber;
@property (nonatomic, strong) AMLocation * assetLocation;

@property (nonatomic, strong) NSArray * repairWOHistory;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * manufacturerWebsite;
@property (nonatomic, retain) NSString *moveToWarehouse;
@end
