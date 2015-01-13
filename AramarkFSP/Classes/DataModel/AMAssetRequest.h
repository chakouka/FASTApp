//
//  AMAssetRequest.h
//  AramarkFSP
//
//  Created by Appledev010 on 6/11/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMAssetRequest : NSObject

@property (nonatomic, strong) NSString * assetID;
@property (nonatomic, strong) NSString * requestID;
@property (nonatomic, strong) NSString * locationID;
@property (nonatomic, strong) NSString * posID;
@property (nonatomic, strong) NSString * machineNumber;
@property (nonatomic, strong) NSString * serialNumber;
@property (nonatomic, strong) NSString * updatedMNumber;
@property (nonatomic, strong) NSString * updatedSNumber;
@property (nonatomic, strong) NSString * createdBy;
@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSString * woID;
@property (nonatomic, strong) NSString * machineType;
@property (nonatomic, strong) NSDate * verifiedDate;
@property (nonatomic, strong) NSString * verifyNotes;
@property (nonatomic, retain) NSString * statusID;

@end
