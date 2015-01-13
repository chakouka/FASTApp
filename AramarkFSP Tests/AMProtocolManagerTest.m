//
//  AMProtocolManagerTest.m
//  AramarkFSP
//
//  Created by Haipeng ZHAO on 6/26/2014.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AMProtocolManager.h"
#import "AMDBManager.h"
#import "AMFileCache.h"

@interface AMProtocolManagerTest : XCTestCase

@end

@implementation AMProtocolManagerTest

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

- (void)testGetHttpParamsString
{
    NSDictionary *dict = @{@"act": @"past",
                           @"pastx": @"10"};
    SEL selector = NSSelectorFromString(@"getHttpParamsString:");
    
    if ([[AMProtocolManager sharedInstance] respondsToSelector:selector]) {
        NSString *string = [[AMProtocolManager sharedInstance] performSelector:selector withObject:dict];
        NSLog(@"%@", string);
    }

}

- (void)testGetReportData
{
    __block BOOL isFinishFetching = NO;
    
    [[AMProtocolManager sharedInstance] getReportDataWithCompletion:^(NSInteger type, NSError *error, id userData, id responseData) {
        XCTAssertNil(error, @"error: %@", error.localizedDescription);
        XCTAssertNotNil(responseData, @"response data is nil");
        
        NSDictionary *reportData = reportData;
        NSLog(@"report: %@", reportData);
        
        isFinishFetching = YES;
    }];
    

    
    while (!isFinishFetching) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

-(void)testAttachementEndPoint
{
    NSURL *url = [[AMProtocolManager sharedInstance] getAttachmentEndpoint];
    XCTAssertNotNil(url, @"no attachment endpoint");
    NSLog(@"attachment endpoint: %@", url.absoluteString);
}

-(void)testDownloadUnfetchedAttachments
{
    __block BOOL isFinishFetching = NO;

    [[AMProtocolManager sharedInstance] downloadUnfetchedAttachments];
    
    while (!isFinishFetching) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

//-(void)testUploadAttachments
//{
//    __block BOOL isFinishFetching = NO;
//
//    AMDBAttachment *attachment = [[AMDBManager sharedInstance] createNewAttachmentWithSetupBlock:^(AMDBAttachment *newAttachment) {
//        attachment.parentId = @"a0nf0000001L02fAAC"; // 1194
//        attachment.localURL = [[[AMFileCache sharedInstance] directoryName] stringByAppendingString:@"/00Pf0000000ye8OEAQ"];
//    }];
//
//    attachment.parentId = @"a0nf0000001L02fAAC"; // 1194
//    attachment.localURL = [NSTemporaryDirectory() stringByAppendingString:@"servlet (1).jpeg"];
//    
//    [[AMProtocolManager sharedInstance]  uploadAttachments:@[attachment] completion:^(NSInteger type, NSError *error, id userData, id responseData) {
//        
//        isFinishFetching = YES;
//
//    }];
//    
//    while (!isFinishFetching) {
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    }
//}


@end












