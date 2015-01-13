//
//  AMFileCache.m
//  PwC
//
//  Created by David Liu on 13-3-14.
//
//

#import "AMFileCache.h"

#define DIRECTORYVALIDTIMELENGTH 60 * 60 * 24 * 1

@interface AMFileCache ()
{
    NSString * _directoryName;
}

@end

@implementation AMFileCache

@synthesize directoryName = _directoryName;

+ (AMFileCache *)sharedInstance
{
    static AMFileCache * sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMFileCache alloc] init];
    });
    
    return sharedInstance;
}

/*删除特殊字符
 *@param    str   需要处理的字符串
 *@retrun   NSString    处理后的字符串
 */
+ (NSString *)delegateSpecialCharacters:(NSString *)str
{
    NSString *str1=[str stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *str2=[str1 stringByReplacingOccurrencesOfString:@"!" withString:@""];
    
    return str2;
}

#pragma mark - Methods

- (BOOL)saveFile:(NSData *)file WithFileName:(NSString *)name
{
    if (!file) return NO;
    NSArray * paths = nil;
    NSString * documentsDirectory = nil;// Get documents folder
    NSString * directoryPath = nil;
    NSString * dataPath = nil;

    if (_directoryName) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        directoryPath = [documentsDirectory stringByAppendingPathComponent:_directoryName];
        dataPath = [directoryPath stringByAppendingPathComponent:name];
    }
    else
    {
        dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    }
    
    return [file writeToFile:dataPath atomically:YES];
}

- (NSData *)getFile:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        return nil;
    }
    NSArray * paths = nil;
    NSString * documentsDirectory = nil;// Get documents folder
    NSString * directoryPath = nil;
    NSString * dataPath = nil;
    
    if (_directoryName) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        directoryPath = [documentsDirectory stringByAppendingPathComponent:_directoryName];
        dataPath = [directoryPath stringByAppendingPathComponent:name];
    }
    else
    {
        dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    }
    NSFileManager * fm = [NSFileManager defaultManager];
    
    return [fm contentsAtPath:dataPath];
}

- (BOOL)removeFile:(NSString *)name
{
    NSArray * paths = nil;
    NSString * documentsDirectory = nil;// Get documents folder
    NSString * directoryPath = nil;
    NSString * dataPath = nil;
    
    if (_directoryName) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        directoryPath = [documentsDirectory stringByAppendingPathComponent:_directoryName];
        dataPath = [directoryPath stringByAppendingPathComponent:name];
    }
    else
    {
        dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    }
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError* error;
    
    return [fm removeItemAtPath:dataPath error:&error];
}

- (BOOL)isExistFile:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        return NO;
    }
    NSArray * paths = nil;
    NSString * documentsDirectory = nil;// Get documents folder
    NSString * directoryPath = nil;
    NSString * dataPath = nil;
    
    if (_directoryName) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        directoryPath = [documentsDirectory stringByAppendingPathComponent:_directoryName];
        dataPath = [directoryPath stringByAppendingPathComponent:name];
    }
    else
    {
        dataPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    }
    NSFileManager * fm = [NSFileManager defaultManager];
    BOOL isDirctory = YES;
    
    return [fm fileExistsAtPath:dataPath isDirectory:&isDirctory];

}

- (NSString *)getDirectoryPath
{
    NSArray * paths = nil;
    NSString * documentsDirectory = nil;// Get documents folder
    NSString * directoryPath = nil;
    
    if (_directoryName) {
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        directoryPath = [documentsDirectory stringByAppendingPathComponent:_directoryName];
    }
    else
    {
        directoryPath = NSTemporaryDirectory() ;
    }
    
    return directoryPath;
}

- (NSArray *)getFilesListByFilter:(NSPredicate *)filter
{
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getDirectoryPath] error:nil];
    NSArray * filesWithFilter = [files filteredArrayUsingPredicate:filter];

    return filesWithFilter;
}

#pragma mark - Init

- (void)setDirectoryName:(NSString *)directoryName
{
    _directoryName = directoryName;
    
    if (_directoryName && ![_directoryName isEqualToString:@""]) {
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString * dataPath = [documentsDirectory stringByAppendingPathComponent:_directoryName];
        NSFileManager * fm = [NSFileManager defaultManager];
        NSError* error;
        BOOL isDirctory = YES;
        
        if ([fm fileExistsAtPath:dataPath isDirectory:&isDirctory]){//存在，检查时间有效性
            NSDictionary* attrs = [fm attributesOfItemAtPath:dataPath error:&error];
            //NSDate *date = nil;
            
            if (attrs != nil && isDirctory == YES) {
                
                /*date = (NSDate*)[attrs objectForKey: NSFileCreationDate];
                if (date) {
                    if ([date timeIntervalSinceNow] < -DIRECTORYVALIDTIMELENGTH) {
                        DLog(@"removeItemAtPath start");
                        [fm removeItemAtPath:dataPath error:&error];
                        DLog(@"removeItemAtPath end");
                    }
                }
                else{//无创建时间，删除
                    [fm removeItemAtPath:dataPath error:&error];
                }*/
            }
            else//无法获取文件夹属性，删除
                [fm removeItemAtPath:dataPath error:&error];
        }
        
        if (![fm fileExistsAtPath:dataPath]){//不存在则重新创建
            if([fm createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error])
                ;// success
            else
            {
                DLog(@"Failed to create directory %@,error:%@",dataPath,error);
            }
        }
    }

}

- (id)initWithDirectoryName:(NSString *) name
{
    self = [super init];
    
    self.directoryName = name;

    return self;
}

@end
