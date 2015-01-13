//
//  AMDBPoS.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/11/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBPoS : NSManagedObject

@property (nonatomic, retain) NSString * bdm;
@property (nonatomic, retain) NSString * driverName;
@property (nonatomic, retain) NSString * kam;
@property (nonatomic, retain) NSString * lastModifiedBy;
@property (nonatomic, retain) NSString * meiNumber;
@property (nonatomic, retain) NSString * naBillingType;
@property (nonatomic, retain) NSString * nam;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * parkingDetail;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * routeLookupID;
@property (nonatomic, retain) NSNumber * routeNumber;
@property (nonatomic, retain) NSString * segment;
@property (nonatomic, retain) NSString * routeLookupName;

@end
