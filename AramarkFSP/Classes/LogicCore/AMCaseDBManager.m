//
//  AMCaseDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMCaseDBManager.h"
#import "AMDBCase.h"

@implementation AMCaseDBManager
#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBCase";
    
    return self;
}


- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMCase * amCase = (AMCase *)object;
    AMDBCase * dbCase = (AMDBCase *)dbObject;
    
    dbCase.owner = amCase.owner;
    dbCase.caseNumber = amCase.caseNumber;
    dbCase.subject = amCase.subject;
    dbCase.caseDescription = amCase.caseDescription;
    dbCase.priority = amCase.priority;
    dbCase.status = amCase.status;
    dbCase.closedDate = amCase.closedDate;
    dbCase.closedBy = amCase.closedBy;
    dbCase.lastModifiedBy = amCase.lastModifiedBy;
    dbCase.lastModifiedDate = amCase.lastModifiedDate;
    dbCase.caseID = amCase.caseID;
    dbCase.accountID = amCase.accountID;
    if (!dbCase.signContactID) {
        dbCase.signContactID = amCase.signContactID;
    }
    if (!dbCase.signContactInfo) {
        dbCase.signContactInfo = amCase.signContactInfo;
    }
    if (!dbCase.signContactPhone) {
        dbCase.signContactPhone = amCase.signContactPhone;
    }
    if (!dbCase.signContactEmail) {
        dbCase.signContactEmail = amCase.signContactEmail;
    }
    if (!dbCase.signFirstName) {
        dbCase.signFirstName = amCase.signFirstName;
    }
    if (!dbCase.signLastName) {
        dbCase.signLastName = amCase.signLastName;
    }
    if (!dbCase.signTitle) {
        dbCase.signTitle = amCase.signTitle;
    }
    dbCase.meiCustomer = amCase.meiCustomer;
    dbCase.createdDate = amCase.createdDate;
    dbCase.contactId = amCase.contactId;
    dbCase.contactName = amCase.contactName;
    dbCase.estimatedTotalPrice = amCase.estimatedTotalPrice;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMCase * amCase = [[AMCase alloc] init];
    AMDBCase * dbCase = (AMDBCase *)dbObject;
    
    amCase.owner = dbCase.owner;
    amCase.caseNumber = dbCase.caseNumber;
    amCase.subject = dbCase.subject;
    amCase.caseDescription = dbCase.caseDescription;
    amCase.priority = dbCase.priority;
    amCase.status = dbCase.status;
    amCase.closedDate = dbCase.closedDate;
    amCase.closedBy = dbCase.closedBy;
    amCase.lastModifiedBy = dbCase.lastModifiedBy;
    amCase.lastModifiedDate = dbCase.lastModifiedDate;
    amCase.caseID = dbCase.caseID;
    amCase.accountID = dbCase.accountID;
    amCase.signContactID = dbCase.signContactID;
    amCase.signContactInfo = dbCase.signContactInfo;
    amCase.signContactEmail = dbCase.signContactEmail;
    amCase.signContactPhone = dbCase.signContactPhone;
    amCase.signFirstName = dbCase.signFirstName;
    amCase.signLastName = dbCase.signLastName;
    amCase.signTitle = dbCase.signTitle;
    amCase.meiCustomer = dbCase.meiCustomer;
    amCase.createdDate = dbCase.createdDate;
    amCase.contactId = dbCase.contactId;
    amCase.contactName = dbCase.contactName;
    amCase.estimatedTotalPrice = dbCase.estimatedTotalPrice;
    
    return amCase;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMCase * amCase = (AMCase *)data;
    
    return [NSPredicate predicateWithFormat:@"caseID = %@",amCase.caseID];
}

#pragma mark - Methods
+ (AMCaseDBManager *)sharedInstance
{
    static AMCaseDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMCaseDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

@end
