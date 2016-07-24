//
//  LogManager.m
//  AramarkFSP
//
//  Created by Bruno Nader on 7/22/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import "FileManager.h"

@implementation LogManager

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
        NSError *error;
        NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:LOG_FILE_NAME];
        
        if ([FileManager isFileBiggerThanAllowed:filePath])
        {
            filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:BACKUP_LOG_FILE_NAME];
        }
        
        NSString *messageAndDate = [[NSString alloc] initWithFormat:@"%@ - %@", [NSDate date], message];
        
        [messageAndDate writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Failed to write this data to the log files: %@",
              message);
    }
    
    va_end(ap);
}

@end
