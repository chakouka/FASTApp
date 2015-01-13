//
//  GoogleUtility.m
//  Todo
//
//  Created by PwC on 4/14/14.
//  Copyright (c) 2014 viktyz. All rights reserved.
//

#import "GoogleUtility.h"
#import <Foundation/NSString.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GTMStringEncoding.h"

//#define KEY_OF_GOOLGE   @"AIzaSyAoo4_dkWBGs3Oc3vE1JlSTYYIZL4rvi30"
#define KEY_OF_GOOLGE   @"AIzaSyDOEOObeIM4E1RFbnxhbeC4-52ZyZRlSzw"
//#define KEY_OF_GOOGLE   @"AIzaSyBi4yVWkxUVAshJhfuqOSoAWrp1GDjRoKQ"

//ClientID gme-aramark
//CryptoKey 3Egitvg4iS6M1W-ydEOqw-Rxm08=

#define KEY_OF_CLIENT_ID    @"gme-aramark"
#define KEY_OF_CRYPTOKEY    @"3Egitvg4iS6M1W-ydEOqw-Rxm08="

@implementation GoogleUtility

#pragma mark GPS Routes

+ (NSString *)pathWithName:(NSString *)aName {
	NSString *documentsDirectory = NSTemporaryDirectory();
	return [documentsDirectory stringByAppendingPathComponent:aName];
}

+ (BOOL)isExistDataForURL:(NSURL *)aURL {
    if (!aURL) {
        return NO;
    }
	NSString *strName = [[aURL absoluteString] md5];
	return [[NSFileManager defaultManager] fileExistsAtPath:[self pathWithName:strName]];
}

+ (void)saveData:(NSData *)aData withURL:(NSURL *)aURL {
	if (![self isExistDataForURL:aURL]) {
		NSString *strName = [[aURL absoluteString] md5];
		[aData writeToFile:[self pathWithName:strName] atomically:YES];
	}
}

+ (NSData *)dataWithURL:(NSURL *)aURL
{
    NSString *strName = [[aURL absoluteString] md5];
    NSString *strPath = [self pathWithName:strName];
    return [NSData dataWithContentsOfFile:strPath];
}

+ (NSString *)filterHtmlTag:(NSString *)originHtmlStr {
	NSScanner *theScanner;
	NSString *text = nil;
    
	theScanner = [NSScanner scannerWithString:originHtmlStr];
    
	while ([theScanner isAtEnd] == NO) {
		[theScanner scanUpToString:@"<" intoString:NULL];
        
		[theScanner scanUpToString:@">" intoString:&text];
        
		originHtmlStr = [originHtmlStr stringByReplacingOccurrencesOfString:
		                 [NSString stringWithFormat:@"%@>", text]
		                                                         withString:@""];
	}
    
	return originHtmlStr;
}

+ (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedLine
                         fromPoint:(CLLocationCoordinate2D)origin
                           toPoint:(CLLocationCoordinate2D)destination {
	NSMutableString *encodedPoints = [encodedLine mutableCopy];
	[encodedPoints replaceOccurrencesOfString:@"\\\\" withString:@"\\"
	                                  options:NSLiteralSearch
	                                    range:NSMakeRange(0, [encodedPoints length])];
    
	NSMutableArray *array = [NSMutableArray array];
	array = [[self class] polylineWithEncodedString:encodedLine];
    
	CLLocation *first   = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:origin.latitude] floatValue]
	                                                 longitude:[[NSNumber numberWithFloat:origin.longitude] floatValue]];
	CLLocation *end     = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:destination.latitude] floatValue]
	                                                 longitude:[[NSNumber numberWithFloat:destination.longitude] floatValue]];
	[array insertObject:first atIndex:0];
	[array addObject:end];
	return array;
}

+ (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedLine
                         fromPoint:(CLLocationCoordinate2D)origin{
	NSMutableString *encodedPoints = [encodedLine mutableCopy];
	[encodedPoints replaceOccurrencesOfString:@"\\\\" withString:@"\\"
	                                  options:NSLiteralSearch
	                                    range:NSMakeRange(0, [encodedPoints length])];
    
	NSMutableArray *array = [NSMutableArray array];
	array = [[self class] polylineWithEncodedString:encodedLine];
    
	CLLocation *first   = [[CLLocation alloc] initWithLatitude:[[NSNumber numberWithFloat:origin.latitude] floatValue]
	                                                 longitude:[[NSNumber numberWithFloat:origin.longitude] floatValue]];
	[array insertObject:first atIndex:0];
	return array;
}

+ (NSMutableArray *)polylineWithEncodedString:(NSString *)encodedString {
	NSMutableArray *array = [NSMutableArray array];
	const char *bytes = [encodedString UTF8String];
	NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	NSUInteger idx = 0;
    
	float latitude = 0;
	float longitude = 0;
	while (idx < length) {
		char byte = 0;
		int res = 0;
		char shift = 0;
        
		do {
			byte = bytes[idx++] - 63;
			res |= (byte & 0x1F) << shift;
			shift += 5;
		}
		while (byte >= 0x20);
        
		float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
		latitude += deltaLat;
        
		shift = 0;
		res = 0;
        
		do {
			byte = bytes[idx++] - 0x3F;
			res |= (byte & 0x1F) << shift;
			shift += 5;
		}
		while (byte >= 0x20);
        
		float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
		longitude += deltaLon;
        
		float finalLat = latitude * 1E-5;
		float finalLon = longitude * 1E-5;
        
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:finalLat longitude:finalLon];
		[array addObject:loc];
	}
    
	return array;
}

+(NSString *)stringWithType:(NaviMode)aType
{
    NSString *naviMode = @"";
    
    switch (aType) {
		case kModeBicycle:
			naviMode = @"bicycling";
			break;
            
		case kModeWalking:
			naviMode = @"walking";
			break;
            
		default:
			naviMode = @"driving";
			break;
	}
    
    return naviMode;
}

#pragma mark -
+ (NSString *)finalDirectionURL:(NSString *)aUrl
{
#ifdef TEST_FOR_FREE_GOOGLE_KEY
    return [NSString stringWithFormat:@"https://maps.googleapis.com%@&key=%@",aUrl,KEY_OF_GOOLGE];
#else
    NSString *key = KEY_OF_CRYPTOKEY;
    NSString *aClientID = KEY_OF_CLIENT_ID;
    
    NSString *url = [aUrl stringByAppendingString:[NSString stringWithFormat:@"&client=%@",aClientID]];
    NSData *urlData = [url dataUsingEncoding: NSASCIIStringEncoding];
    
    GTMStringEncoding *encoding = [GTMStringEncoding rfc4648Base64WebsafeStringEncoding];
    
    NSData *binaryKey = [encoding decode:key];
    
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1,
           [binaryKey bytes], [binaryKey length],
           [urlData bytes], [urlData length],
           &result);
    NSData *binarySignature =
    [NSData dataWithBytes:&result length:CC_SHA1_DIGEST_LENGTH];
    
    NSString *signature = [encoding encode:binarySignature];
    
    return [NSString stringWithFormat:@"http://maps.googleapis.com%@&signature=%@", url,
            signature];
#endif
}

@end
