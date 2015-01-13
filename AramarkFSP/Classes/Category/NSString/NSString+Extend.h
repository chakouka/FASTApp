//
//  NSString+Extend.h
//  MapShow
//
//  Created by PwC on 4/22/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extend)

//Use this category method can solve the problem of calculate UILable's text length bug
-(CGFloat)TextHeightWithFontSize:(int)fontsize Width:(int)width;

/**
 *  To validate whether the self string is equal to inputString or Localized inputString
 *
 *  @param inputString inputString
 *
 *  @return YES if equals to any of them, otherwise NO
 */
- (BOOL)isEqualToLocalizedString:(NSString *)inputString;

@end
