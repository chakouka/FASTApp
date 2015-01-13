//
//  NSString+Extend.m
//  MapShow
//
//  Created by PwC on 4/22/14.
//  Copyright (c) 2014 PwC. All rights reserved.
//

#import "NSString+Extend.h"

@implementation NSString (Extend)


//Use this category method can solve the problem of calculate UILable's text length bug
-(CGFloat)TextHeightWithFontSize:(int)fontsize Width:(int)width{
    CGSize constraint = CGSizeMake(width, MAXFLOAT);
    UILabel *lbl = [[UILabel alloc]init];
    UIFont *font =[UIFont fontWithName:lbl.font.familyName size:fontsize];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil];
    
    CGSize size = [self boundingRectWithSize:constraint options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading  attributes:dic context:nil].size;
    CGFloat height = MAX(size.height, 44.0f);
    return height;
}

- (BOOL)isEqualToLocalizedString:(NSString *)inputString
{
    return ([self isEqualToString:inputString] || [self isEqualToString:MyLocal(inputString)]);
}

@end
