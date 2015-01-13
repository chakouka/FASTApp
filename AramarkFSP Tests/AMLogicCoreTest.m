//
//  AMLogicCoreTest.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/2/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMLogicCore.h"
#import "AMDBManager.h"

@interface AMLogicCoreTest : XCTestCase

@end

@implementation AMLogicCoreTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateCase
{
    __block BOOL isFinishUploading = NO;

    [self createNewCaseInDB];
    
    [[AMLogicCore sharedInstance] uploadCreatedCasesWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        isFinishUploading = YES;
    }];
    
    while (!isFinishUploading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


-(void)createNewCaseInDB
{
    AMDBNewCase *testEntity = [[AMDBManager sharedInstance] createNewCaseInDB];
    
    testEntity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
    testEntity.recordTypeID = @"012f00000000JJIAA2"; // Equipment
    testEntity.type = @"Repair";
    testEntity.accountID = @"001f000000HQq7WAAT";   // CocaCola Co.NY
    testEntity.point_of_Service = @"a00f0000005E14tAAC";    // CHouse 22
    testEntity.mEI_Customer = @"";
    testEntity.priority = @"High";
    testEntity.subject = @"testSubject";
    testEntity.contactID = @"";
    testEntity.contactEmail = @"";
    testEntity.caseDescription = @"testDescriptoin";
    testEntity.assetID = @"02if0000000gsgkAAA"; // Coffee Machine
    testEntity.serialNumber = @"";
    testEntity.dataStatus = [NSNumber numberWithInt: EntityStatusCreated];
    
}



- (void)testCreateWorkOrders
{
    __block BOOL isFinishUploading = NO;
    
    NSArray *newWOinDB = [[AMDBManager sharedInstance] getCreatedWorkOrders];
    for (AMDBNewWorkOrder *newWorkOrder in newWOinDB) {
        newWorkOrder.dataStatus = @(EntityStatusNew);
    }
    
    [self createNewWorkOrderInDB];
    
    [[AMLogicCore sharedInstance] uploadCreatedWorkOrdersWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        isFinishUploading = YES;
    }];
    
    while (!isFinishUploading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}


-(void)createNewWorkOrderInDB
{
    [[AMDBManager sharedInstance] createNewWorkOrderInDBWithAMWorkOrder:nil additionalSetupBlock:^(AMDBNewWorkOrder *newWorkOrder) {
        
        AMDBNewWorkOrder *testEntity = newWorkOrder;
        testEntity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
        testEntity.caseID = @"500f0000005Fho6AAC";
        testEntity.recordTypeID = @"012f00000000JV3AAM";    // Repair
        
        testEntity.posID = @"a00f0000005CkGOAA0";    // Center No.12
        //    testEntity.contactID = @"003f000000GjU5u";
        //    testEntity.caseDescription = @"testDescriptoin";
        testEntity.assetID = @"02if0000000aHIvAAM"; // Coffee Machine
        //    testEntity.callAhead = [NSNumber numberWithBool:YES];
        //    testEntity.complaintCode = @"testComplaintCode";
        //    testEntity.currentLocation = @"Room Venus 4114 14th Avenue New York City New York";
        testEntity.endDateTime = [NSDate dateWithTimeIntervalSinceNow:2*60*60];
        //    testEntity.machineTypeID = @"01tf0000002GhOsAAK";
        //    testEntity.preferredScheduleTimeFrom = @"8:00";
        //    testEntity.preferredScheduleTimeTo = @"10:00";
        testEntity.startDateTime = [NSDate date];
        //    testEntity.status = @"Open";
        //    testEntity.underWarranty = [NSNumber numberWithBool:YES];
        //    testEntity.vendKey = @"";
        testEntity.dataStatus = @(EntityStatusCreated);
    } completion:^(NSInteger type, NSError *error) {
        
    }];
    


}

-(void)testGetMaintainanceFee
{
//     AMDBCustomerPrice *customerPrice = [[AMLogicCore sharedInstance] getMaintainanceFeeByWOID:self.workOrder.woID];
    
}

-(void)testUploadNewLeads
{
    __block BOOL isFinishUploading = NO;

    
    [[AMLogicCore sharedInstance] createNewLeadInDBWithSetupBlock:^(AMDBNewLead *newLead) {        
        newLead.street2 = @"steet2";
        newLead.zipCode = @"12345";
        newLead.title = @"title";
        newLead.emailAddress = @"email@address.com";
        newLead.phoneNumber = @"123456789";
        newLead.companyName = @"company name";
        newLead.companySize = @"company size";
        newLead.currentProvider = @"current provider";
        newLead.referingEmployee = @"refering employee";
        newLead.street = @"street";
        newLead.stateProvince = @"state province";
        newLead.firstName = @"aaa";
        newLead.lastName = @"bbb";
        newLead.city = @"city";
        newLead.country = @"country";
        newLead.comments = @"comments";
        newLead.salutation = @"Mr.";
        

        newLead.hasCoffee = @YES;
        newLead.hasWater = @YES;
        newLead.hasIce = @NO;
        newLead.hasPrivateLabel = @NO;
        newLead.hasSingleCup = @YES;
        newLead.satisfactionLevel = @"Satisfied";
        
    } completion:^(NSInteger type, NSError *error) {
        if (error) {
            
        } else {
            [[AMLogicCore sharedInstance] uploadCreatedNewLeadsWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
                XCTAssertNil(error, @"upload new leads error: %@", error.localizedDescription);
                
                isFinishUploading = YES;
            }];
        }
    }];
    
    while (!isFinishUploading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}



@end




