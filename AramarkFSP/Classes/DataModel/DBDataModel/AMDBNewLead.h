//
//  AMDBNewLead.h
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/16/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBNewLead : NSManagedObject

@property (nonatomic, retain) NSString * street2;
@property (nonatomic, retain) NSString * zipCode;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic, retain) NSString * companySize;
@property (nonatomic, retain) NSString * currentProvider;
@property (nonatomic, retain) NSString * referingEmployee;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * stateProvince;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * fakeID;
@property (nonatomic, retain) NSNumber * dataStatus;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSString * salesforceId;
@property (nonatomic, retain) NSString * salutation;
@property (nonatomic, retain) NSNumber * hasCoffee;
@property (nonatomic, retain) NSNumber * hasWater;
@property (nonatomic, retain) NSNumber * hasIce;
@property (nonatomic, retain) NSNumber * hasPrivateLabel;
@property (nonatomic, retain) NSNumber * hasSingleCup;
@property (nonatomic, retain) NSString * satisfactionLevel;

@end
