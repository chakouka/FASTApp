//
//  AMLocation.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/4/14.
//  Copyright (c) 2014 Aramark FSP. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMLocation : NSObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * accountID;
@property (nonatomic, strong) NSString * locationID;
@property (nonatomic, strong) NSString * createdBy;
@property (nonatomic, strong) NSDate * createdDate;
@property (nonatomic, strong) NSString * lastModifiedBy;
@property (nonatomic, strong) NSString * location;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * street;
@property (nonatomic, strong) NSDate * lastModifiedDate;
@property (nonatomic, strong) NSString * userID;
@property (nonatomic, strong) NSString * addtionalNotes;
@property (nonatomic, strong) NSNumber * badgeNeeded;
@property (nonatomic, strong) NSNumber * cabinetHeight;
@property (nonatomic, strong) NSNumber * dockAvailable;
@property (nonatomic, strong) NSNumber * doorsRemoved;
@property (nonatomic, strong) NSNumber * doorwayWidth;
@property (nonatomic, strong) NSString * electricOutlet;
@property (nonatomic, strong) NSNumber * electricity3ft;
@property (nonatomic, strong) NSString * elevatorStairs;
@property (nonatomic, strong) NSNumber * elevatorSize;
@property (nonatomic, strong) NSNumber * freightElevator;
@property (nonatomic, strong) NSNumber * personalProtection;
@property (nonatomic, strong) NSNumber * electricalInPlace;
@property (nonatomic, strong) NSNumber * visitByServiceDep;
@property (nonatomic, strong) NSNumber * roomMeasurement;
@property (nonatomic, strong) NSNumber * siteLevel;
@property (nonatomic, strong) NSDate * siteSurveyDate;
@property (nonatomic, strong) NSString * specialNotes;
@property (nonatomic, strong) NSNumber * safetyTraining;
@property (nonatomic, strong) NSString * typeFlooring;
@property (nonatomic, strong) NSNumber * waterSource;
@property (nonatomic, retain) NSString * fakeID;
@property (nonatomic, retain) NSNumber * dataStatus;


@end
