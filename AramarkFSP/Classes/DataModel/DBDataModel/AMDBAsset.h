//
//  AMDBAsset.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/19/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBAsset : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * assetName;
@property (nonatomic, retain) NSDate * installDate;
@property (nonatomic, retain) NSString * lastModifiedBy;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSDate * lastVerifiedDate;
@property (nonatomic, retain) NSString * locationID;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSString * machineNumber;
@property (nonatomic, retain) NSString * machineType;
@property (nonatomic, retain) NSString * mMachineNumber;
@property (nonatomic, retain) NSString * mSerialNumber;
@property (nonatomic, retain) NSDate * nextPMDate;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * productID;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * vendKey;
@property (nonatomic, retain) NSString * verificationStatus;
@property (nonatomic, retain) NSString * manufacturerWebsite;

@end
