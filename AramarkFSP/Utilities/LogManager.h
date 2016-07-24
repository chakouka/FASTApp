//
//  LogManager.h
//  AramarkFSP
//
//  Created by Bruno Nader on 7/22/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogManager : NSObject


#define LOG_FILE_NAME @"fast.log"
#define LOG_ZIP_FILE_NAME @"fast.zlib"

#define FLog(fmt, ...) [[LogManager sharedInstance] log:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__];

+ (LogManager *)sharedInstance;
- (void)log:(NSString *)format, ...;

@end
