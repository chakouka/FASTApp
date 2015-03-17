//
//  AMDBNewContact.h
//  AramarkFSP
//
//  Created by Brian Kendall 3/16/2015.
//  Copyright (c) 2015 Aramark Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AMDBNewContact : NSManagedObject

@property (nonatomic, retain) NSString * accountID;
@property (nonatomic, retain) NSString * contactID;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * dataStatus;
@property (nonatomic, retain) NSString * errorMessage;
@property (nonatomic, retain) NSString * fakeID;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * posID;
@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSString * title;

@end
