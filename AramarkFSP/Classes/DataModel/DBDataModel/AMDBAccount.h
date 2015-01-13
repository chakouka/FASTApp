//
//  AMDBAccount.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/17/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBAccount : NSManagedObject

@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSDate * atRisk;
@property (nonatomic, retain) NSString * fspSalesConsultant;
@property (nonatomic, retain) NSNumber * isNationalAccount;
@property (nonatomic, retain) NSString * kam;
@property (nonatomic, retain) NSNumber * keyAccount;
@property (nonatomic, retain) NSString * nam;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * naNumber;
@property (nonatomic, retain) NSString * nationalAccount;
@property (nonatomic, retain) NSString * parentAccount;
@property (nonatomic, retain) NSString * salesConsultant;
@property (nonatomic, retain) NSString * atRiskReason;

@end
