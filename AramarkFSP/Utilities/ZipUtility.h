//
//  ZipUtility.h
//  AramarkFSP
//
//  Created by Bruno Nader on 7/24/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "zlib.h"

@interface ZipUtility : NSObject

+ (NSData *) gzipData: (NSData *) pUncompressedData;

@end
