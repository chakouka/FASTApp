//
//  AMAccount.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/9/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMAccount : NSObject

@property (nonatomic, strong) NSString * accountID;
@property (nonatomic, strong) NSDate * atRisk;
@property (nonatomic, strong) NSNumber * isNationalAccount;
@property (nonatomic, strong) NSString * kam;
@property (nonatomic, strong) NSString * nam;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * nationalAccount;
@property (nonatomic, strong) NSString * parentAccount;
@property (nonatomic, strong) NSString * salesConsultant;
@property (nonatomic, strong) NSArray * pendingWOList;
@property (nonatomic, strong) NSArray * locationList;
@property (nonatomic, retain) NSString * fspSalesConsultant;
@property (nonatomic, retain) NSString * naNumber;
@property (nonatomic, retain) NSNumber * keyAccount;
@property (nonatomic, retain) NSString * atRiskReason;

@end
