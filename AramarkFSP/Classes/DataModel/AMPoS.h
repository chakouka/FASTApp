//
//  AMPoS.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/4/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMPoS : NSObject

@property (nonatomic, strong) NSString * posID;
@property (nonatomic, strong) NSString * segment;
@property (nonatomic, strong) NSString * bdm;
@property (nonatomic, strong) NSNumber * routeNumber;
@property (nonatomic, strong) NSString * driverName;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * parkingDetail;
@property (nonatomic, strong) NSString * lastModifiedBy;
@property (nonatomic, strong) NSString * nam;
@property (nonatomic, strong) NSString * kam;
@property (nonatomic, strong) NSArray * pendingWOList;
@property (nonatomic, strong) NSNumber * past28WOCount;
@property (nonatomic, strong) NSArray * contactList;
@property (nonatomic, retain) NSString * meiNumber;
@property (nonatomic, retain) NSString * naBillingType;
@property (nonatomic, retain) NSString * routeLookupID;
@property (nonatomic, retain) NSString * routeLookupName;

@end
