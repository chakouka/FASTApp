//
//  AMCase.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/4/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMCase : NSObject

@property (nonatomic, strong) NSString * owner;
@property (nonatomic, strong) NSString * caseNumber;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSString * caseDescription;
@property (nonatomic, strong) NSString * priority;
@property (nonatomic, strong) NSString * status;
@property (nonatomic, strong) NSDate * closedDate;
@property (nonatomic, strong) NSString * closedBy;
@property (nonatomic, strong) NSString * lastModifiedBy;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSString * caseID;
@property (nonatomic, strong) NSString * accountID;
@property (nonatomic, strong) NSString * signContactID;
@property (nonatomic, strong) NSString * signFirstName;
@property (nonatomic, strong) NSString * signLastName;
@property (nonatomic, strong) NSString * signTitle;
@property (nonatomic, strong) NSString * signContactInfo;
@property (nonatomic, strong) NSString * signContactEmail;
@property (nonatomic, strong) NSString * signContactPhone;
@property (nonatomic, strong) NSArray * woList;
@property (nonatomic, retain) NSString * meiCustomer;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * contactId;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSNumber * estimatedTotalPrice;

@end
