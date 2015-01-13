//
//  AMUtilities.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum
{
    kFontOptionRegular,
    kFontOptionItalic,
//    kFontOptionBold
} FontOption;

@interface AMUtilities : NSObject

@property (nonatomic) CGPoint originalOffset;

+ (void)logout;

+ (NSTimeInterval)currentTime;

+ (NSTimeInterval)daysLater:(NSInteger)aDays;

+ (NSTimeInterval)daysLater:(NSInteger)aDays after:(NSTimeInterval)aDay;

+ (NSTimeInterval)daysBefore:(NSInteger)aDays from:(NSTimeInterval)aDay;

+ (NSTimeInterval)timeBySecondWithDate:(NSDate *)aDate;

+ (NSDate *)dateWithTimeSecond:(NSTimeInterval)aTimeInterval;

/**
 *  Load View from the specified xib
 *
 *  @param className className description
 *  @param xibName   xibName description, if nil, kAMCommonViewsXibName is default value
 *
 *  @return return View, or nil if no view found in passed xib file
 */
+ (id)loadViewByClassName:(NSString *)className fromXib:(NSString *)xibName;

/**
 *  Set up Shadow for View
 *
 *  @param view        destination view
 *  @param shadowColor shadow Color
 *  @param radius      radius value
 */
+ (void)setupViewShadow:(UIView *)view shadowColor:(UIColor *)shadowColor cornerRadius:(CGFloat)radius;


+ (UIFont *)applicationFontWithOption:(FontOption)option andSize:(CGFloat)size;

+ (NSString *)daysFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate;

/**
 *  Move @view with animation
 *
 *  @param view      the view should be animated
 *  @param direction value of WFAnimationDirection
 *  @param distance  float value
 */
+ (void)animateView:(UIView *)view direction:(AnimationDirection)direction distance:(float)distance;

+ (void)animateScrollView:(UIScrollView *)scrollView showKeyboard:(BOOL)willShow;
+ (void)animateScrollView:(UIScrollView *)scrollView subView:(UIView *)subView showKeyboard:(BOOL)willShow;

+ (void)refreshFontInView:(UIView *)aView;

+ (NSMutableAttributedString *)getAttributedStringFromString:(NSString *)originalString withAttributeDictionary:(NSDictionary *)attributeDic forRange:(NSRange)range;

/**
 *  Check whether the input data is valid floating value or not
 *
 *  @param string input data
 *
 *  @return Return YES if the typed string is floating value, otherwise return NO
 */
+ (BOOL)isValidFloatingValueTyped:(NSString *)string;

/**
 *  Check whether the input data is valid Integer value or not
 *
 *  @param string input data
 *
 *  @return Return YES if the typed string is integer value, otherwise return NO
 */
+ (BOOL)isValidIntegerValueTyped:(NSString *)string;

+ (NSString *)encodeToBase64String:(NSData *)imageData withScale:(float)scaleSize;

+ (UIImage *)scaleImage:(UIImage  *)image toScale:(float)scaleSize;

+ (NSMutableAttributedString *)addAttributeToString:(NSAttributedString *)originalAttrString withAttrbuteDictionary:
(NSDictionary *)attributeDic forRange:(NSRange)range;

+(NSDate *)todayBeginningDate;

+(NSString *)getToken;

+ (void)showAlertWithInfo:(NSString *)aInfo;

+ (BOOL)isValidEmailValueTyped:(NSString *)string;

+ (CLLocation *)currentLocation;

+ (void)saveCurrentLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude;

+(BOOL)isEmpty:(NSString *)aStr;

+ (NSIndexPath *)indexPathForView:(UIView *)aView inTableView:(UITableView *)tableView;

+ (MKCoordinateRegion)regionWithCenterCoordinate:(CLLocationCoordinate2D)aCenterCoordinate;

@end











