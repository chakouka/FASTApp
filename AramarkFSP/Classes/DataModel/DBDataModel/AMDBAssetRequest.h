//
//  AMDBAssetRequest.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/18/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBAssetRequest : NSManagedObject

@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * locationID;
@property (nonatomic, retain) NSString * machineNumber;
@property (nonatomic, retain) NSString * machineType;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * requestID;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * updatedMNumber;
@property (nonatomic, retain) NSString * updatedSNumber;
@property (nonatomic, retain) NSDate * verifiedDate;
@property (nonatomic, retain) NSString * verifyNotes;
@property (nonatomic, retain) NSString * woID;
@property (nonatomic, retain) NSString * statusID;
@property (nonatomic, retain) NSString *moveToWarehouse;

@end
