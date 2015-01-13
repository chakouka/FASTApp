//
//  AMUtilities.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMUtilities.h"
#import "AMProtocolParser.h"
#import "SFRestAPI.h"
#import "SFOAuthCoordinator.h"
#import "RegexKitLite.h"
#import "SFAuthenticationManager.h"

@implementation AMUtilities

+ (void)logout
{
    [[SFAuthenticationManager sharedManager] logout];
    [SVProgressHUD dismiss];
}

+ (NSTimeInterval)currentTime {
	return [[self class] timeBySecondWithDate:[NSDate date]];
}

+ (NSTimeInterval)daysLater:(NSInteger)aDays {
	return [self daysLater:aDays after:[[self class] currentTime]];
}

+ (NSTimeInterval)daysLater:(NSInteger)aDays after:(NSTimeInterval)aDay {
	return (aDay + aDays * 24 * 60 * 60);
}

+ (NSTimeInterval)daysBefore:(NSInteger)aDays from:(NSTimeInterval)aDay {
	return (aDay - aDays * 24 * 60 * 60);
}

+ (NSTimeInterval)timeBySecondWithDate:(NSDate *)aDate {
	return (int)([aDate timeIntervalSince1970] + 0.5);
}

+ (NSDate *)dateWithTimeSecond:(NSTimeInterval)aTimeInterval {
	return [NSDate dateWithTimeIntervalSince1970:aTimeInterval];
}


+ (id)loadViewByClassName:(NSString *)classNameStr fromXib:(NSString *)xibName {
	Class className = NSClassFromString(classNameStr);
	NSArray *nib;
	if (xibName) {
		nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil];
	}
	else {
		nib = [[NSBundle mainBundle] loadNibNamed:kAMCommonViewsXibName owner:self options:nil];
	}

	for (id oneObject in nib)
		if ([oneObject isMemberOfClass:className]) {
			return oneObject;
		}

	return nil;
}

+ (UIFont *)applicationFontWithOption:(FontOption)option andSize:(CGFloat)size {
	NSString *familyName = @"RopaSans";
	NSString *suffix;
	switch (option) {
		case kFontOptionRegular:
			suffix = @"-Regular";
			break;

		case kFontOptionItalic:
			suffix = @"-Italic";
			break;

//		case kFontOptionBold:
//			suffix = @"-Bold";
//			break;

		default:
			break;
	}

	return [UIFont fontWithName:[familyName stringByAppendingString:suffix] size:size];
}

+ (NSString *)daysFromDate:(NSDate *)fromDate ToDate:(NSDate *)toDate {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSDate *senddate = fromDate;
	NSDate *endDate = toDate;
	NSDate *senderDate = [dateFormatter dateFromString:[dateFormatter stringFromDate:senddate]];
	NSTimeInterval time = [endDate timeIntervalSinceDate:senderDate];

	int days = ((int)time) / (3600 * 24);
	int hours = ((int)time) % (3600 * 24) / 3600 + days * 24;

	NSString *dateContent = @"";

	if (days <= 0 && hours <= 0) {
		dateContent = @"0 hr";
	}
	else {
		dateContent = [[NSString alloc] initWithFormat:@"%i hrs", hours];
	}

	return dateContent;
}

+ (void)animateScrollView:(UIScrollView *)scrollView xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset
{
    CGSize contentSize = scrollView.contentSize;
    CGFloat newWidth = contentSize.width;
    CGFloat newHeight = contentSize.height;
    if (contentSize.width - xOffset > 0) {
        newWidth -= xOffset;
    }
    if (contentSize.height - yOffset > 0) {
        newHeight -= yOffset;
    }
    CGSize newContentSize = CGSizeMake(newWidth, newHeight);
    scrollView.contentSize = newContentSize;
}

+ (void)animateScrollView:(UIScrollView *)scrollView subView:(UIView *)subView showKeyboard:(BOOL)willShow
{
    CGFloat subViewY = subView.frame.origin.y;
    CGPoint originOffset = scrollView.contentOffset;
    CGRect viewRect = scrollView.frame;
    CGRect newRect;
    CGPoint offset;
    if (willShow) {
        if (CGRectGetHeight(viewRect) - 352.0 <= 0) {
            DLog(@"willShow Yes returned");
            return;
        }
        newRect = CGRectMake(viewRect.origin.x, viewRect.origin.y, CGRectGetWidth(viewRect), CGRectGetHeight(viewRect) - 352.0);
        offset = CGPointMake(0, originOffset.y + 352.0);
        if (offset.y > subViewY - 40.0) { //40.0 is for header view
            offset.y = subViewY - 40.0;
        }
        
    } else {
        if (CGRectGetHeight(viewRect) + 352.0 > 768) {
            DLog(@"willShow NO returned");
            return;
        }
        newRect = CGRectMake(viewRect.origin.x, viewRect.origin.y, CGRectGetWidth(viewRect), CGRectGetHeight(viewRect) + 352.0);
        offset = CGPointMake(0.0, originOffset.y - 352.0 < 0.0 ? 0.0 : originOffset.y - 352.0);
    }
    DLog(@"WillShow: %@, offset Y Value: %f", willShow == YES ? @"YES" : @"NO", offset.y);
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.frame = newRect;
    } completion:^(BOOL finished) {
        [scrollView setContentOffset:offset];
    }];
}

+ (void)animateScrollView:(UIScrollView *)scrollView showKeyboard:(BOOL)willShow
{
    CGPoint originOffset = scrollView.contentOffset;
    CGRect viewRect = scrollView.frame;
    CGRect newRect;
    CGPoint offset;
    if (willShow) {
        if (CGRectGetHeight(viewRect) - 352.0 <= 0) {
            return;
        }
        newRect = CGRectMake(viewRect.origin.x, viewRect.origin.y, CGRectGetWidth(viewRect), CGRectGetHeight(viewRect) - 352.0);
        offset = CGPointMake(0, originOffset.y + 352.0);
        
    } else {
        if (CGRectGetHeight(viewRect) + 352.0 >= 768) {
            return;
        }
        newRect = CGRectMake(viewRect.origin.x, viewRect.origin.y, CGRectGetWidth(viewRect), CGRectGetHeight(viewRect) + 352.0);
        offset = CGPointMake(0.0, originOffset.y - 352.0 < 0.0 ? 0.0 : originOffset.y - 352.0);
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        scrollView.frame = newRect;
    } completion:^(BOOL finished) {
        [scrollView setContentOffset:offset];
    }];
}

+ (void)animateView:(UIView *)view direction:(AnimationDirection)direction distance:(float)distance
{
    const float movementDuration = 0.5f;
    switch (direction) {
        case AnimationDirectionUp:
        {
            [UIView animateWithDuration:movementDuration animations:^(void){
                view.frame = CGRectOffset(view.frame, 0, -distance);
            }];
            break;
        }
        case AnimationDirectionDown:
        {
            [UIView animateWithDuration:movementDuration animations:^(void){
                view.frame = CGRectOffset(view.frame, 0, distance);
            }];
            break;
        }
        case AnimationDirectionLeft:
            
            break;
            
        case AnimationDirectionRight:
            
            break;
            
        default:
            break;
    }
    
}

+ (void)setupViewShadow:(UIView *)view shadowColor:(UIColor *)shadowColor cornerRadius:(CGFloat)radius
{
    if (view) {
        UIColor *sColor = [UIColor grayColor];
        CGFloat cornerRadius = 4.0;
        if (shadowColor) {
            sColor = shadowColor;
        }
        if (radius > 0.0) {
            cornerRadius = radius;
        }
        [view.layer setCornerRadius:cornerRadius];
        [view.layer setShadowColor:sColor.CGColor];
        [view.layer setShadowOpacity:0.8];
        [view.layer setShadowRadius:3.0];
        [view.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
    }
}

+ (void)refreshFontInView:(UIView *)aView
{
    for (UIView *subview in [aView subviews]) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)subview;
            [lbl setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)subview;
            [tf setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        } else if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)subview;
            [btn.titleLabel setFont:[AMUtilities applicationFontWithOption:kFontOptionRegular andSize:kAMFontSizeCommon]];
        }else if ([[subview subviews] count] > 0) {
            [self refreshFontInView:subview];
        }
    }
}

+ (NSMutableAttributedString *)getAttributedStringFromString:(NSString *)originalString withAttributeDictionary:(NSDictionary *)attributeDic forRange:(NSRange)range{
    
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc]initWithString:originalString];
    if (range.location != NSNotFound) {
        [resultString addAttributes:attributeDic range:range];
    }
    return resultString;
}

+ (BOOL)isValidIntegerValueTyped:(NSString *)string
{
    NSString *expression = @"^[1-9]\\d*$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];
    if (numberOfMatches == 0)
        return NO;
    return YES;
}

+ (BOOL)isValidFloatingValueTyped:(NSString *)string
{
    NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];
    if (numberOfMatches == 0)
        return NO;
    return YES;
}

+ (NSString *)encodeToBase64String:(NSData *)imageData withScale:(float)scaleValue{
    UIImage *image=nil;
    if (scaleValue != 1.0) {
        image=[self scaleImage:[[UIImage alloc]initWithData:imageData] toScale:scaleValue];
    } else {
        image = [[UIImage alloc] initWithData:imageData];
    }
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (NSMutableAttributedString *)addAttributeToString:(NSAttributedString *)originalAttrString withAttrbuteDictionary:
(NSDictionary *)attributeDic forRange:(NSRange)range{
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc]initWithAttributedString:originalAttrString];
    if (range.location != NSNotFound) {
        [resultString addAttributes:attributeDic range:range];
    }
    return resultString;
}


+ (UIImage *)scaleImage:(UIImage  *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize, image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width*scaleSize, image.size.height*scaleSize)];
    UIImage *scaledImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

#pragma mark - 

//- (void)reachabilityWithHostName:(NSString *)aHostName
//{
//    Reachability *r = [Reachability reachabilityWithHostName:aHostName];
//    switch ([r currentReachabilityStatus]) {
//        case NotReachable:
//            // 没有网络连接
//            NSLog(@"没有网络");
//            
//            break;
//        case ReachableViaWWAN:
//            // 使用3G网络
//            NSLog(@"正在使用3G网络");
//            break;
//        case ReachableViaWiFi:
//            // 使用WiFi网络
//            NSLog(@"正在使用wifi网络");
//            break;
//    }
//}

+(NSDate *)todayBeginningDate
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [[AMProtocolParser sharedInstance] timeZoneOnSalesforce];
    
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSDate *date = [calendar dateFromComponents:components];
    
    return date;
}

+(NSString *)getToken
{
    NSString *token = [SFRestAPI sharedInstance].coordinator.credentials.accessToken;
    return token;
}

+ (void)showAlertWithInfo:(NSString *)aInfo
{
    [UIAlertView showWithTitle:@""
                       message:aInfo
             cancelButtonTitle:MyLocal(@"OK")
             otherButtonTitles:nil
                      tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
                          if (buttonIndex == [alertView cancelButtonIndex]) {
                              return;
                          }
                      }];
}

+ (BOOL)isValidEmailValueTyped:(NSString *)string
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:string];
}

+ (CLLocation *)currentLocation
{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:KEY_OF_CURRENT_LOCATION]) {
        return nil;
    }
    
    NSMutableDictionary *dicInfo = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_OF_CURRENT_LOCATION];
    return [[CLLocation alloc] initWithLatitude:[[dicInfo objectForKey:@"KEY_OF_LATITUDE"] floatValue] longitude:[[dicInfo objectForKey:@"KEY_OF_LONGITUDE"] floatValue]];
}

+ (void)saveCurrentLongitude:(NSNumber *)longitude andLatitude:(NSNumber *)latitude
{
    NSMutableDictionary *dicInfo = [NSMutableDictionary dictionary];
    [dicInfo setObject:longitude forKey:@"KEY_OF_LONGITUDE"];
    [dicInfo setObject:latitude forKey:@"KEY_OF_LATITUDE"];
    [[NSUserDefaults standardUserDefaults] setObject:dicInfo forKey:KEY_OF_CURRENT_LOCATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(BOOL)isEmpty:(NSString *)aStr
{
    if (!aStr)
    {
        return TRUE;
    }
    else
    {
        NSString *trimedString = [aStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0)
        {
            return TRUE;
        }
        else
        {
            return FALSE;
        }
    }
}

+ (NSIndexPath *)indexPathForView:(UIView *)aView inTableView:(UITableView *)tableView
{
    UIView* contentView =[aView superview];
    CGPoint center = [tableView convertPoint:aView.center fromView:contentView];
    NSIndexPath *indexpath =[tableView indexPathForRowAtPoint:center];
    return indexpath;
}

+ (MKCoordinateRegion)regionWithCenterCoordinate:(CLLocationCoordinate2D)aCenterCoordinate
{
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = aCenterCoordinate.latitude;
    centerCoordinate.longitude = aCenterCoordinate.longitude;
    
    MKCoordinateSpan span;
    span.latitudeDelta = 1;
    span.longitudeDelta = 1;
    MKCoordinateRegion region;
    region.center = centerCoordinate;
    region.span = span;
    
    return region;
}

@end









