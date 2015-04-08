//
//  AMProtocolAssembler.h
//  AramarkFSP
//
//  Created by Appledev010 on 5/25/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMProtocolAssembler : NSObject

+ (AMProtocolAssembler *)sharedInstance;

- (NSDictionary *)createObjectWithData:(NSDictionary *)createObj;

- (NSDictionary *)updateObjectWithData:(NSDictionary *)createObj;

- (NSDictionary *)deleteObjectWithData:(NSDictionary *)deleteObj;

- (NSDictionary *)uploadSignatureWithData:(NSArray *)signatureObj;
- (NSDictionary *)setPoSAsset:(NSArray *)assetList;

-(NSDictionary *)parameterDictionaryFromAttachments:(NSArray *)attachments;

-(NSDictionary *)dictionaryWithAllEntityIDsForSync;
-(NSDictionary *)dictionaryWithWorkOrderAndEventIDsForSync;

@end
