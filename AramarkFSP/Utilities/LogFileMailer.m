//
//  LogFileMailer.m
//  AramarkFSP
//
//  Created by Bruno Nader on 7/24/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import "LogFileMailer.h"
#import "FileManager.h"
#import "ZipUtility.h"
#import "LogManager.h"

#define LOG_FILE_EMAIL_RECIPIENT @"Kendall-Brian@aramark.com; pkrepsztul@simplinova.com"

@implementation LogFileMailer

-(id) init
{
    if (self = [super init])
    {
        self.subject =  @"";
        self.body = @"";
        self.recipients = nil;
        self.attachments = nil;
        self.isHtml = NO;
    }
    
    return self;
}

-(void) composeLogsEmail
{
    self.subject =  @"FAST Log Files";
    self.body = [self getMessageBodyContent];
    self.recipients = @[@"Kendall-Brian@aramark.com",@"pkrepsztul@simplinova.com"];
    self.attachments = [self getAttachments];
    self.isHtml = NO;
}


-(NSString *) getMessageBodyContent
{
    return @"Emailing FAST app log files attached.";
}

- (NSArray *) getAttachments
{
    @try
    {
        NSMutableArray *arrayOfCompressedFiles = [NSMutableArray new];
        
        NSArray *logFilesArray = [NSArray arrayWithObjects:
                         LOG_FILE_NAME,
                         BACKUP_LOG_FILE_NAME,
                         DB_FILE_NAME,
                         nil];
        
        __block NSInteger counter = 1;
        
        [logFilesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            
            NSData *umcompressedData = [NSData dataWithContentsOfFile:
                                        [FileManager getFilePathInDirectory:directory WithName:obj]];
        
            if (umcompressedData != nil)
            {
                
                NSData *compressedData = [ZipUtility gzipData:umcompressedData];
                
                NSString *fileName = [NSString stringWithFormat:@"%ld-%@", (long)counter, LOG_ZIP_FILE_NAME];
                
                NSMutableDictionary *dict = [NSMutableDictionary new];
                
                [dict setObject:compressedData forKey:fileName];
                [arrayOfCompressedFiles addObject:dict];
            }
            
            counter++;
            
        }];
        
        return arrayOfCompressedFiles;
    }
    @catch (NSException *exception)
    {
        FLog(@"Exception when trying to get Attachments for emailing the log files: %@", exception)
        
        return nil;
    }
}


@end
