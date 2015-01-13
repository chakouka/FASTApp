//
//  LanguageConfig.h
//  AramarkFSP
//
//  Created by FYH on 9/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, LanguageType) {
    LanguageType_English = 0,
    LanguageType_French,
};

#define MyLocal(aString)                     [LanguageConfig stringWithString:aString]
#define MyImage(aString)                     [LanguageConfig imageWithString:aString]
#define MyButtonTitle(aButton,aString)            [LanguageConfig button:aButton withTitle:aString]
#define MyButtonImage(aButton,aString)            [LanguageConfig button:aButton withImage:aString]

@interface LanguageConfig : NSObject

@property (strong, nonatomic) NSDictionary *frenchDictionary;

+ (LanguageConfig *)sharedInstance;

+ (UIButton *)button:(UIButton *)aButton withImage:(NSString *)aString;

+ (UIButton *)button:(UIButton *)aButton withTitle:(NSString *)aString;

+ (NSString *)imageWithString:(NSString *)aString;

+ (NSString *)stringWithString:(NSString *)aString;

+ (void)setLanguage:(LanguageType)aType;

/**
 *  return YES if the current language is not same with languageType
 *
 *  @param LanguageType LanguageType_English or LanguageType_French
 *
 *  @return
 */
+ (BOOL)applicationLanguageChanged:(LanguageType)languageType;

/**
 *  Set up application language defualt value:
 *  0 for English;
 *  1 for French
 *
 *  @param numberLang
 */
//+ (void)setLanguageWithNumberValue:(NSNumber *)numberLang;

+ (LanguageType)currentLanguage;


@end
