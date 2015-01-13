//
//  AMConfiguredCell.m
//  AramarkFSP
//
//  Created by Aaron Hu on 5/13/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import "AMConfiguredCell.h"

@implementation AMConfiguredCell

- (id)initWithCellType:(AMCellType)cellType title:(NSString *)title value:(NSString *)value isEditable:(BOOL)boolValue
{
    if (self = [super init]) {
        self.cellType = cellType;
        self.cellTitle = MyLocal(title);
        self.cellValue = value;
        self.isEditable = boolValue;
    }
    return self;
}

- (id)initWithCellType:(AMCellType)cellType title:(NSString *)title propertyDic:(NSDictionary *)propertyDic isEditable:(BOOL)boolValue
{
    if (self = [super init]) {
        self.cellType = cellType;
        self.cellTitle = MyLocal(title);
        self.cellValue = [propertyDic objectForKey:kAMPROPERTY_VALUE];
        self.propertyName = [propertyDic objectForKey:kAMPROPERTY_NAME];
        self.propertyDic = propertyDic;
        self.isEditable = boolValue;
    }
    return self;
}

@end
