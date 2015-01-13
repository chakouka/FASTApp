//
//  AMProtocolParserTest.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 7/2/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMProtocolParser.h"

@interface AMProtocolParserTest : XCTestCase

@end

@implementation AMProtocolParserTest

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

- (void)testDateTransform
{
    /* 
     (Event) Id = 00Uf0000002qdWzEAI;
     (WO) Id = a0nf0000001JvmXAAS; WO Number = WO-00000454;
     "Actual_End_Time__c" = "2014-06-25T09:50:46.000+0000";
     "Actual_Start_Time__c" = "2014-06-25T09:50:45.000+0000";
     on website: 6/25/2014 5:50 AM
     */
    
    NSString *dateString = @"2014-06-25T09:50:46.000+0000";
    NSDate *date = [[AMProtocolParser sharedInstance] dateFromSalesforceDateString:dateString];
    NSLog(@"local date: %@", date);
    
    NSString *dateStringForSalesforce = [[AMProtocolParser sharedInstance] dateStringForSalesforceFromDate:date];
    NSLog(@"upload date: %@", dateStringForSalesforce);
}

@end
