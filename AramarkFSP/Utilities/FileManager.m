//
//  FileManager.m
//  AramarkFSP
//
//  Created by Bruno Nader on 7/24/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

+ (void) renameFileInDirectory:(NSString *) directory FileName:(NSString *)name
                   NewFileName:(NSString *) newName
{
    // Rename the file, by moving the file
    NSString *newFilePath = [directory
                             stringByAppendingPathComponent:newName];
    
    NSString *filePath = [directory stringByAppendingString:name];
    
    NSError *error;
    
    //first remove backup file if exists..
    [[NSFileManager defaultManager] removeItemAtPath:newFilePath error:&error];
    
    // Attempt the move
    if ([[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newFilePath error:&error] != YES)
        NSLog(@"Unable to move file: %@", [error localizedDescription]);
}

+ (BOOL) isFileBiggerThanAllowed:(NSString *) fileName
{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSError *attributesError;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileName error:&attributesError];
    
    NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
    long long fileSize = [fileSizeNumber longLongValue];
    
    if (fileSize > LOG_FILE_MAX_SIZE)
    {
        [FileManager renameFileInDirectory:directory FileName:LOG_FILE_NAME NewFileName:BACKUP_LOG_FILE_NAME];
        
        return YES;
    }
    else
        return NO;
}

@end
