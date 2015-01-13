//
//  AMDBManagerTest.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/2/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMDBManager.h"

@interface AMDBManagerTest : XCTestCase

@end

@implementation AMDBManagerTest

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

- (void)testGetMaintanceFee
{
    AMDBCustomerPrice *customerPrice = [[AMDBManager sharedInstance] getMaintainanceFeeByWOID:@"a0nf0000001KFkUAAW"];
    NSLog(@"customer price: %@, %@", customerPrice.productType, customerPrice.price);
    
    NSArray *filters = [[AMDBManager sharedInstance] getFilterListByWOID:@"a0nf0000001JvmXAAS"];
    customerPrice = [filters firstObject];
    NSLog(@"customer price: %@, %@", customerPrice.productType, customerPrice.price);

}

- (void)testGetCreatedCasesHistory
{
    NSArray *array = [[AMDBManager sharedInstance] getCreatedCasesHistoryInRecentDays:15];
    for (AMDBNewCase *newCase in array) {
        NSLog(@"created case: %@", newCase.fakeID);
    }
}

- (void)testGetUnfetchedAttachments
{
    NSArray *array = [[AMDBManager sharedInstance] getUnfetchedAttachments];
    for (AMDBAttachment *attachment in array) {
        NSLog(@"unfetched attachment remote: %@, local: %@", attachment.remoteURL, attachment.localURL);
    }
}

@end







