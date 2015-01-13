//
//  AMLabelCount.h
//  AramarkFSP
//
//  Created by Aaron Hu on 6/12/14.
//  Copyright (c) 2014 PWC Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMLabelCount : UILabel

@property (nonatomic) NSInteger countNumber; //if > 0 will show, otherwise will be hidden

- (id)initWithCountNumber:(NSInteger)countNumber;

@end
