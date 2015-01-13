//
//  AMFileCache.h
//  PwC
//
//  Created by David Liu on 13-3-14.
//
//

#import <Foundation/Foundation.h>

@interface AMFileCache : NSObject

@property (nonatomic,strong) NSString * directoryName;

+ (AMFileCache *)sharedInstance;
- (id)initWithDirectoryName:(NSString *) name;
- (BOOL)saveFile:(NSData *)file WithFileName:(NSString *)name;
- (NSData *)getFile:(NSString *)name;
- (BOOL)removeFile:(NSString *)name;
- (BOOL)isExistFile:(NSString *)name;
- (NSString *)getDirectoryPath;
- (NSArray *)getFilesListByFilter:(NSPredicate *)filter;

/*删除特殊字符
 *@param    str   需要处理的字符串
 *@retrun   NSString    处理后的字符串
 */
+ (NSString *)delegateSpecialCharacters:(NSString *)str;
@end
