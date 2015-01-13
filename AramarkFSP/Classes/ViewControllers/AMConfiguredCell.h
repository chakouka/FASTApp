//
//  AMConfiguredCell.h
//  AramarkFSP
//
//  Created by Aaron Hu on 5/13/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    AMCellTypeEdit,
    AMCellTypeCheckBox,
    AMCellTypeDropDown,
    AMCellTypeTextArea
}AMCellType;

@interface AMConfiguredCell : NSObject

@property (nonatomic) AMCellType cellType;
@property (strong, nonatomic) NSString *cellTitle;
@property (strong, nonatomic) NSString *cellValue;
@property (nonatomic) BOOL isEditable;
@property (strong, nonatomic) NSDictionary *propertyDic;
@property (strong, nonatomic) NSString *propertyName;

- (id)initWithCellType:(AMCellType)cellType title:(NSString *)title value:(NSString *)value isEditable:(BOOL)boolValue;


- (id)initWithCellType:(AMCellType)cellType title:(NSString *)title propertyDic:(NSDictionary *)propertyDic isEditable:(BOOL)boolValue;

@end
