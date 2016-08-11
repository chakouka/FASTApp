//
//  LogManager.m
//  AramarkFSP
//
//  Created by Bruno Nader on 7/22/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import "FileManager.h"

@implementation LogManager : NSObject

+ (LogManager *)sharedInstance
{
    static LogManager *instance = nil;
    
    if (instance == nil)
        instance = [[LogManager alloc] init];
    
    return instance;
}

- (void)log:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
#ifdef DEBUG
    NSLog(@"%@", message);
#endif
    
    @try
    {
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:LOG_FILE_NAME];
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        
        NSString *finalMessage = [NSString stringWithFormat:@"%@ - %@\n",
                                  [NSDate date],
                                  message];
        
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[finalMessage dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Failed to write this data to the log files: %@",
              message);
    }
    
    va_end(ap);
}

@end
