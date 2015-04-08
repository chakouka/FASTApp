//
//  AMContactDBManager.m
//  AramarkFSP
//
//  Created by Appledev010 on 5/17/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMContactDBManager.h"
#import "AMDBContact.h"

@implementation AMContactDBManager

#pragma mark - Internal Methods

- (id)init
{
    self = [super init];
    
    _entityName = @"AMDBContact";
    
    return self;
}

- (void)transferObject:(id)object toDBObject:(id)dbObject
{
    AMContact * contact = (AMContact *)object;
    AMDBContact * dbContact = (AMDBContact *)dbObject;
    
    dbContact.name = contact.name;
    dbContact.phone = contact.phone;
    dbContact.role = contact.role;
    dbContact.email = contact.email;
    dbContact.posID = contact.posID;
    dbContact.accountID = contact.accountID;
    dbContact.contactID = contact.contactID;
    dbContact.firstName = contact.firstName;
    dbContact.lastName = contact.lastName;
    dbContact.title = contact.title;
    dbContact.lastModifiedBy = contact.lastModifiedBy;
    dbContact.lastModifiedDate = contact.lastModifiedDate;
    dbContact.shouldDelete = contact.shouldDelete;
}

- (id)transferDBObjectToObject:(id)dbObject
{
    AMContact * contact = [[AMContact alloc] init];
    AMDBContact * dbContact = (AMDBContact *)dbObject;
    
    contact.name = dbContact.name;
    contact.phone = dbContact.phone;
    contact.role = dbContact.role;
    contact.email = dbContact.email;
    contact.posID = dbContact.posID;
    contact.accountID = dbContact.accountID;
    contact.contactID = dbContact.contactID;
    contact.firstName = dbContact.firstName;
    contact.lastName = dbContact.lastName;
    contact.title = dbContact.title;
    contact.lastModifiedBy = dbContact.lastModifiedBy;
    contact.lastModifiedDate = dbContact.lastModifiedDate;
    contact.shouldDelete = dbContact.shouldDelete;
    return contact;
}

- (void)handleObject:(id)data existDBObject:(id)dbData
{
    [self transferObject:data toDBObject:dbData];
}

- (NSPredicate *)getCheckExistFilter:(id)data
{
    AMContact * contact = (AMContact *)data;
    
    return [NSPredicate predicateWithFormat:@"contactID = %@",contact.contactID];
}

#pragma mark - Methods
+ (AMContactDBManager *)sharedInstance
{
    static AMContactDBManager *sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMContactDBManager alloc] init];
    });
    
    return sharedInstance;
    
}

- (void)replaceFields:(NSString *)field withValue:(id)value toDBObject:(id)dbObject
{
    AMDBContact * dbContact = (AMDBContact *)dbObject;
    if ([field isEqualToString:@"lastModifiedDate"]) {
        dbContact.lastModifiedDate = value;
    }

}
@end
