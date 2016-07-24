//
//  FileManager.h
//  AramarkFSP
//
//  Created by Bruno Nader on 7/24/16.
//  Copyright © 2016 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOG_FILE_MAX_SIZE 3000000 // 3 MB
#define LOG_FILE_NAME @"fast.log"
#define BACKUP_LOG_FILE_NAME @"fast-backup.log"

@interface FileManager : NSObject

+ (BOOL) isFileBiggerThanAllowed:(NSString *) fileName;
+ (void) renameFileInDirectory:(NSString *) directory FileName:(NSString *)name
                   NewFileName:(NSString *) newName;

@end
