//
//  AMDBNewCase+Create.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/24/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMDBNewCase+AddOn.h"

@implementation AMDBNewCase (AddOn)

+(AMDBNewCase *)newEntityInManagedObjectContext:(NSManagedObjectContext *)context
{
    AMDBNewCase *entity = nil;
    entity = [NSEntityDescription insertNewObjectForEntityForName:@"AMDBNewCase" inManagedObjectContext:context];
    entity.createdDate = [NSDate date];
    entity.dataStatus = [NSNumber numberWithInt:EntityStatusNew];
    entity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];;

    return entity;
}

-(NSDictionary *)dictionaryToCreateObject
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:self.fakeID forKeyPath:@"fakeId"];
    [dict setValue:self.recordTypeID forKeyPath:@"RecordTypeId"];
    [dict setValue:self.recordTypeName forKeyPath:@"RecordTypeName"];
    [dict setValue:self.type forKeyPath:@"Type"];
    [dict setValue:self.accountID forKeyPath:@"Account"];
    [dict setValue:self.point_of_Service forKeyPath:@"Point_of_Service__c"];
    [dict setValue:self.mEI_Customer forKeyPath:@"MEI_Customer__c"];
    [dict setValue:self.priority forKeyPath:@"Priority"];
    [dict setValue:self.subject forKeyPath:@"Subject"];
    [dict setValue:self.contactID forKeyPath:@"Contact"];
    [dict setValue:self.contactEmail forKeyPath:@"ContactEmail"];
    [dict setValue:self.caseDescription forKeyPath:@"Description"];
    [dict setValue:self.assetID forKeyPath:@"Asset"];
    [dict setValue:self.serialNumber forKeyPath:@"SerialNumber"];
    [dict setValue:self.firstName forKeyPath:@"FirstName"];
    [dict setValue:self.lastName forKeyPath:@"LastName"];

    return dict;
}

//@property (nonatomic, retain) NSString * accountID;
//@property (nonatomic, retain) NSString * assetID;
//@property (nonatomic, retain) NSString * caseDescription;
//@property (nonatomic, retain) NSString * contactEmail;
//@property (nonatomic, retain) NSString * contactID;
//@property (nonatomic, retain) NSDate * createdDate;
//@property (nonatomic, retain) NSNumber * dataStatus;
//@property (nonatomic, retain) NSString * errorMessage;
//@property (nonatomic, retain) NSString * fakeID;
//@property (nonatomic, retain) NSString * firstName;
//@property (nonatomic, retain) NSString * id;
//@property (nonatomic, retain) NSString * lastName;
//@property (nonatomic, retain) NSString * mEI_Customer;
//@property (nonatomic, retain) NSString * point_of_Service;
//@property (nonatomic, retain) NSString * priority;
//@property (nonatomic, retain) NSString * recordTypeID;
//@property (nonatomic, retain) NSString * serialNumber;
//@property (nonatomic, retain) NSString * subject;
//@property (nonatomic, retain) NSString * type;
//@property (nonatomic, retain) NSString * accountName;
//@property (nonatomic, retain) NSString * posID;
//@property (nonatomic, retain) NSString * posName;
//@property (nonatomic, retain) NSString * assetNumber;

@end










