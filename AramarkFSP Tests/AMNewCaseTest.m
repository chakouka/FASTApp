//
//  AramarkFSP_Tests.m
//  AramarkFSP Tests
//
//  Created by Haipeng ZHAO on 6/25/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMLogicCore.h"
#import "AMDBNewCase+AddOn.h"
#import "AMDBManager.h"
#import "AMProtocolManager.h"

@interface AMNewCaseTest : XCTestCase

@end

@implementation AMNewCaseTest

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

- (void)testCreateNewCases
{
    __block BOOL isFinishUploading = NO;
    
    
    NSArray *dataArray = @[[self newCaseWithPoSID],
                           [self newCaseWithMEICustomer],
                           [self newCaseWithContactID],
                           [self newCaseWithContactEmail]];
    
    [[AMProtocolManager sharedInstance]
     createObjectsWithManagedObjects:dataArray
     operationType:AM_REQUEST_ADDCASE
     completion:^(NSInteger type, NSError *error, id userData, id responseData) {
         XCTAssertNil(error, @"Error: %@", error.localizedDescription);
         if (!error) {
             DLog(@"Create case success with responseData %@", [responseData description]);
         }
             isFinishUploading = YES;
     }];
    
    while (!isFinishUploading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
}



-(AMDBNewCase *)newCaseWithPoSID
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
    
    
    return testEntity;
}

-(AMDBNewCase *)newCaseWithMEICustomer
{
    AMDBNewCase *testEntity = [[AMDBManager sharedInstance] createNewCaseInDB];
    
    testEntity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
    testEntity.recordTypeID = @"012f00000000JJIAA2";
    testEntity.type = @"Repair";
    testEntity.accountID = @"001f000000HQq7WAAT";
    testEntity.point_of_Service = @"";
    testEntity.mEI_Customer = @"MEI123456789";
    testEntity.priority = @"High";
    testEntity.subject = @"testSubject";
    testEntity.contactID = @"";
    testEntity.contactEmail = @"";
    testEntity.caseDescription = @"testDescriptoin";
    testEntity.assetID = @"";
    testEntity.serialNumber = @"SN00005001";    // Coca Vending Machine

    return testEntity;
}

-(AMDBNewCase *)newCaseWithContactID
{
    AMDBNewCase *testEntity = [[AMDBManager sharedInstance] createNewCaseInDB];
    
    testEntity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
    testEntity.recordTypeID = @"012f00000000JJIAA2";
    testEntity.type = @"Repair";
    testEntity.accountID = @"001f000000HQq7WAAT";
    testEntity.point_of_Service = @"";
    testEntity.mEI_Customer = @"";
    testEntity.priority = @"High";
    testEntity.subject = @"testSubject";
    testEntity.contactID = @"003f000000HZ59pAAD";
    testEntity.contactEmail = @"";
    testEntity.caseDescription = @"testDescriptoin";
    
    return testEntity;
}

-(AMDBNewCase *)newCaseWithContactEmail
{
    AMDBNewCase *testEntity = [[AMDBManager sharedInstance] createNewCaseInDB];
    
    testEntity.fakeID = [NSString stringWithFormat:@"Fake_%f", [NSDate timeIntervalSinceReferenceDate]];
    testEntity.recordTypeID = @"012f00000000JJIAA2";
    testEntity.type = @"Repair";
    testEntity.accountID = @"001f000000HQq7WAAT";
    testEntity.point_of_Service = @"";
    testEntity.mEI_Customer = @"";
    testEntity.priority = @"High";
    testEntity.subject = @"testSubject";
    testEntity.contactID = @"";
    testEntity.contactEmail = @"michael.jordan@pwc.ny.com";
    testEntity.caseDescription = @"testDescriptoin";
    
    return testEntity;
}



@end








