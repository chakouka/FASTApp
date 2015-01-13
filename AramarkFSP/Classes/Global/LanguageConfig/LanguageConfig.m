//
//  LanguageConfig.m
//  AramarkFSP
//
//  Created by FYH on 9/16/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "LanguageConfig.h"

@implementation LanguageConfig

+ (LanguageConfig *)sharedInstance
{
    static dispatch_once_t onceToken;
    static LanguageConfig *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LanguageConfig alloc] init];
    });
    return sharedInstance;
}

+ (UIButton *)button:(UIButton *)aButton withImage:(NSString *)aString
{
    [aButton setImage:[UIImage imageNamed:MyImage(aString)] forState:UIControlStateNormal];
    [aButton setImage:[UIImage imageNamed:MyImage(aString)] forState:UIControlStateHighlighted];
    return aButton;
}

+ (UIButton *)button:(UIButton *)aButton withTitle:(NSString *)aString
{
    [aButton setTitle:aString forState:UIControlStateNormal];
    [aButton setTitle:aString forState:UIControlStateHighlighted];
    return aButton;
}

+ (NSString *)imageWithString:(NSString *)aString
{
    NSString *str = nil;
    
    switch ([self currentLanguage]) {
        case LanguageType_French:
        {
            str = [aString stringByAppendingString:@"-fr"];
        }
            break;
            
        default:
        {
            str = aString;
        }
            break;
    }
    
    return str;
}

+ (NSString *)stringWithString:(NSString *)aString
{
    NSString *str = nil;
    
    switch ([self currentLanguage]) {
        case LanguageType_French:
        {
            str = [[self dictionaryForLanguage:LanguageType_French] objectForKey:aString];
            
            if ([[self class] isEmpty:str]) {
                str = aString;
//                str = [NSString stringWithFormat:@"T:%@",aString]; //TODO::For Test
//                NSLog(@"Need Translation : %@",aString);
            }
        }
            break;
            
        default:
        {
            str = aString;
        }
            break;
    }
    
    return str;
}

+ (NSDictionary *)dictionaryForLanguage:(LanguageType)languageType
{
    switch (languageType) {
        case LanguageType_French:
        {
            if (![self sharedInstance].frenchDictionary) {
                NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"French" ofType:@"plist"];
                [self sharedInstance].frenchDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
            }
            return [self sharedInstance].frenchDictionary;
        }
            break;
            
        default:
            break;
    }
    return nil;
}

+ (void)setLanguage:(LanguageType)aType
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:aType] forKey:kAMAPPLICATION_CURRENT_LANGUAGE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//+ (void)setLanguageWithNumberValue:(NSNumber *)numberLang
//{
//    [USER_DEFAULT setObject:numberLang forKey:kAMAPPLICATION_CURRENT_LANGUAGE_KEY];
//    [USER_DEFAULT synchronize];
//}

+ (LanguageType)currentLanguage
{
    
//    return LanguageType_French; //TODO::
    
    LanguageType type = LanguageType_English;
    
    if ([@"en" isEqualToString:[[NSLocale preferredLanguages] objectAtIndex:0]])
    {
        type = LanguageType_English;
    }
    else if([@"fr" isEqualToString:[[NSLocale preferredLanguages] objectAtIndex:0]])
    {
        type = LanguageType_French;
    }
    
    NSNumber *languageType = [[NSUserDefaults standardUserDefaults] objectForKey:kAMAPPLICATION_CURRENT_LANGUAGE_KEY];
    
    return languageType ? [languageType intValue] : type;
}

+ (BOOL)applicationLanguageChanged:(LanguageType)languageType
{
    return languageType != [self currentLanguage];
}

+(BOOL)isEmpty:(NSString *)aStr
{
    return
    aStr == nil
    || [aStr isEqualToString:@"<null>"]
    || [aStr isEqualToString:@"(null)"]
    || [aStr  isEqualToString:NULL]
    || [aStr isKindOfClass:[NSNull class]]
    || ([aStr respondsToSelector:@selector(length)] && [(NSData *)aStr length] == 0)
    || ([aStr respondsToSelector:@selector(count)] && [(NSArray *)aStr count] == 0);
}
@end
