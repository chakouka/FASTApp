//
//  GoogleUtility.h
//  Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegexKitLite.h"
#import "NSString+MD5Addition.h"

typedef NS_ENUM (NSUInteger, NaviMode)
{
    kModeDriving = 0,
    kModeBicycle,
    kModeWalking
};

@interface GoogleUtility : NSObject

+ (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedLine
                         fromPoint:(CLLocationCoordinate2D)origin
                           toPoint:(CLLocationCoordinate2D)destination;

+ (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedLine
                         fromPoint:(CLLocationCoordinate2D)origin;

+ (NSString *)filterHtmlTag:(NSString *)originHtmlStr;

+ (BOOL)isExistDataForURL:(NSURL *)aURL;

+ (void)saveData:(NSData *)aData withURL:(NSURL *)aURL;

+ (NSData *)dataWithURL:(NSURL *)aURL;

+ (NSString *)stringWithType:(NaviMode)aType;

+ (NSString *)finalDirectionURL:(NSString *)aUrl;
@end
