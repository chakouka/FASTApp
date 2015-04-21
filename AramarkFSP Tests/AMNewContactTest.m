//
//  AMNewContactTest.m
//  AramarkFSP
//
//  Created by bkendall on 4/20/15.
//  Copyright (c) 2015 PWC Inc. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "AMLogicCore.h"
#import "AMDBNewContact+AddOn.h"
#import "AMDBManager.h"
#import "AMProtocolManager.h"

@interface AMNewContactTest : XCTestCase

@end
@implementation AMNewContactTest
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

- (void)testCreateNewContact {
    
    __block BOOL isFinishUploading = NO;
    
    
    NSArray *dataArray = @[//[self newCaseWithPoSID],
                           //[self newCaseWithMEICustomer],
                           //[self newCaseWithContactID],
                           //[self newCaseWithContactEmail]
                           ];
    
    [[AMProtocolManager sharedInstance]
     createObjectsWithManagedObjects:dataArray
     operationType:AM_REQUEST_ADDCASE
     completion:^(NSInteger type, NSError *error, id userData, id responseData) {
         XCTAssertNil(error, @"Error: %@", error.localizedDescription);
         if (!error) {
             DLog(@"Create contact success with responseData %@", [responseData description]);
         }
         isFinishUploading = YES;
     }];
    
    while (!isFinishUploading) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}
@end