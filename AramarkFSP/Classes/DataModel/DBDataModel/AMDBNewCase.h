//
//  AMDBNewCase.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 8/1/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBNewCase : NSManagedObject

@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * accountName;
@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSString * assetNumber;
@property (nonatomic, retain) NSString * caseDescription;
@property (nonatomic, retain) NSString * caseNumber;
@property (nonatomic, retain) NSString * contactEmail;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * dataStatus;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSString * fakeID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * mEI_Customer;
@property (nonatomic, retain) NSString * point_of_Service;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * posName;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * recordTypeID;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * recordTypeName;

@end
