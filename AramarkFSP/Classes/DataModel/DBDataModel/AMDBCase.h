//
//  AMDBCase.h
//  AramarkFSP
//
//  Created by Aaron Hu on 9/4/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBCase : NSManagedObject

@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * caseDescription;
@property (nonatomic, retain) NSString * caseID;
@property (nonatomic, retain) NSString * caseNumber;
@property (nonatomic, retain) NSString * closedBy;
@property (nonatomic, retain) NSDate * closedDate;
@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSNumber * estimatedTotalPrice;
@property (nonatomic, retain) NSString * lastModifiedBy;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * meiCustomer;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * signContactID;
@property (nonatomic, retain) NSString * signContactInfo;
@property (nonatomic, retain) NSString * signFirstName;
@property (nonatomic, retain) NSString * signLastName;
@property (nonatomic, retain) NSString * signTitle;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSString * signContactPhone;
@property (nonatomic, retain) NSString * signContactEmail;

@end
