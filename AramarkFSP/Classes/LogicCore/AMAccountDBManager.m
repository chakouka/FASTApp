//
//  AMAccountDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMAccountDBManager.h"
#import <CoreData/CoreData.h>
#import "AMDBAccount.h"

@implementation AMAccountDBManager

#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBAccount";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMAccount * account = (AMAccount *)object;
    AMDBAccount * dbAccount = (AMDBAccount *)dbObject;
    
    dbAccount.accountID = account.accountID;
    dbAccount.atRisk = account.atRisk;
    dbAccount.isNationalAccount = account.isNationalAccount;
    dbAccount.kam = account.kam;
    dbAccount.nam = account.nam;
    dbAccount.name = account.name;
    dbAccount.nationalAccount = account.nationalAccount;
    dbAccount.parentAccount = account.parentAccount;
    dbAccount.salesConsultant = account.salesConsultant;
    dbAccount.fspSalesConsultant = account.fspSalesConsultant;
    dbAccount.naNumber = account.naNumber;
    dbAccount.keyAccount = account.keyAccount;
    dbAccount.atRiskReason = account.atRiskReason;

}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMAccount * account = [[AMAccount alloc] init];
    AMDBAccount * dbAccount = (AMDBAccount *)dbObject;
    
    account.accountID = dbAccount.accountID;
    account.atRisk = dbAccount.atRisk;
    account.isNationalAccount = dbAccount.isNationalAccount;
    account.kam = dbAccount.kam;
    account.nam = dbAccount.nam;
    account.name = dbAccount.name;
    account.nationalAccount = dbAccount.nationalAccount;
    account.parentAccount = dbAccount.parentAccount;
    account.salesConsultant = dbAccount.salesConsultant;
    account.fspSalesConsultant = dbAccount.fspSalesConsultant;
    account.naNumber = dbAccount.naNumber;
    account.keyAccount = dbAccount.keyAccount;
    account.atRiskReason = dbAccount.atRiskReason;
    
    return account;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMAccount * account = (AMAccount *)data;
    
    return [NSPredicate predicateWithFormat:@"accountID = %@",account.accountID];
}

#pragma mark - Methods
+ (AMAccountDBManager *)sharedInstance
{
    static AMAccountDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMAccountDBManager alloc] init];
    });
    
    return sharedInstance;

}

@end
